# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform module for deploying Kubernetes clusters on Proxmox Virtual Environment using Talos OS and optionally bootstrapping them with FluxCD for GitOps. The module is published to the Terraform Registry as `vdupain/talos-k8s-cluster/proxmox`.

## Architecture

The module has a four-stage pipeline architecture:

1. **vms_proxmox** (`modules/vms_proxmox/`): Creates VMs on Proxmox
   - Downloads Talos images from the Talos Factory based on schematics (supports both standard and NVIDIA GPU variants)
   - Creates VMs with EFI, boot disk, and data disk
   - Supports GPU passthrough via PCI mapping
   - Supports both static IP and DHCP network configurations
   - If DHCP is enabled, includes a 60-second wait after VM creation

2. **talos_k8s** (`modules/talos_k8s/`): Configures Talos and bootstraps Kubernetes
   - Generates machine secrets and configurations for control plane and worker nodes
   - Applies configuration patches from templates (`config/control-plane.yaml.tmpl`, `config/worker.yaml.tmpl`)
   - Bootstraps the first control plane node
   - Generates kubeconfig and talosconfig
   - Control plane configs include Cilium CNI configuration, ZFS setup, and Falco patches
   - Worker GPU nodes receive additional patches for NVIDIA runtime

3. **init_k8s** (`modules/init_k8s/`): Initializes Kubernetes cluster (optional, only if certificate is provided)
   - Sets up sealed-secrets with provided certificates

4. **gitops_k8s** (`modules/gitops_k8s/`): Bootstraps FluxCD (optional, only if gitops config is provided)
   - Uses the Flux Terraform provider to bootstrap Git-based GitOps

Dependencies flow sequentially: vms_proxmox → talos_k8s → init_k8s → gitops_k8s

## Common Commands

### Development and Testing

```bash
# Initialize Terraform (or use OpenTofu)
terraform init

# Format code recursively
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Working with Examples

Each example in `examples/` demonstrates different configurations:
- `0-demo-cluster`: Basic 3-node control plane cluster
- `1-gpu-cluster`: Cluster with GPU worker nodes
- `2-bare-cluster`: Minimal cluster without GitOps
- `3-mini-cluster`: Smaller resource configuration
- `4-dhcp-cluster`: Using DHCP instead of static IPs
- `5-vars-from-envrc`: Configuration using environment variables

To test an example:
```bash
cd examples/0-demo-cluster
terraform init
terraform plan
```

### Documentation

```bash
# Update README.md with terraform-docs (used by prepare-release.sh)
terraform-docs markdown table --recursive --recursive-path examples --output-file README.md --output-mode inject .
terraform-docs markdown table --recursive --output-file README.md --output-mode inject .
```

### Interacting with Created Clusters

After applying, configuration files are stored in the `output/` directory:

```bash
# Access Kubernetes cluster
kubectl --kubeconfig output/kube-config.yaml get nodes

# Access Talos cluster
export TALOSCONFIG="output/talos-config.yaml"
talosctl config endpoint <CONTROL_PLANE_IP>
talosctl config node <WORKER_IP>
talosctl health

# Check Flux GitOps status (if enabled)
flux --kubeconfig output/kube-config.yaml get kustomization -A
```

## Configuration Files

### Variable Files
- Use `.tfvars.template` files as starting points for configuration
- `provider.auto.tfvars.template`: Proxmox provider settings
- `variables.auto.tfvars.template`: Cluster and VM configurations
- `github-actions.tfvars.template`: Template for CI/CD use with environment variable substitution

### Talos Configuration
- `modules/vms_proxmox/schematics/base.yaml`: Base Talos extensions (qemu-guest-agent, zfs)
- `modules/vms_proxmox/schematics/nvidia.yaml`: NVIDIA GPU extensions
- `modules/vms_proxmox/schematics/intel.yaml`: Intel GPU extensions
- Schematics are automatically merged based on GPU type detection
- Configuration patches in `modules/talos_k8s/config/` are templatefiles that receive runtime parameters

## Key Variables

- `cluster`: Defines cluster name, network settings (gateway, CIDR, VLAN), Talos version, endpoint, VIP, and scheduling options
- `vms`: Map of VM configurations including machine_type ("controlplane" or "worker"), resources, and optional GPU mapping
- `additional_extensions`: Additional Talos extensions to add to all nodes (merged with base and GPU-specific extensions)
- `proxmox`: Authentication and connection settings for Proxmox VE
- `gitops`: Optional FluxCD bootstrap configuration
- `certificate`: Optional certificate/key pair for sealed-secrets
- `pci`: Optional PCI device mappings for GPU passthrough

## Provider Versions

The module requires:
- Terraform/OpenTofu >= 1.8
- Proxmox provider (bpg/proxmox) configured in submodules
- Talos provider configured in submodules
- Kubernetes provider >= 3.0.1
- Flux provider >= 1.7.6
- Local provider >= 2.6.1

Current versions referenced in README prerequisites:
- Proxmox VE 9.1
- OpenTofu v1.9.0
- Talos v1.12 (default in code: v1.12.1)
- FluxCD 2.6.0

## CI/CD

GitHub Actions workflow (`.github/workflows/terraform.yaml`) runs on push to main and PRs:
- Runs on self-hosted runner
- Uses environment variables from GitHub secrets for Proxmox authentication
- Performs init, format check, validate, and plan
- Apply step is commented out (manual apply required)
- Creates `terraform.tfvars` from template using `envsubst`

## Network Configuration Modes

The module supports two network modes:
1. **Static IP**: Requires `gateway`, `cidr`, and `ip` per VM
2. **DHCP**: Set `cluster.network_dhcp = true`, omit static IP settings
   - A 60-second wait period is added after VM creation to allow DHCP assignment

## Cluster Endpoint Configuration

The Kubernetes cluster endpoint is automatically determined using the following priority order:

1. **VIP (Virtual IP)** - Highest Priority
   - If `cluster.vip_ip` is configured, it becomes the cluster endpoint
   - Recommended for HA control plane setups with multiple control plane nodes
   - Automatically configures Talos VIP using kube-vip for high availability
   - Example: `vip_ip = "192.168.1.100"`

2. **Explicit Endpoint** - Medium Priority
   - If `cluster.endpoint` is explicitly set (and VIP is not configured)
   - Useful when using external load balancers or DNS entries
   - Example: `endpoint = "k8s.example.com"` or `endpoint = "192.168.1.200"`

3. **First Control Plane IP** - Default/Fallback
   - If neither VIP nor explicit endpoint is configured
   - Uses the IP address of the first control plane node
   - Suitable for single control plane or development clusters

**Configuration Examples:**

```hcl
# HA cluster with VIP (recommended for production)
cluster = {
  name       = "prod-cluster"
  vip_ip     = "192.168.1.100"  # Cluster endpoint will be 192.168.1.100
  vip_interface = "eth0"
  # ... other settings
}

# Cluster with explicit endpoint (external load balancer)
cluster = {
  name     = "prod-cluster"
  endpoint = "k8s-lb.example.com"  # Cluster endpoint will be k8s-lb.example.com
  # ... other settings
}

# Simple cluster (development/testing)
cluster = {
  name = "dev-cluster"
  # endpoint will default to first control plane IP
}
```

**Note:** The VIP configuration takes precedence over all other settings. If you configure both `vip_ip` and `endpoint`, the VIP will be used as the cluster endpoint.

## GPU Support

The module supports NVIDIA and Intel GPUs with automatic detection and configuration:

### GPU Type Detection
- GPU type is auto-detected from the `gpu` field name (case-insensitive)
- NVIDIA GPUs: Any name containing "nvidia" (e.g., "nvidia-3090", "NVIDIA-A100")
- Intel GPUs: Any name containing "intel" (e.g., "intel-arc-a770", "INTEL-GPU")
- Unknown GPU types fallback to base configuration

### Automatic Extension Merging
The module automatically merges extensions based on GPU type:
1. **Base extensions** (from `schematics/base.yaml`): qemu-guest-agent, zfs
2. **GPU-specific extensions** (from `schematics/nvidia.yaml` or `schematics/intel.yaml`):
   - NVIDIA: nvidia-container-toolkit-production, nonfree-kmod-nvidia-production
   - Intel: intel-gpu-firmware
3. **Additional extensions** (from `additional_extensions` variable): User-defined

### Configuration
For worker nodes with GPU:
- Set `gpu` parameter to the PCI mapping name
- Module automatically builds appropriate Talos image with merged extensions
- Applies GPU-specific configuration patches including runtime class
- Requires `pci` variable with PCI device mappings

### Customizing GPU Extensions
To modify GPU-specific extensions, edit the schematic files:
- `modules/vms_proxmox/schematics/base.yaml` - Base extensions for all nodes
- `modules/vms_proxmox/schematics/nvidia.yaml` - NVIDIA-specific extensions
- `modules/vms_proxmox/schematics/intel.yaml` - Intel-specific extensions

SecureBoot is always enabled with well-known certificates included.

## Output Structure

The module creates:
- `output/kube-config.yaml`: Kubernetes cluster access
- `output/talos-config.yaml`: Talos OS cluster management
- Optional copies to `~/.kube/` and `~/.talos/` directories
