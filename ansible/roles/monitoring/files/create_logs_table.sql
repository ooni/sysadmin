CREATE TABLE IF NOT EXISTS default.logs
(
    `CODE_FILE` String,
    `CODE_FUNC` String,
    `CODE_LINE` String,
    `INVOCATION_ID` String,
    `LOGGER` String,
    `MESSAGE_ID` String,
    `MESSAGE` String,
    `PRIORITY` UInt8,
    `PROCESS_NAME` String,
    `SYSLOG_FACILITY` UInt16,
    `SYSLOG_IDENTIFIER` String,
    `SYSLOG_PID` Nullable(UInt64),
    `SYSLOG_TIMESTAMP` String,
    `THREAD_NAME` String,
    `TID` UInt64,
    `UNIT` String,
    `_AUDIT_LOGINUID` Nullable(UInt64),
    `_AUDIT_SESSION` Nullable(UInt64),
    `_BOOT_ID` String,
    `_CAP_EFFECTIVE` String,
    `_CMDLINE` String,
    `_COMM` String,
    `_EXE` String,
    `_GID` UInt16,
    `_HOSTNAME` String,
    `_KERNEL_DEVICE` String,
    `_KERNEL_SUBSYSTEM` String,
    `_MACHINE_ID` String,
    `_PID` UInt32,
    `_SELINUX_CONTEXT` String,
    `_STREAM_ID` String,
    `_SYSTEMD_CGROUP` String,
    `_SYSTEMD_INVOCATION_ID` String,
    `_SYSTEMD_SLICE` String,
    `_SYSTEMD_UNIT` String,
    `_TRANSPORT` String,
    `_UDEV_SYSNAME` String,
    `_UID` UInt32,
    `__CURSOR` String,
    `_SOURCE_MONOTONIC_TIMESTAMP` Nullable(Int64),
    `_SOURCE_REALTIME_TIMESTAMP` Int64,
    `__MONOTONIC_TIMESTAMP` Nullable(Int64),
    `__REALTIME_TIMESTAMP` Int64,
    date ALIAS fromUnixTimestamp64Micro(_SOURCE_REALTIME_TIMESTAMP),
    rtdate ALIAS fromUnixTimestamp64Micro(__REALTIME_TIMESTAMP)
)
ENGINE = MergeTree
ORDER BY __REALTIME_TIMESTAMP
SETTINGS index_granularity = 8192