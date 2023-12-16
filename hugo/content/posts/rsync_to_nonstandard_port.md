---
title: "Rsync via SSH to a port other than 22"
date: 2020-04-07T20:27:03+01:00
draft: false
---
# Rsync via SSH to a port which is not 22
```
rsync -avz -e "ssh -p 2020" user@remoteip:/path/to/files/ /local/path/
```

# Throttle rsync to prevent it from using too  much bandwidth
```
rsync -avz -e "ssh -p 2020" --numeric-ids --bwlimit=1.5m user@remoteip:/path/to/files/ /local/path/
```
