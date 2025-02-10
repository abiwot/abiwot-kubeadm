# Ceph Grafana Dashboards

This document is a reference only on how the configmap dashboard files within are created.

There are some basic dashboards to be installed (Ceph-cluster, Ceph-osd, & Ceph-pools) from the Grafana labs repository.  These are maintained by the Rook community.  These install instructions will use the sidecar method by creating configmaps within K8s for Grafana to automatically pickup.

The commands below will create 2 files (JSON & YAML).  The JSON can be used to import into Grafana via UI.  The YAML is used to create a configmap for sidecar implementation.

## Ceph Cluster Dashboard - 2842

```shell
curl -s https://grafana.com/api/dashboards/2842/revisions/18/download -o cephcluster-dashboard.json && kubectl create configmap cm-dashboard-cephcluster-2842 --from-file=./cephcluster-dashboard.json -n monitoring --dry-run=client -o yaml | kubectl label -f - --dry-run=client -o yaml --local grafana_dashboard=1 >> cm-dashboard-cephcluster-2842.yaml

kubectl apply -f cm-dashboard-cephcluster-2842.yaml
```

## Ceph OSD Dashboard - 5336

```shell
curl -s https://grafana.com/api/dashboards/5336/revisions/9/download -o cephosd-dashboard.json && kubectl create configmap cm-dashboard-cephosd-5336 --from-file=./cephosd-dashboard.json -n monitoring --dry-run=client -o yaml | kubectl label -f - --dry-run=client -o yaml --local grafana_dashboard=1 >> cm-dashboard-cephosd-5336.yaml

kubectl apply -f cm-dashboard-cephosd-5336.yaml
```

## Ceph Pools Dashboard - 5342

```shell
curl -s https://grafana.com/api/dashboards/5342/revisions/9/download -o cephpools-dashboard.json && kubectl create configmap cm-dashboard-cephpools-5342 --from-file=./cephpools-dashboard.json -n monitoring --dry-run=client -o yaml | kubectl label -f - --dry-run=client -o yaml --local grafana_dashboard=1 >> cm-dashboard-cephpools-5342.yaml

kubectl apply -f cm-dashboard-cephpools-5342.yaml
```