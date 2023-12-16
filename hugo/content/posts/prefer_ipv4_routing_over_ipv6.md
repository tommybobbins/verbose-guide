---
title: "Prefer IPv4 routing over IPv6"
date: 2020-04-07T20:13:18+01:00
draft: false
---

If you have an IPv4 and and IPv6 default gateway, but you wish for mail to be routed via the IPv4 network instead of the IPv4 then create a file /etc/gai.conf which contains:

``` 
# cat /etc/gai.conf <<EOF
label       ::1/128        0
label       ::/0           1
label       2002::/16      2
label       ::/96          3
label       ::ffff:0:0/96  4
precedence  ::1/128        50
precedence  ::/0           40
precedence  2002::/16      30
precedence  ::/96          20
precedence  ::ffff:0:0/96  100

EOF
```
