---
title: "Debian Preseeding with apt-cacher-ng"
date: 2018-11-06T20:41:11Z
draft: False
---


Here is a working snippet of a preseed.cfg which works with apt-cacher-ng out of the box:

```
# Mirror settings
# If you select ftp, the mirror/country string does not need to be set.
#d-i mirror/protocol string ftp
#d-i mirror/country string GB
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.uk.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string http://192.168.1.23:3142/
```

# References:
https://www.debian.org/releases/stretch/example-preseed.txt
http://www.panticz.de/Install-APT-caching-proxy

You will need to change the IP of the apt-cacher-ng server to the correct IP/hostname - 192.168.1.23 in the above example.
