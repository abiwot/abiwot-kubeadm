# Notes

This document is to touch on some subjects that might require some clarifications and/or more in-depth explanations.  Keeping them out of the build document as not to add/cause any confusion.

## Table of Contents

- [Control-plane Architecture](#control-plane-architecture)
- [High Availability (HA) - Things to Consider](#high-availability-ha---things-to-consider)
  - [Control-plane Availability](#control-plane-availability)
  - [Storage Node Availability](#storage-node-availability)
  - [Impact Radius for Worker Nodes](#impact-radius-for-worker-nodes)

## Control-plane Architecture

This deployment is using a "stacked" control-plane model.  Basically each control-plane node consists of:

- kube-api pod
- kube-scheduler pod
- kube-controller-manager pod
- kube-proxy pod
- etcd pod

The etcd is as a clustered key-value database that contains the configs and state of the cluster.

## High Availability (HA) - Things to Consider

One of the main points of a containerized environment is its ability to suffer outages (planned and unplanned) and keep functioning.  Lets address some of the topics to be aware of and carefully plan for.

### Control-plane Availability

The control-plane nodes are essentially the brains of the cluster.  This is where all the decision making occurs to deploy, manage, secure, schedule, and recover.  In your environment, you have to ensure the control-plane nodes are operational and have a "quorum" for the etcd database (keeps all the configs & state of your cluster).
"etcd" uses Raft consensus to ensure quorum.  Raft works best with odd number deployments (3,5,7).  The formula used for quorum is:

$N/2 + 1$

- 3 x control-plane nodes => can suffer 1 node lost
- 5 x control-plane nodes => can suffer 2 nodes lost
- 7 x control-plane nodes => can suffer 3 nodes lost

Once you lose etcd quorum, that database goes into a read-only mode, not allowing any changes to your cluster to occur until quorum is restored.

#### Availability Zones (AZ) / Fault Domains (FD)

When planning your control-plane deployment, make sure you understand the impact to the K8s cluster if/when you lose an AZ or FD.

- etcd quorum
  - If you split odd number of control-plane nodes across even number of AZ/FD; then you create a HA imbalance.
    - zone1: 1 node
    - zone2: 2 nodes
    - when zone1 fails = quorum exists and etcd is operational
    - when zone2 fails != quorum fails and etcd is read-only

#### Control-plane I/O (throughput performance)

The control-plane I/O (throughput performance = how many requests/actions per second) is another consideration, especially for medium to large size clusters.  A big concern for medium - large size clusters is the amount of requests being pushed to the API and etcd pods.  If these pods start to suffer from resource starvation, then the performance will be felt in many actions across the entire cluster.
This is important when running in a degraded control-plane state (nodes are down for maintenance or outage).  With less nodes to process the I/O demand, you can overwhelm the management side.

### Storage Node Availability

This deployment uses Rook-Ceph (Rook is the orchestrator.  Ceph is the distributed storage.).  For the RadosBlockDevices (RBD), they are setup to hold 3 replicas.  This means each RBD pool has 3 copies of your data.  So you can lose 1 node and still have your data safe.
You want to keep this in mind when designing your storage node placement within AZ/FD.  Very similar logic as to the control-plane node placement.

Would recommend 4+ storage nodes for any production deployment, from a safety point of view.  You may need to consider more nodes based on workload I/O.

### Impact Radius for Worker Nodes

Consider the resource size (cpu & memory) of your K8s worker nodes.  You might be tempted to build very large nodes to hold 100+ pods each.  Keep in mind when you have to drain that node for maintenance or when nodes fail; the impact might be detrimental to the application's availability running on those 100+ pods.  Better to keep the impact of a node loss to minimal impact.  The sizes will depend on your application fault tolerance, infrastructure, K8s recovery (replicasets, statefulsets), K8s admins, etc...
As of K8s v1.32, the [recommendations](https://kubernetes.io/docs/setup/best-practices/cluster-large/) are:

- <= 110 pods per node
- <= 5K nodes per cluster
- < 150K total pods
