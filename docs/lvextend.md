The below documentation is to be used when you want to extend a `/dev/mapper` volume by attaching a new disk to the VM.

1. Login to the eclipsis panel and create a new disk on the same location as the VPS you want to attach it to. A good name could be `hkgmetadb.infra.ooni.io:pv05` where the first part is the hostname of the VPS and the `pv05` is the slot where you will be attaching the disk.

2. Shutdown the target host where you would like to attach the disk image too (you cannot attach a disk to a running VPS)

3. Go to the disk image and attach it to the correct slot on the VPS (labeling the disk image properly helps to find the next available slot)

4. Start up the VPS again

5. Login to the machine and go through the following checklist to expand the `/dev/mapper` partition. Replace `$disk` with the disk label you see in the configuration section of the VPS on the eclipsis portal

```
pvs; dd if=/dev/$disk bs=4096 count=16 | hexdump -C
pvcreate /dev/$disk
pvs; vgs
vgextend hkgmetadb /dev/$disk
vgs; lvs; df -h
lvextend --resizefs -l 100%VG hkgmetadb/srv
lvs; df -h
```

At the end you should see the disk being enlarged
