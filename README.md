# Talos Kubernetes on Proxmox

Terraform module for creating a Kubernetes Cluster

* on Proxmox Virtual Environment
* using Talos OS
* and bootraping it with fluxcd

## Prerequisites

* [Proxmox Virtual Environment 9.1](<https://www.proxmox.com/en/>)
* [Terraform >= 1.10](<https://developer.hashicorp.com/terraform>)
* [Talos v1.12](<https://www.talos.dev/v1.9/introduction/getting-started/>)
* [Kubernetes](<https://kubernetes.io/docs/reference/kubectl/>)
* [fluxcd 2.6.0](<https://fluxcd.io/>)

Before running the module, you need to have an up and running Proxmox cluster configured for [Terraform](<https://registry.terraform.io/providers/bpg/proxmox/latest/docs>)

## Usage

```sh
cat main.tf
module "talos_k8s_cluster" {
  source  = "vdupain/talos-k8s-cluster/proxmox"
  version = "2.0.0"

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
      memory_dedicated  = 4096
      system_disk_size   = 10
      user_disk_size = 10
      datastore_id   = "local-lvm"
    }
    "k8s-cp-1" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.211"
      cpu            = 2
      memory_dedicated  = 4096
      system_disk_size   = 10
      user_disk_size = 10
      datastore_id   = "local-lvm"
    }
    "k8s-cp-2" = {
      host_node      = "pve1"
      machine_type   = "controlplane"
      ip             = "192.168.10.212"
      cpu            = 2
      memory_dedicated  = 4096
      system_disk_size   = 10
      user_disk_size = 10
      datastore_id   = "local-lvm"
    }
  }

  proxmox = {
    endpoint     = "https://pve.domain"
    insecure     = true
    username     = "user"
    password     = "password"
    api_token    = "user@pve!terraform=secret"
  }

  gitops = {
    repository   = "https://github.com/vdupain/gitops.git"
    token        = "github_pat"
    cluster_name = "my-cluster"
  }

}
```

```sh
# with Terraform
terraform init
terraform apply

# with OpenTofu
tofu init
tofu apply
...
module.talos_k8s_cluster.module.fluxcd[0].flux_bootstrap_git.this: Still creating... [50s elapsed]
module.talos_k8s_cluster.module.fluxcd[0].flux_bootstrap_git.this: Still creating... [1m0s elapsed]
module.talos_k8s_cluster.module.fluxcd[0].flux_bootstrap_git.this: Creation complete after 1m0s [id=flux-system]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
```

> **Note:** Terraform native tests (`.tftest.hcl`) must be run with **Terraform >= 1.10** only — OpenTofu has known incompatibilities with mock providers.

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

## Architecture

The module is composed of four sub-modules executed in order:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Root Module                              │
│                                                                 │
│  ┌──────────────────┐       ┌──────────────────────────────┐   │
│  │  vms_proxmox     │──────▶│       talos_k8s              │   │
│  │  (required)      │       │       (required)             │   │
│  │                  │       │                              │   │
│  │ • Download Talos │       │ • Generate machine secrets   │   │
│  │   image          │       │ • Apply Talos config to each │   │
│  │ • Create VMs     │       │   controlplane / worker node │   │
│  │ • PCI mappings   │       │ • Bootstrap etcd             │   │
│  │   (optional)     │       │ • Retrieve kubeconfig        │   │
│  └──────────────────┘       └──────────────┬───────────────┘   │
│                                            │                   │
│                          ┌─────────────────┴──────────────┐    │
│                          │                                │    │
│                ┌─────────▼────────┐          ┌────────────▼──┐ │
│                │  gitops_k8s      │          │  init_k8s     │ │
│                │  (optional)      │          │  (optional)   │ │
│                │                  │          │               │ │
│                │ • FluxCD         │          │ • Sealed      │ │
│                │   bootstrap on   │          │   Secrets     │ │
│                │   git repository │          │   certificate │ │
│                └──────────────────┘          └───────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

| Module | Required | Description |
|--------|:--------:|-------------|
| `vms_proxmox` | yes | Downloads Talos OS image and provisions VMs on Proxmox |
| `talos_k8s` | yes | Configures Talos OS, bootstraps Kubernetes, retrieves kubeconfig |
| `gitops_k8s` | no | Bootstraps FluxCD on a git repository (enabled when `gitops != null`) |
| `init_k8s` | no | Installs Sealed Secrets certificate in the cluster (enabled when `certificate != null`) |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | ~> 1.7 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitops_k8s"></a> [gitops\_k8s](#module\_gitops\_k8s) | ./modules/gitops_k8s | n/a |
| <a name="module_init_k8s"></a> [init\_k8s](#module\_init\_k8s) | ./modules/init_k8s | n/a |
| <a name="module_talos_k8s"></a> [talos\_k8s](#module\_talos\_k8s) | ./modules/talos_k8s | n/a |
| <a name="module_vms_proxmox"></a> [vms\_proxmox](#module\_vms\_proxmox) | ./modules/vms_proxmox | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.kube_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kube_config_home](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.talos_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.talos_config_home](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_extensions"></a> [additional\_extensions](#input\_additional\_extensions) | Additional Talos system extensions to include in all images (added to base + GPU-specific extensions defined in modules/vms\_proxmox/schematics/) | `list(string)` | `[]` | no |
| <a name="input_certificate"></a> [certificate](#input\_certificate) | Certificate for k8s sealed-secrets | <pre>object({<br/>    cert = string<br/>    key  = string<br/>  })</pre> | `null` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name                               = string<br/>    talos_version                      = optional(string, "v1.12.4")<br/>    network_dhcp                       = optional(bool, false)<br/>    gateway                            = optional(string)<br/>    dns_domain                         = optional(string)<br/>    dns_servers                        = optional(list(string))<br/>    cidr                               = optional(number)<br/>    vlan_id                            = optional(number, null)<br/>    network_device_bridge              = optional(string, "vmbr0")<br/>    endpoint                           = optional(string)<br/>    allow_scheduling_on_control_planes = optional(bool, true)<br/>    vip_ip                             = optional(string)<br/>    vip_interface                      = optional(string, "eth0")<br/>  })</pre> | n/a | yes |
| <a name="input_gitops"></a> [gitops](#input\_gitops) | GitOps configuration | <pre>object({<br/>    repository   = string<br/>    token        = string<br/>    cluster_name = string<br/>  })</pre> | `null` | no |
| <a name="input_pci"></a> [pci](#input\_pci) | Mapping PCI configuration | <pre>map(object({<br/>    name             = string<br/>    id               = string<br/>    iommu_group      = number<br/>    node             = string<br/>    path             = string<br/>    subsystem_id     = string<br/>    mediated_devices = optional(bool, false)<br/>  }))</pre> | `null` | no |
| <a name="input_proxmox"></a> [proxmox](#input\_proxmox) | Proxmox configuration | <pre>object({<br/>    endpoint           = optional(string)<br/>    insecure           = optional(bool)<br/>    username           = optional(string)<br/>    password           = optional(string)<br/>    api_token          = optional(string)<br/>    ssh_agent          = optional(string, false)<br/>    random_vm_ids      = optional(string, false)<br/>    random_vm_id_start = optional(number, 1000)<br/>    random_vm_id_end   = optional(number, 2000)<br/>  })</pre> | n/a | yes |
| <a name="input_vms"></a> [vms](#input\_vms) | VMs configuration | <pre>map(object({<br/>    host_node        = string<br/>    machine_type     = string<br/>    datastore_id     = optional(string, "local-lvm")<br/>    ip               = optional(string)<br/>    cpu              = number<br/>    memory_dedicated = number<br/>    system_disk_size = optional(number, 10)<br/>    user_disk_size   = optional(number, 20)<br/>    install_disk     = optional(string, "/dev/sda")<br/>    disk_file_format = optional(string, "raw")<br/>    gpu              = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Retrieves the name for a k8s Talos cluster |
| <a name="output_config_ipv4_addresses"></a> [config\_ipv4\_addresses](#output\_config\_ipv4\_addresses) | Retrieves VM names with IPv4 address for a k8s Talos cluster |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Retrieves the kubeconfig for a k8s Talos cluster |
| <a name="output_qemu_ipv4_addresses"></a> [qemu\_ipv4\_addresses](#output\_qemu\_ipv4\_addresses) | Retrieves VM names with IPv4 address for a k8s Talos cluster |
| <a name="output_talos_config"></a> [talos\_config](#output\_talos\_config) | Retrieves the talosconfig for a k8s Talos cluster |
| <a name="output_vm_ipv4_address_vms"></a> [vm\_ipv4\_address\_vms](#output\_vm\_ipv4\_address\_vms) | Retrieves IPv4 address for a k8s Talos cluster |
<!-- END_TF_DOCS -->