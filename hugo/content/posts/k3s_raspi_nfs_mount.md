---
title: "K3S NFS Root howto"
date: 2021-02-07T22:28:45Z
draft: false
---

# Using K3S and Raspberry Pi Network booting (no SD Cards).

Due to NFS not supporting overlayfs in all kernels (yet), if you want to run K3S for NFS booting Pis, there is an install option you need to add INSTALL_K3S_EXEC="--snapshotter=native" to the install process. Here is a quick description of the problem and my setup in case this is of any use.

## Description of the problem. Installing K3S on Network boot Raspberry Pi 3/4

Booting the Raspberry Pi cmdline.txt options

```
root@k3s1:/boot# cat cmdline.txt
console=tty1 root=/dev/nfs nfsroot=192.168.1.23:/data2/raspbian_nfs/k3s1,vers=4.2 rw ip=192.168.1.201::192.168.1.254:255.255.255.0:k3s1:eth0:off rootwait elevator=deadline cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
```

The /etc/fstab shows the NFS mounts from our NFS server.

```
root@k3s1:/boot# cat /etc/fstab 
proc            /proc           proc    defaults          0       0
192.168.1.23:/data/tftpboot/generic/k3s1_64  /boot           nfs    defaults          0       2
192.168.1.23:/data2/raspbian_nfs/k3s1 / nfs defaults 0 0
```

We are making a 3 node cluster, k3s1 being the Master and k3s2 and k3s3 are the Worker nodes. The /etc/hosts entries:

```
192.168.1.201           k3s1
192.168.1.202           k3s2
192.168.1.203           k3s3
```

Installing k3s as per the documentation:
```
root@k3s1:/#  curl -sfL https://get.k3s.io | sh -
...
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service                                                                     
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.                                 
[INFO]  systemd: Starting k3s
...
Job for k3s.service failed because the control process exited with error code.                                                             
See "systemctl status k3s.service" and "journalctl -xe" for details.
```
The error is shown in the journalctl output - the upperfs does not support overlayfs.

```
root@k3s1:/#  journalctl -xe
...
Feb 07 21:00:01 k3s1 k3s[1099]: time="2021-02-07T21:00:01.354518540Z" level=error msg="Failed to retrieve agent config: \"overlayfs\" snapsh
Feb 07 21:00:06 k3s1 k3s[1099]: time="2021-02-07T21:00:06.365237219Z" level=info msg="Cluster-Http-Server 2021/02/07 21:00:06 http: TLS hand
Feb 07 21:00:06 k3s1 k3s[1099]: time="2021-02-07T21:00:06.449071336Z" level=info msg="certificate CN=k3s1 signed by CN=k3s-server-ca@1612731
Feb 07 21:00:06 k3s1 k3s[1099]: time="2021-02-07T21:00:06.466357951Z" level=info msg="certificate CN=system:node:k3s1,O=system:nodes signed 
Feb 07 21:00:06 k3s1 kernel: overlayfs: upper fs does not support tmpfile.
Feb 07 21:00:06 k3s1 kernel: overlayfs: upper fs does not support RENAME_WHITEOUT.
Feb 07 21:00:06 k3s1 kernel: overlayfs: upper fs does not support xattr, falling back to index=off and metacopy=off.
Feb 07 21:00:06 k3s1 kernel: overlayfs: upper fs missing required features.
```

Use the k3s-uninstall.sh script and then run the install with --snapshotter=native:

```
root@k3s1:/# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--snapshotter=native" sh -s - 
```

This will eventually work and kubectl get nodes will return the following

```
root@k3s1:~# kubectl get nodes
NAME   STATUS     ROLES    AGE     VERSION
k3s1   NotReady   <none>   2m18s   v1.20.2+k3s1
```

Find the K3S_TOKEN, ready to install the two workers:

```
root@k3s1:/# cat /var/lib/rancher/k3s/server/node-token                                                                    
K10a698d7cd06ec639f2dd6251ba9e28ca23bbffc6a8a32179a03e918fd8682e4ee::server:c2da2baa08f4fff0e7e85b58b3b21bbb 
```

On the Two worker nodes:

```
root@k3s2:~# curl -sfL https://get.k3s.io | K3S_URL=https://k3s1:6443 K3S_TOKEN=K10a698d7cd06ec639f2dd6251ba9e28ca23bbffc6a8a32179a03e918fd8682e4ee::server:c2da2baa08f4fff0e7e85b58b3b21bbb INSTALL_K3S_EXEC="--snapshotter=native" sh -   

root@k3s3:~# curl -sfL https://get.k3s.io | K3S_URL=https://k3s1:6443 K3S_TOKEN=K10a698d7cd06ec639f2dd6251ba9e28ca23bbffc6a8a32179a03e918fd8682e4ee::server:c2da2baa08f4fff0e7e85b58b3b21bbb INSTALL_K3S_EXEC="--snapshotter=native" sh -   
```

This now works:

```
root@k3s1:/etc/rancher/node# kubectl get nodes
NAME   STATUS   ROLES                  AGE   VERSION
k3s2   Ready    <none>                 10m   v1.20.2+k3s1
k3s3   Ready    <none>                 10m   v1.20.2+k3s1
k3s1   Ready    control-plane,master   28m   v1.20.2+k3s1
```

Running pods
```
root@k3s1:/etc/rancher/node# kubectl run bobbins --image=nginx
pod/bobbins created
root@k3s1:/etc/rancher/node# kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
bobbins   0/1     Pending   0          10s
root@k3s1:/etc/rancher/node# kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
bobbins   0/1     Pending   0          22s
root@k3s1:/etc/rancher/node# kubectl get pods
NAME      READY   STATUS              RESTARTS   AGE
bobbins   0/1     ContainerCreating   0          30s
```

Eventually, this works:

```
root@k3s1:/etc/rancher/node# kubectl get pods -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP          NODE   NOMINATED NODE   READINESS GATES                                         
bobbins   1/1     Running   0          3m50s   10.42.1.3   k3s2   <none>           <none>           
```
