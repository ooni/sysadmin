lvextend checklist:

- pvs; dd if=/dev/$disk bs=4096 count=16 | hexdump -C
- pvcreate /dev/$disk
- pvs; vgs
- vgextend hkgmetadb /dev/$disk
- vgs; lvs; df -h
- lvextend --resizefs -l 100%VG hkgmetadb/srv
- lvs; df -h
