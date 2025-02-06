# Kubeadm Cluster Deployment Prerequisites

These are the requirements to ensure the environment/infrastructure is configured in preparation for deployment.

## System Requirements

- Software
  - OS: Ubuntu >=24.04
    - All OS based components are designed to use Ubuntu
- Hardware
  - Control-plane nodes
    - For high-availability (HA) considerations, see [NOTES](NOTES.md#high-availability-ha---things-to-consider)
    - Minimum requirements
      - CPU = 2-4
      - Memory = 6-8GB
      - Storage
        - /dev/sda = 100GB (SSD preferred): host OS operations
        - /dev/sdb = 150GB (SSD preferred): /var mount
          - see note below about /var/log/pods
      - Network = 1Gb (highly recommend >=10Gb)
  - Storage nodes
    - For HA considerations, see [NOTES](NOTES.md#storage-node-availability)
    - Rook-Ceph nodes have high pod "requests" levels.  This requires the storage nodes to have higher resource demands.  You could reduce the pod requests levels but, not recommended for any production deployment.
    - SSD = top performing storage available
    - HDD = mechanical disk or less performance storage
    - Minimum requirements
      - CPU = 10-14
      - Memory = 28-32GB
      - Storage
        - /dev/sda = 100GB (SSD preferred): host OS operations
        - /dev/sdb = 150GB (SSD preferred): /var mount
          - see note below about /var/log/pods
        - /dev/sdc = 100GB (SSD): Ceph storage \[RBD]
        - /dev/sdd = 150GB (HDD): Ceph storage \[RBD]
        - /dev/sde = 75GB (HDD): Ceph storage \[CephFS]
        - /dev/sdf = 10GB (SSD): Ceph .mgr meta

        - **Do not create partitions on devices sdc - sdf.  Ceph will capture/format these via the deployment**
        - **Very important the devices are mounted to the above locations as the Ceph cluster deployment manifest is configured to capture those specifically**
          - If you modify the device mount locations, then the Rook-Ceph cluster configuration needs to reflect the changes
      - Network = >=10Gb
  - Worker nodes
    - Notes
      - With this deployment, you can initially keep the worker nodes resources small and increase as demand grows
    - For high-availability (HA) considerations, see [NOTES](NOTES.md#impact-radius-for-worker-nodes)
      - Best practice is to have $N + 1$ for peak load measurements
    - Minimum requirements
      - CPU = 4-8
      - Memory = 8-12GB
      - Storage
        - /dev/sda = 100GB (SSD preferred): host OS operations
        - /dev/sdb = 150GB (SSD preferred): /var mount
          - see note below about /var/log/pods
      - Network = >=10Gb

### NOTE: Mount point for **/var**

Recommended putting /var onto a separate dedicated disk.  This allows for easier management when host systems get busy/full with pods.  The /var/log/pods is the default location for Kubernetes pod logs.  If you mount this directory onto a separate disk/device/partition from where /var is mounted, kubelet will no longer be able to monitor disk space usage.  Recommended to keep the entire /var together.

- Reference: [Cluster-Administration-Logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/#log-location-node)

## Kubernetes Aggregation Layer (Load-balancer)

To ensure you can always access the K8s API (residing on the control-plane nodes), you need to have a load-balancer (LB) mechanism external to the cluster.  The aggregation layer is also responsible for the control-plane to reach each others API and etcd.  

See [README](README.md#kubernetes-environment)

The LB needs to be configured prior to any K8s nodes being initialized.

This project is not intended to provide production level instructions on setting up a LB cluster.  There are configs on how to setup/configure a basic internal LB cluster, for the purpose of this deployment.

See [load-balancer-README](load-balancer/README.md)

## DNS Records (internal)

There are DNS records required prior to deployment.  These DNS records are for internal (not public facing) intra-node communications and ability to expose some UI/services externally from the K8s cluster.

See [README](README.md#kubernetes-environment)

If you change/deviate the DNS records, ensure the LB configurations reflect these changes

