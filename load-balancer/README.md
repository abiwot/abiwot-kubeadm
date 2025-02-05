# K8s API Aggregation Layer (load-balancer)

As mentioned before, you need to have an external (from the K8s cluster perspective) that is responsible to be the aggregation layer for K8s inbound communications and ingress to exposed services.

This deployment will depict a cluster of NGINX load-balancers.  The configs provided are purely for convience and not an example of a production level NGINX LB deployment.

## Load-balancer Design Layout

See ![Diagram](../diagrams/kubeadm-infrastructure.drawio.svg)

## System Requirements

- OS
  - Ubuntu 24.04
- Resources (minimum)
  - CPU = 1-2
  - Memory = 2-4GB
  - Storage = 50-100GB
- DNS Records
  - See [Diagram](#load-balancer-design-layout).  The DNS Entries chart has the necessary records needed.

## Load-balancer Build Configuration

### Package Installations

1. These tasks need to be completed on **BOTH** LBs
2. Run ```sudo apt update && sudo apt upgrade -y```
3. Install support packages

```shell
sudo apt install curl wget git -y
```

4. Install NGINX & keepalived packages
    1. At this time of writing this, application versions were:
        1. NGINX = 1.26.2
        2. Keepalived = 2.2.8

```shell
sudo apt install nginx keepalived -y
sudo apt mark-hold nginx keepalived
```

5. Git clone abiwot-kubeadm

```shell
mkdir -p $HOME/projects/k8s
cd $HOME/projects/k8s
git clone https://github.com/abiwot/abiwot-kubeadm.git
```

### Keepalived Configuration

**Ensure each LB node gets their corresponding keepalived config file**

1. Navigate to $HOME/projects/k8s/abiwot-kubeadm/load-balancer/keepalived/
2. Copy keepalived.conf to /etc/keepalived/
3. Set kernel parameters (see [Kernel Notes](#kernel-notes)) for details
4. Restart keepalived service

**Note**:

Your network interface name within the OS might be different.  If so, then you need to adjust the values in *keepalived.conf* & */etc/sysctl.conf*

```shell
cd $HOME/projects/k8s/abiwot-kubeadm/load-balancer/keepalived/<corresponding host folder>
sudo cp keepalived.conf /etc/keepalived/
```

```shell
sudo tee -a /etc/sysctl.conf <<EOF

# Keepalived VRRP Tuning
net.ipv4.ip_nonlocal_bind=1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.ens256.arp_ignore=1
net.ipv4.conf.ens256.arp_announce=2

EOF

```

```shell
sudo sysctl -p
sudo systemctl restart keepalived
sudo systemctl status keepalived
```

#### Kernel Notes

Brief explanation of what each of the kernel parameters are for.

|Setting|Purpose|
|:------|:------|
|*ip_nonlocal_bind=1*|Allows services to bind to the vIP immediately|
|*arp_ignore=1*|Prevents BACKUP stated system from responding to ARP for vIP|
|*arp_announce=2*|Ensures ARP announcements use the correct interface|

### NGINX Configurations

#### SSL Certificates for LB

You should have SSL certificates for your internal domain on the LBs for verification of traffic.  I would recommend using trusted (real) certificates.  
Just make sure you modify the K8s NGINX config file for those certificates.

For this deployment, you can create some self-signed certificates to be used, as-is.

1. Navigate to $HOME/projects/k8s/abiwot-kubeadm/load-balancer/tools/
2. Use the bash_create_ssl_selfsigned.sh script to create a full chain
3. Ensure those certs are in the correct locations for NGINX to use

```shell
cd $HOME/projects/k8s/abiwot-kubeadm/load-balancer/tools/
sudo chmod +x bash_create_ssl_selfsigned.sh
sudo ./bash_create_ssl_selfsigned.sh -d abiwot-lab.com -o /etc/pki/nginx/abiwot-lab.com/
ls -lah /etc/pki/nginx/abiwot-lab.com/
```

#### K8s NGINX Configuration

1. Make NGINX configuration folder structure
2. Copy root NGINX configuration file
3. Copy K8s NGINX configuration file

```shell
sudo mkdir -p /etc/nginx/conf.d/k8s/http
sudo mkdir -p /etc/nginx/conf.d/k8s/stream
cd $HOME/projects/k8s/abiwot-kubeadm/load-balancer/nginx
sudo cp nginx.conf /etc/nginx/
sudo cp https_k8clst100.conf /etc/nginx/conf.d/k8s/http/
sudo cp stream_k8clst100.conf /etc/nginx/conf.d/k8s/stream/
```

4. Test the NGINX configs
5. Apply the NGINX configs

```shell
sudo nginx -t
sudo nginx -s reload
```