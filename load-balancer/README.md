## K8s API Aggregation Layer (load-balancer)

As mentioned before, you need to have an external (from the K8s cluster perspective) that is responsible to be the aggregation layer for K8s inbound communications and ingress to exposed services.

This deployment will depict a cluster of NGINX load-balancers.  The configs provided are purely for convience and not an example of a production level NGINX LB deployment.

### Load-balancer Design Layout

See ![Diagram](../diagrams/kubeadm-infrastructure.drawio.svg)

### System Requirements

- OS
  - Ubuntu 24.04
- Resources (minimum)
  - CPU = 1-2
  - Memory = 2-4GB
  - Storage = 50-100GB
- DNS Records
  - See [Diagram](#load-balancer-design-layout).  The DNS Entries chart has the necessary records needed.

### Load-balancer Build Configuration

#### Package Installations

1. These tasks need to be completed on **BOTH** LBs
2. Run ```sudo apt update && sudo apt upgrade -y```
3. Install NGINX & keepalived packages
```shell
sudo apt install 
```
