---
title: "Raspberrypi_nfsboot"
date: 2020-05-30T17:57:12+01:00
draft: false
---

# Booting a Raspberry Pi from SD card, root filesystem is NFS

Other documentation has recommended the following line

```
dwc_otg.lpm_enable=0 console=tty1 root=/dev/nfs nfsroot=192.168.1.23:/data/raspbian_nfs/2020_06,tcp,rw,vers=3 ip=dhcp rootfstype=nfs elevator=deadline rootwait
```

This kernel panicked for me each time due to the rootfstype=nfs, so after some digging, I used:

```
 console=tty1 root=/dev/nfs nfsroot=192.168.1.23:/data/raspbian_nfs/2020_06,vers=3 rw ip=dhcp rootwait elevator=deadline
```

On the NFS server, /etc/exports contains:

```
/data/raspbian_nfs/2020_06  192.168.1.0/24(no_root_squash,rw,async,no_subtree_check,insecure)
```

/data/raspbian_nfs/2020_06 is populated using:

```
# mount 192.168.1.23:/data/raspbian_nfs/2020_06 /mnt
# rsync -Phax --numeric-ids / /mnt/data/raspbian_nfs/2020_06
```

The /etc/dhcp/dhcpd.conf is too complicated to document fully here, but this section is relevant:

```
subnet 192.168.1.0 netmask 255.255.255.0 {
  next-server 192.168.1.23;
  server-name "192.168.1.23";
  range 192.168.1.24 192.168.1.240;
  option broadcast-address 192.168.1.255;
  option subnet-mask 255.255.255.0;
  option routers 192.168.1.254;
}
```
I then flash an SD card as normal, copy the content across to the /data/raspbian_nfs/2020_06 directory, remove the boot from that directory.

The /etc/fstab on the Raspberry Pi and in /data/raspbian_nfs/2020_06/etc/fstab should look as follows:

```
proc            /proc           proc    defaults          0       0
LABEL=boot  /boot           vfat    defaults          0       2
192.168.1.23:/data/raspbian_nfs/2020_06 / nfs defaults 0 0
```

The partition /dev/mmcblk0p2 can then be removed from the SD card, using fdisk once the Pi boots
