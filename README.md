# Kubeadm - Kubernetes Cluster Framework Deployment

## Purpose

This project is designed as base framework (and teaching playground) for a kubeadm Kubernetes (K8s) cluster.  It is not designed to be the ultimate end goal for your K8s cluster but, a good solid framework to build on.

## Audience

You should be very familiar with Linux based administration.  Your knowledge level of K8s can be minimal to build this environment.

## TL;DR

If your intention is to just build the this K8s framework:

- then just copy/paste and you should end up with this K8s cluster

If your intention is to better understand:

- recommend after each section to do some research why certain commands were used.

## Notes:

- See [PREREQUISITES](PREREQUISITES.md)
  - ensure K8s aggregation layer (load-balancer) is deployed/available
    - how to build a load-balancer is outside the scope of this document/project.  There are snippets of NGINX configs as a guideline for this deployment
  - ensure DNS records have been created
    - *Especially the API aggregation layer record!!!*
- See [NOTES](NOTES.md)
  - Covers background topics in a very high-level for additional knowledge or considerations while designing

## Kubernetes Framework Environment

![Kubernetes Infrastructure](diagrams/kubeadm-infrastructure.drawio.svg)

![Service Exposuer](diagrams/kubeadm-infrastructure-service-exposure.drawio.svg)