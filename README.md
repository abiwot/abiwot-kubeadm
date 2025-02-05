# Kubeadm - Kubernetes Cluster Framework Deployment

## Purpose

This project is designed to be a base framework around a kubeadm Kubernetes (K8s) cluster.  It is not designed to be the ultimate end goal for your K8s cluster but, a good solid framework to build on.

## Audience

You should be very familiar with Linux based administration.  You do not need to know any K8s to build the environment but, to better understand what you are deploying, it would help to understand some of the basics.

## TL;DR

If your intention is to just build the this K8s framework, then just copy/paste and you should end up with this K8s cluster.
If your intention is to gain a better understanding, advise after each section to do some research why certain commands were used.

## Notes:

- See [Prerequisites](prerequisites.md)
  - ensure K8s aggregation layer (load-balancer) is deployed/available
    - how to build a load-balancer is outside the scope of this document/project.  There are snippets of NGINX configs as a guideline for this deployment
  - ensure DNS records have been created
    - *Especially the API aggregation layer record!!!*
- See [NOTES](NOTES.md)
  - Covers background topics in a very high-level for additional knowledge or considerations while designing

## Kubernetes Environment

![Kubernetes Infrastructure](diagrams/kubeadm-infrastructure.drawio.svg)