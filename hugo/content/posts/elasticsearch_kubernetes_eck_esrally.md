---
title: "Elasticsearch on Kubernetes benchmarking with esrally"
date: 2023-08-20T10:59:57+01:00
draft: false
---

# Elasticsearch on Kubernetes (ECK) worked example with terraform, GKE,  podman & esrally

I'm interested in running elasticsearch in kubernetes since an interview question I got asked: "What service would you not run in Kubernetes?". I thought about this at the time and answered elasticsearch, my reasons being the storage, replication and the upgrades. I figured it would be easier to run this on either bare metal or SaaS (opensearch). I hadn't heard about [ECK](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html) at the time. My answer was incorrect. Sorry Elastic.

I've been looking at the performance of ECK versus Opensearch for *reasons* and thought I would document some of the setup for running ECK and benchmarking it in GCP. The problem I found the hardest was how to use GCP as an Artifact repository because the login versus the docker push/podman push is Opaque. Needless to say if you get a status code 400 similar to the following:

```
registry login failed with 400 bad request
```

Check that you are actually using the correct path to the repository/image:tag - in the example below the repository would be benchmarking and the image would be esrally:0.1
```
 gcloud auth print-access-token --quiet | podman login -u oauth2accesstoken --password-stdin europe-west2-docker.pkg.dev
 podman build -t europe-west2-docker.pkg.dev/<project>/benchmarking/esrally:0.1 .
 podman push europe-west2-docker.pkg.dev/<project>/benchmarking/esrally:0.1
```

Full details of the build are in [Github](https://github.com/tommybobbins/upgraded-broccoli). Spoilers: ECK is fast ;)
