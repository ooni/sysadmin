#!/usr/bin/env python2

# That's Python2 as some nodes in our infra still have no Python3 and time.monotonic()

from contextlib import contextmanager, closing
import argparse
import ctypes
import math
import mmap
import os
import io
try:
    from Queue import Queue
except ImportError:
    from queue import Queue # Py3
import random
import threading
import time

SAMPLE_PERIOD = 30 # one IOP per X seconds
SECONDS_PER_BENCH = 10
IOP_BLOCK = mmap.PAGESIZE

RAMDISK_MAJOR = 1 # see <linux/major.h>
LOOP_MAJOR = 7 # see <linux/major.h>
CLOCK_MONOTONIC = 1 # see <linux/time.h>
CLOCK_MONOTONIC_RAW = 4 # see <linux/time.h>

class timespec(ctypes.Structure):
    _fields_ = [
        ('tv_sec', ctypes.c_long),
        ('tv_nsec', ctypes.c_long),
    ]

librt = ctypes.CDLL('librt.so.1', use_errno=True)
clock_gettime = librt.clock_gettime
clock_gettime.argtypes = [ctypes.c_int, ctypes.POINTER(timespec)]

def monotonic():
    t = timespec()
    if clock_gettime(CLOCK_MONOTONIC, ctypes.pointer(t)) != 0:
        errno_ = ctypes.get_errno()
        raise OSError(errno_, os.strerror(errno_))
    return t.tv_sec + t.tv_nsec * 1e-9

@contextmanager
def closing_open(*args):
    fd = None
    try:
        fd = os.open(*args)
        yield fd
    finally:
        if fd is not None:
            os.close(fd)

def seeksample(disk, offset=None, direct=True):
    # this is modeled after `gnome-disk-utility` random-read benchmark
    if offset is None:
        # ioctl(BLKGETSIZE64) is an alternative to /sys/block/*/size
        size = int(open('/sys/block/{}/size'.format(disk)).read())
        sizeblk = size / (IOP_BLOCK / 512) # `size` is measured in 512bytes blocks
        offset = random.randint(0, sizeblk - 1) * IOP_BLOCK
    # O_SYNC is not set as that's read/only benchmark, O_CLOEXEC is not in `os` at all
    open_flags = os.O_RDONLY
    if direct:
        open_flags |= os.O_DIRECT
    with closing_open('/dev/' + disk, open_flags) as fd, \
         closing(mmap.mmap(-1, IOP_BLOCK, mmap.MAP_PRIVATE)) as mm:
        # os.pread() and os.read() can't read O_DIRECT file as the buffer is not aligned,
        # so readinto() is used and mmap() provides aligned buffer.
        fobj = io.FileIO(fd, closefd=False)
        fobj.seek(offset)
        begin = monotonic()
        readlen = fobj.readinto(mm)
        end, now = monotonic(), time.time()
        if readlen != IOP_BLOCK:
            raise IOError('Error reading block from offset', disk, offset, IOP_BLOCK, readlen)
        if end < begin:
            raise RuntimeError('monotonic() ticks backwards', begin, end)
    return now, end - begin

def scraper(disk, dataq):
    smear = random.uniform(0, SAMPLE_PERIOD)
    while True:
        time.sleep(SAMPLE_PERIOD - ((time.time() - smear) % SAMPLE_PERIOD))
        try:
            timestamp, seektime = seeksample(disk)
            err = False
        except Exception:
            timestamp, seektime, err = None, None, True
        dataq.put((disk, timestamp, seektime, err))

def exporter(dataq, fpath):
    stats = {}
    while True:
        disk, timestamp, seektime, err = dataq.get()
        dataq.task_done()
        if disk not in stats:
            stats[disk] = {'sum': 0., 'count': 0, 'error': 0, 'timestamp': 0}
        el = stats[disk]
        if not err:
            el['sum'] += seektime
            el['count'] += 1
            el['timestamp'] = timestamp
        else:
            el['error'] += 1
        prom = ''.join([
            '# HELP node_seeksample_seconds_sum Seconds spend doing seek() sampling.\n'
            '# TYPE node_seeksample_seconds_sum counter\n'
        ]+ ['node_seeksample_seconds_sum{device="%s"} %f\n' % (d, stats[d]['sum']) for d in stats]+[
            '# HELP node_seeksample_seconds_count Count of seek() samples.\n'
            '# TYPE node_seeksample_seconds_count counter\n'
        ]+ ['node_seeksample_seconds_count{device="%s"} %d\n' % (d, stats[d]['count']) for d in stats]+[
            '# HELP node_seeksample_error_count Count of errors during seek() sampling.\n'
            '# TYPE node_seeksample_error_count counter\n'
        ]+ ['node_seeksample_error_count{device="%s"} %d\n' % (d, stats[d]['error']) for d in stats]+[
            '# HELP node_seeksample_timestamp Unixtime of last successful seek() sampling.\n'
            '# TYPE node_seeksample_timestamp gauge\n'
        ]+ ['node_seeksample_timestamp{device="%s"} %f\n' % (d, stats[d]['timestamp']) for d in stats])
        with open(fpath, 'w') as fd:
            fd.write(prom) # yes, it's not atomic, that's OK

def get_disks_to_test():
    to_test = []
    for disk in sorted(os.listdir('/sys/block')):
        slaves = os.listdir('/sys/block/{}/slaves'.format(disk))
        size = int(open('/sys/block/{}/size'.format(disk)).read())
        removable = int(open('/sys/block/{}/removable'.format(disk)).read())
        major = int(open('/sys/block/{}/dev'.format(disk)).read().split(':', 1)[0])
        if slaves:
            print('Skipped disk {}, it has slaves: {}'.format(disk, ' '.join(slaves)))
        elif size == 0:
            print('Skipped disk {}, size = 0'.format(disk))
        elif major == RAMDISK_MAJOR:
            print('Skipped disk {}, RAM disk'.format(disk))
        elif major == LOOP_MAJOR:
            print('Skipped disk {}, loop disk'.format(disk))
        elif removable:
            print('Skipped disk {}, is removable'.format(disk))
        else:
            seeksample(disk) # or `raise` in case of error
            to_test.append(disk)
    return to_test

def textfile(fpath):
    to_test = get_disks_to_test()
    dataq = Queue()
    for disk in to_test:
        t = threading.Thread(target=scraper, name='seek/'+disk, args=(disk, dataq))
        t.daemon = True
        t.start()
    exporter(dataq, fpath)

def bench_run(disk, n_samples):
    if disk == 'zero':
        # to estimate overhead
        return sorted(seeksample(disk, offset=0, direct=False)[1] for _ in range(n_samples))
    else:
        return sorted(seeksample(disk)[1] for _ in range(n_samples))

def bench(disk):
    data = bench_run(disk, 16)
    n_samples = min(262144, int(SECONDS_PER_BENCH / data[8]))
    if n_samples > 16:
        data.extend(bench_run(disk, n_samples - 16))
    data.sort()
    avg = sum(data) / n_samples
    sd = math.sqrt(sum((_ - avg) ** 2 for _ in data) / (n_samples-1)) # corrected sample standard deviation
    stats = [
        ('min', min(data)),
        ('p25', data[n_samples//4]),
        ('p50', data[n_samples//2]),
        ('p75', data[3*n_samples//4]),
        ('max', max(data)),
        ('avg', avg),
        ('dev', sd),
    ]
    print('{}: cnt {:d} samples'.format(disk, n_samples))
    for name, value in stats:
        print('{}: {} {:3f} ms'.format(disk, name, value * 1e3))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--bench-all', action='store_true', help='Run rough seek() benchmark for all devices')
    parser.add_argument('--bench', help='Run rough seek() benchmark for device')
    parser.add_argument('--textfile', help='Run sampler exporting seek() samples to prometheus textfile')
    opt = parser.parse_args()
    if opt.bench:
        bench(opt.bench)
    elif opt.bench_all:
        for disk in get_disks_to_test():
            bench(disk)
    elif opt.textfile:
        textfile(opt.textfile)
    else:
        parser.error('What should I do?')

if __name__ == '__main__':
    main()
