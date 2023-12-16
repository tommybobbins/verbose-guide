---
title: "Cold backup of QEMU/KVM images"
date: 2021-04-03T15:43:22Z
drafts: "false"
---

# Taking a cold backup of a QEMU or KVM VMs

If you need to take backups of qcow2 images, the following script is useful. QEMU uses two pieces of information, the xml file which makes up the metadata about the VM (CPU, memory, Network configuration) and the disk image itself which is a qcow2 image by defalt.

## Backup

```
#!/bin/bash
BACKUP_DIR="/tng_nfs/KVM_GOLD"
if ! [ -d ${BACKUP_DIR} ]
then
  echo "Backup directory $BACKUP_DIR does not exist"
fi
for SERVER in $(virsh list --all | awk '{print $2}' | egrep -v "Name" | egrep -v "^$")
do
  echo $SERVER
  virsh dumpxml ${SERVER} > ${BACKUP_DIR}/${SERVER}.xml
done

rsync -av /var/lib/libvirt/images/*.qcow2 ${BACKUP_DIR}
```

## Restoring

```
# gzip -c BACKUP_DIR/myimagename.qcow2.gz > /var/lib/libvirt/images/myimagename.qcow2
```
Define the backup XML:

```
# virsh define BACKUP_DIR/myimagename.xml
```
