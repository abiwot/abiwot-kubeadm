## Kubeadm Framework

These are the different components that make up this K8s deployment.  Below is a matrix to depict the versions of each component.  These versions have been tested (as much as one person can) to ensure they work together.

### Component Matrix Compatability

| Component | Method | App ver | Helm ver |
|:----------|:-------|:--------|:---------|
| containerd (CRI) | APT | 1.7.24 | n/a |
| kubelet | APT | 1.32.1-1.1 | n/a |
| kubeadm | APT | 1.32.1-1.1 |n/a |
| kubectl | APT | 1.32.1-1.1 | n/a |
| kubernetes | manifest | 1.32.1 | n/a |
| calico (CNI) | helm | 3.29.1 | 3.29.1 |
| helm | manifest | 3.17.0 | n/a |
| ingress-nginx (controller) | helm | 1.12.0 | 4.12.0 |
| rook-ceph | helm | 1.16.1 | 1.16.1 |
| kubernetes-csi-addon | manifest | 0.11.0 | n/a |
| k8-csi-external-snapshotter | manifest | 8.2.0 | n/a |
| kube-pormetheus-stack | helm | 0.79.2 | 68.4.3 |
| kubernetes-dashboard | helm | 7.10.4 | 7.10.4 |
| cert-manager | helm | 1.16.2 | 1.16.2 |

### Component Deployment Minimal

The main components that must be installed for minimal functionality are:

- kubeadm
- tigera-calico

If you are using this deployment for testing/learning, then these 2 components are the foundational base to learn from

### System Requirements

See [PREQUISITES](../PREREQUISITES.md#system-requirements)