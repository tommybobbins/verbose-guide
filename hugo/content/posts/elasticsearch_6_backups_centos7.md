---
title: "Elasticsearch 6 backups via snapshots for CentOS 7.0"
date: 2021-02-21T15:42:18Z
draft: false
---

# Elasticsearch 6.2 backups on CentOS 7/RHEL 7

I need to run Elasticsearch 6.2 and upgrade to Elasticsearch 7.11, making snapshots at each stage (prior to 6.8 upgrade and 7.11). In order to install ES 6.2.2, this was downloaded and built from a zipfile as the RPM format is incompatible with newer rpm releases. This method might not be a complete as installing a package from the repo, The problem I had was with the path.repo not being defined and this needed a particular format to get working. Here is the setup prior to upgrading.

## Problem

```
[root@es-node-01 elasticsearch]# curl -X PUT "es-node-01:9200/_snapshot/my_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch_backup/feb2021"
  }
}
'

Error
........
location [/var/lib/elasticsearch_backup] doesn't match any of the locations specified by path.repo because this setting is empty
```

This is because the path.repo needs adding to the elasticsearch.yml after a shared directory is created on all 3 nodes. I used NFS for this.

# Cluster layout

3 Node Elasticsearch cluster, with the following IPs and /etc/hosts entries:

```
[root@es-node-01 elasticsearch]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.122.106   centos8-3
192.168.122.101   es-node-01
192.168.122.102   es-node-02
```

Install the nfs-utils, open the firewalld ports if necessary and share the /var/lib/elasticsearch_backup via NFS:

```
[root@es-node-01 elasticsearch]# firewall -cmd --add-service nfs --permanent; firewall-cmd --reload
[root@es-node-01 elasticsearch]# ls -ld /var/lib/elasticsearch_backup/
drwxrwx---. 3 elasticsearch elasticsearch 21 Feb 21 15:19 /var/lib/elasticsearch_backup/

[root@es-node-01 elasticsearch]# cat /etc/exports
/var/lib/elasticsearch_backup 192.168.122.0/24(rw,no_root_squash)

[root@es-node-02 sysconfig]# mkdir /var/lib/elasticsearch_backup
[root@es-node-02 sysconfig]# mount es-node-01:/var/lib/elasticsearch_backup /var/lib/elasticsearch_backup

[root@es-node-03 sysconfig]# mkdir /var/lib/elasticsearch_backup
[root@es-node-03 sysconfig]# mount es-node-01:/var/lib/elasticsearch_backup /var/lib/elasticsearch_backup

```
You may wish to make these mounts permanent in the /etc/fstab. Ensure that the path.repo is defined in the /etc/elasticsearch/elasticsearch.yml. I had to doublequote this and leave inside square braces. YMMV.

```
[root@es-node-01 elasticsearch]# egrep -v "^#" /etc/elasticsearch/elasticsearch.yml
cluster.name: es-cluster1
node.name: es-node-01
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

path.repo: ["/var/lib/elasticsearch_backup"]
network.host: 192.168.122.101
discovery.zen.ping.unicast.hosts: ["es-node-01", "es-node-02", "es-node-03"]
discovery.zen.minimum_master_nodes: 2
node.master: true
node.data: true
```
Restart elasticsearch on all nodes, then register my_backup to be feb2021:

```
[root@es-node-01 elasticsearch]# curl -X PUT "es-node-01:9200/_snapshot/my_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch_backup/feb2021"
  }
}
'
{
  "acknowledged" : true
}
```
Perform the first snapshot into this diretory

```
[root@es-node-01 elasticsearch]# curl -X PUT "es-node-01:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true&pretty"

{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "Y0kOqvFmT2a5zaIv7gj5pw",
    "version_id" : 6020299,
    "version" : "6.2.2",
    "indices" : [
      "test_data"
    ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2021-02-21T15:56:47.203Z",
    "start_time_in_millis" : 1613923007203,
    "end_time" : "2021-02-21T15:56:47.644Z",
    "end_time_in_millis" : 1613923007644,
    "duration_in_millis" : 441,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    }
  }
}
```

Check that there is a reasonable amount of data in /var/lib/elasticsearch_backups:
```
[root@es-node-01 elasticsearch]# find /var/lib/elasticsearch_backup/feb2021/ | wc -l ; du -hs /var/lib/elasticsearch_backup
```

## Restore

In the event of a disaster during the upgrade, for example /var/lib/elasticsearch is destroyed, this can be moved to one side and /var/lib/elasticsearch recreated. Remember to reset the my_backup location:

```
[root@es-node-01 elasticsearch]# curl -X PUT "es-node-01:9200/_snapshot/my_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch_backup/feb2021"
  }
}
'
{
  "acknowledged" : true
}
```

```
[root@es-node-01 elasticsearch]# curl -X POST "es-node-01:9200/_snapshot/my_backup/snapshot_1/_restore?pretty"
```

## More information

[Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/modules-snapshots.html)
