+++
title = "EKS Kong Gateway Real IP via ProxyProtocol v2 and AWS Load Balancer Controller "
date = "2023-05-29"
author = "Tim Gibbon"
authorTwitter = "tommybobbins" #do not include @
cover = ""
tags = ["eks","k8s", "ingress","aws-load-balancer-controller","terraform","helm","values.yaml","kong","proxy","protocol","l4"]
keywords = ["eks","k8s", "ingress","aws-load-balancer-controller","terraform","helm","values.yaml","kong","proxy","protocol","l4"]
description = "Helm chart values.yaml for finding the Real IP in kong using ProxyProtocol with AWS Load Balancer Controller in L4"
showFullContent = false
+++

# Finding the Kong Gateway Real IP on EKS - a simple guide

It is difficult to determine the correct method to find the Real IPs for IP addresses behind a Kong Gateway controlled load balancer. The [documentation](https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/preserve-client-ip/) has an entry for both ExternalTrafficPolicy: Local, Proxy Protocol and a section applying to GKE/AKS and EKS. For example there is a sentence inside the ```ExternalTrafficPolicy: Local``` paragraph which reads "Please note that this is not supported by all of the public Cloud providers".

The document continues to detail Cloud-provider specific methods which include 3 ways inside EKS. It's not clear if these are in addition or replacements for the instructions provided earlier in the document. This results in a  large number of permutations which must be tried. I'm a big fan of worked examples and believe that any documentation should be bolstered with examples, in this case helm charts/configmap worked examples would benefit all engineers.

I'd love to see improvements to the documentation as the number of [forum posts](https://discuss.konghq.com/search?q=real%20ip) suggest that the documentaion is opaque.

# Method used

## Install AWS Load Balancer Controller

Install the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/) using the [instructions](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/installation/) or [AWS docs](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

Alternatively, we used a [terraform](https://gist.github.com/tommybobbins/d77aa9b5246775415a1d3c82b29bf91f#file-aws_load_balancer_controller-tf) implementation of this providing the name of the existing EKS cluster in two variables:

    ${var.project}-${var.env}


## Helm Chart for Kong Gateway using Proxy Protocol v2

After installing the AWS Load balancer controller, the helm chart for kong can be applied. This [helm chart](https://gist.github.com/tommybobbins/d77aa9b5246775415a1d3c82b29bf91f#file-kong-real-ip-values-yaml) will install kong with an NLB with Proxy Protocol v2 enabled and real IPs being passed through to the proxy container inside the kong pods.  After deploying the chart, real IPs should be visible by checking using kubectl:

    $ while true; do date; curl -s -I https://my-dns-name.example.com/myingress | egrep "200 OK"; date; sleep 1; done
    Mon 29 May 2023 10:22:09 BST
    HTTP/1.1 200 OK
    Mon 29 May 2023 10:22:09 BST
    Mon 29 May 2023 10:22:10 BST
    HTTP/1.1 200 OK
    Mon 29 May 2023 10:22:10 BST
    Mon 29 May 2023 10:22:11 BST
    HTTP/1.1 200 OK
    Mon 29 May 2023 10:22:11 BST
    $ kubectl logs kong-kong-123aaddcc7-c3326k -n kong -c proxy | grep "curl" 
    1.2.3.4 - - [29/May/2023:09:22:09 +0000] "HEAD /myingress HTTP/1.1" 200 0 "-" "curl/7.87.0"
    1.2.3.4 - - [29/May/2023:09:22:10 +0000] "HEAD /myingress HTTP/1.1" 200 0 "-" "curl/7.87.0"
    1.2.3.4 - - [29/May/2023:09:22:11 +0000] "HEAD /myingress HTTP/1.1" 200 0 "-" "curl/7.87.0"

## Suggestions for improvement

Please let me know if you have any suggestions for improvements.
