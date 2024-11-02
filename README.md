# Talos Kubernetes on Proxmox

Terraform module for creating a Kubernetes Cluster

* on Proxmox Virtual Environment
* using Talos OS
* and bootraping it with fluxcd


## Requirements

* [Proxmox Virtual Environment 8.2.5](<https://www.proxmox.com/en/>)
* [Terraform v1.9.8](<https://developer.hashicorp.com/terraform>)
* [Talos](<https://www.talos.dev/v1.8/introduction/getting-started/>)
* [Kubernetes](<https://kubernetes.io/docs/reference/kubectl/>)
* [fluxcd 2.4.0](<https://fluxcd.io/>)
 
Before running the module, you need to have an up and running Proxmox cluster configured for [Terraform](<https://registry.terraform.io/providers/bpg/proxmox/latest/docs>)


## Usage


```sh
cat main.tf
module "talos-k8s-cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "1.0.0-rc0"

  cluster = {
    name     = "cluster-demo"
    gateway  = "192.168.10.1"
    cidr     = 24
    endpoint = "192.168.10.210"
  }

  vms = {
    "k8s-cp-0" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.210"
      cpu            = 2
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-0"
    }
    "k8s-cp-1" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.211"
      cpu            = 2
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-1"
    }
    "k8s-cp-2" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.212"
      cpu            = 2
      ram_dedicated  = 4096
      os_disk_size   = 10
      data_disk_size = 10
      datastore_id   = "local-lvm"
      install_disk   = "/dev/sda"
      hostname       = "cp-2"
    }
  }

  proxmox = {
    endpoint     = "https://pve.domain"
    insecure     = true
    username     = "user"
    password     = "password"
    api_token    = "user@pve!terraform=secret"
  }

  github = {
    token      = "github_pat"
    org        = "username"
    repository = "repository"
  }

}
```

```sh
terraform init
...
terraform apply
...
module.talos-k8s-cluster.module.fluxcd[0].flux_bootstrap_git.this: Still creating... [50s elapsed]
module.talos-k8s-cluster.module.fluxcd[0].flux_bootstrap_git.this: Still creating... [1m0s elapsed]
module.talos-k8s-cluster.module.fluxcd[0].flux_bootstrap_git.this: Creation complete after 1m0s [id=flux-system]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
```

## Using cluster

Configuration files are store in output folder

```sh
$ ls -l output
total 8
-rw------- 1 devbox devbox 2295 Nov  2 17:23 kube-config.yaml
-rw------- 1 devbox devbox 1653 Nov  2 17:23 talos-config.yaml
```

### Kubernetes cluster

```sh
$ kubectl --kubeconfig output/kube-config.yaml get nodes
NAME   STATUS     ROLES           AGE   VERSION
cp-0   NotReady   control-plane   43s   v1.31.1
cp-1   NotReady   control-plane   43s   v1.31.1
cp-2   NotReady   control-plane   43s   v1.31.1
```

### Talos OS cluster

```sh
$ export CONTROL_PLANE_IP=192.168.10.210
$ export WORKER_IP=192.168.10.211
$ export TALOSCONFIG="output/talos-config.yaml"
$ talosctl config endpoint $CONTROL_PLANE_IP
$ talosctl config node $WORKER_IP
$ talosctl health
discovered nodes: ["192.168.10.210" "192.168.10.211" "192.168.10.212"]
waiting for etcd to be healthy: ...
waiting for etcd to be healthy: OK
waiting for etcd members to be consistent across nodes: ...
waiting for etcd members to be consistent across nodes: OK
waiting for etcd members to be control plane nodes: ...
waiting for etcd members to be control plane nodes: OK
waiting for apid to be ready: ...
waiting for apid to be ready: OK
waiting for all nodes memory sizes: ...
waiting for all nodes memory sizes: OK
waiting for all nodes disk sizes: ...
waiting for all nodes disk sizes: OK
waiting for no diagnostics: ...
waiting for no diagnostics: OK
waiting for kubelet to be healthy: ...
waiting for kubelet to be healthy: OK
waiting for all nodes to finish boot sequence: ...
waiting for all nodes to finish boot sequence: OK
waiting for all k8s nodes to report: ...
waiting for all k8s nodes to report: OK
waiting for all control plane static pods to be running: ...
waiting for all control plane static pods to be running: OK
waiting for all control plane components to be ready: ...
waiting for all control plane components to be ready: OK
waiting for all k8s nodes to report ready: ...
waiting for all k8s nodes to report ready: OK
waiting for kube-proxy to report ready: ...
waiting for kube-proxy to report ready: SKIP
waiting for coredns to report ready: ...
waiting for coredns to report ready: OK
waiting for all k8s nodes to report schedulable: ...
waiting for all k8s nodes to report schedulable: OK
```

### Flux bootstrap

```sh
$ flux --kubeconfig output/kube-config.yaml get kustomization -A
NAMESPACE  	NAME       	REVISION          	SUSPENDED	READY	MESSAGE
flux-system	flux-system	main@sha1:5902d505	False    	True 	Applied revision: main@sha1:5902d505
```
