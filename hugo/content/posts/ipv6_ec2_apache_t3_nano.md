---
title: "Ipv6 EC2 Apache t3.nano"
date: 2021-06-28T11:48:14+01:00
draft: true
---

# Creating AWS EC2 t3 nano with Apache using Terraform.

This code generating an EC2 instance with IPv6 networking with an SSH key copied from the source server. It uses SSM for local access, copying content from a local S3 bucket to populate the /data/sites directory which Apache then serves up. I've not published the Apache configuration files here.

https://github.com/tommybobbins/congenial-engine

I had some problems with t3.nano OOMs during startup, so the userdata adds a temporary 1GB swapfile in the userdata.sh at the start so that the userdata.sh completes.

```
dd if=/dev/zero of=/var/cache/swapfile bs=1M count=1024;
chmod 600 /var/cache/swapfile;
mkswap /var/cache/swapfile;
swapon /var/cache/swapfile;
free -m > /var/tmp/swap.txt
```
It then removes the swapfile at the end of the userdata, but leaving this in place would probably prevent OOMs.
