---
title: "Growing the Underlying Disks for DRBD - move from smaller disks to bigger"
date: 2021-04-18T21:34:35+01:00
draft: false
---

# Moving from small disks to big disks in DRBD using logical volume manager.

How to move DRBD from smaller disks to bigger disks without needing a full resync. Disclaimer - Check with a DRBD expert before performing any kind of disk migration using DRBD. Take Backups. The idea behind this HOWTO is to perform the disk growth without a full DRBD resync.

## Environment

Assuming we have a DRBD cluster as follows:

```
resource drbd {
  protocol C;
  on c7_drbd1 {
    device /dev/drbd0;
    disk /dev/mapper/vg_main-mysql ;
    address 192.168.122.101:7788;
    meta-disk internal;
    }
  on c7_drbd2 {
    device /dev/drbd0;
    disk /dev/mapper/vg_main-mysql;
    address 192.168.122.102:7788;
    meta-disk internal;
    }
}
```

The logical volumes are setup as follows with root on /dev/vda, original migration from disk /dev/vdb 1GB and /dev/vdc being 2GB being the destination disk :

```
[root@c7_drbd1 ~]# fdisk -l |   egrep "^Disk /dev/vd"
Disk /dev/vda: 5368 MB, 5368709120 bytes, 10485760 sectors
Disk /dev/vdb: 1073 MB, 1073741824 bytes, 2097152 sectors
Disk /dev/vdc: 2147 MB, 2147483648 bytes, 4194304 sectors
```

The node c7_drbd2 is currently the primary DRBD device:

```
[root@c7_drbd2 ~]# drbdadm status
drbd role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:Established peer-disk:UpToDate
```

The logical volume layout is as follows:

```
[root@c7_drbd2 ~]# lvs
  LV    VG      Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos  -wi-ao----  <3.97g                                                    
  swap  centos  -wi-ao---- 512.00m                                                    
  mysql vg_main -wi-ao----  <1.00g                                                    
[root@c7_drbd2 ~]# pvs
  PV         VG      Fmt  Attr PSize  PFree 
  /dev/vda2  centos  lvm2 a--  <4.51g 40.00m
  /dev/vdb   vg_main lvm2 a--  <1.00g     0 
```

## Initial configuration - Disk is active on 02, passive on 01.

We will start the drbd as a primary on c7_drbd2 and secondary on c7_drbd1.

```
[root@c7_drbd2 ~]# drbdadm status
drbd role:Primary
  disk:UpToDate
  peer role:Secondary
    replication:Established peer-disk:UpToDate
```

```
[root@c7_drbd2 ~]# drbdadm primary drbd
[root@c7_drbd2 ~]# mount /dev/drbd0 /mnt
[root@c7_drbd2 ~]# df /mnt
Filesystem     1K-blocks  Used Available Use% Mounted on
/dev/drbd0       1040992 32996   1007996   4% /mnt
[root@c7_drbd2 ~]# ls /mnt
hello.txt
```

## Adjust disks on the secondary node

On c7_drbd1 add the 2GB disk /dev/vdc, migrate the data from vdb and detach it from the volume group:
```
[root@c7_drbd1 ~]# pvcreate /dev/vdc
  Physical volume "/dev/vdc" successfully created.
[root@c7_drbd1 ~]# vgextend vg_main /dev/vdc
  Volume group "vg_main" successfully extended
[root@c7_drbd1 ~]# pvmove /dev/vdb /dev/vdc
  /dev/vdb: Moved: 0.39%
  /dev/vdb: Moved: 100.00%
[root@c7_drbd1 ~]# vgreduce vg_main /dev/vdb
  Removed "/dev/vdb" from volume group "vg_main"
[root@c7_drbd1 ~]# pvremove /dev/vdb
  Labels on physical volume "/dev/vdb" successfully wiped.
```

Add the additional storage to the volume group:

```
[root@c7_drbd1 ~]# lvs
  LV    VG      Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos  -wi-ao----   <3.97g                                                    
  swap  centos  -wi-ao----  512.00m                                                    
  mysql vg_main -wi-ao---- 1020.00m                                                    
[root@c7_drbd1 ~]# vgs
  VG      #PV #LV #SN Attr   VSize  VFree 
  centos    1   2   0 wz--n- <4.51g 40.00m
  vg_main   1   1   0 wz--n- <2.00g  1.00g
[root@c7_drbd1 ~]# lvextend -l+100%FREE /dev/mapper/vg_main-mysql 
  Size of logical volume vg_main/mysql changed from 1020.00 MiB (255 extents) to <2.00 GiB (511 extents).
  Logical volume vg_main/mysql successfully resized.
```

## Failover from primary to the secondary

On c7_drbd2 fail the service over to c7_drbd1 so that the /dev/vdc disk can be added to c7_drbd1

```
[root@c7_drbd2 ~]# umount /mnt
[root@c7_drbd2 ~]# drbdadm secondary drbd
[root@c7_drbd2 ~]# drbdadm status
drbd role:Secondary
  disk:UpToDate
  peer role:Secondary
    replication:Established peer-disk:UpToDate
```

```
[root@c7_drbd1 ~]# drbdadm primary drbd
[root@c7_drbd1 ~]# mount /dev/drbd0 /mnt
[root@c7_drbd1 ~]# ls /mnt
hello.txt
```

## Resize disk on the newly secondary server.

DRBD is now up and running on the new disk, but this is still 1GB. We now need to grow the LVM on c7_drbd2

```
[root@c7_drbd2 ~]# pvcreate /dev/vdc
  Physical volume "/dev/vdc" successfully created.
[root@c7_drbd2 ~]# vgextend vg_main /dev/vdc
  Volume group "vg_main" successfully extended
[root@c7_drbd2 ~]# pvmove /dev/vdb /dev/vdc
  /dev/vdb: Moved: 0.39%
  /dev/vdb: Moved: 100.00%
[root@c7_drbd2 ~]# vgreduce /dev/vg_main /dev/vdb
  Removed "/dev/vdb" from volume group "vg_main"
[root@c7_drbd2 ~]# pvremove /dev/vdb
  Labels on physical volume "/dev/vdb" successfully wiped.
[root@c7_drbd2 ~]# lvextend -l+100%FREE /dev/mapper/vg_main-mysql 
  Size of logical volume vg_main/mysql changed from 1020.00 MiB (255 extents) to <2.00 GiB (511 extents).
  Logical volume vg_main/mysql successfully resized.
[root@c7_drbd1 ~]# vgs
  VG      #PV #LV #SN Attr   VSize  VFree 
  centos    1   2   0 wz--n- <4.51g 40.00m
  vg_main   1   1   0 wz--n- <2.00g     0 
[root@c7_drbd1 ~]# lvs
  LV    VG      Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos  -wi-ao----  <3.97g                                                    
  swap  centos  -wi-ao---- 512.00m                                                    
  mysql vg_main -wi-ao----  <2.00g                                                    
```

## DRBD Resize

Now we have both sides of the cluster at 2GB, we can resize the drbd device to 2GB on the primary.
```
[root@c7_drbd1 ~]#  drbdadm resize drbd
```
(On a more modern version of DRBD it is possible to use --assume-clean. This will prevent all the new storage from being scanned.)
```
[root@c7_drbd1 ~]# xfs_growfs /dev/drbd0 
meta-data=/dev/drbd0             isize=512    agcount=4, agsize=65276 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=261103, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=855, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 261103 to 523239
[root@c7_drbd1 ~]# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/drbd0      2.0G   33M  2.0G   2% /mnt
[root@c7_drbd1 ~]# ls /mnt
hello.txt
```

## Check both sides have been grown

First unmount on the primary node that has just been grown.

```
[root@c7_drbd1 ~]# umount /mnt
[root@c7_drbd1 ~]# drbdadm secondary drbd
[root@c7_drbd2 ~]# drbdadm primary drbd
```

Make the previously secondary node a primary and check.

```
[root@c7_drbd2 ~]# mount /dev/drbd0 /mnt
[root@c7_drbd2 ~]# ls /mnt
hello.txt
[root@c7_drbd2 ~]# df -h /mnt
Filesystem      Size  Used Avail Use% Mounted on
/dev/drbd0      2.0G   33M  2.0G   2% /mnt
```

The DRBD device has been grown and the original disks (/dev/vdb can be removed).
