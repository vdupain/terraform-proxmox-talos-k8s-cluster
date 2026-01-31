# Terraform Examples

This directory contains various examples demonstrating different configurations of the Talos Kubernetes cluster on Proxmox.

## Quick Reference

| Example | Description | Control Planes | Workers | VIP | GPU | GitOps | Use Case |
|---------|-------------|----------------|---------|-----|-----|--------|----------|
| [0-demo-cluster](0-demo-cluster/) | Basic 3-node cluster with GitOps | 3 | 0 | No | No | Yes | Development with GitOps |
| [1-gpu-cluster](1-gpu-cluster/) | Cluster with NVIDIA GPU support | 3 | 1 | No | NVIDIA | Yes | GPU workloads |
| [2-bare-cluster](2-bare-cluster/) | Minimal cluster without GitOps | 3 | 0 | No | No | No | Simple setup |
| [3-mini-cluster](3-mini-cluster/) | Small cluster with workers | 1 | 2 | No | No | No | Resource-constrained |
| [4-dhcp-cluster](4-dhcp-cluster/) | Cluster using DHCP | 1 | 2 | No | No | No | DHCP networks |
| [5-vars-from-envrc](5-vars-from-envrc/) | Environment variable config | 1 | 1 | No | No | No | CI/CD, automation |
| [6-ha-vip-cluster](6-ha-vip-cluster/) | **HA cluster with VIP** | 3 | 3 | **Yes** | No | No | **Production HA** |

## Examples Overview

### 0-demo-cluster
A complete 3-node control plane cluster with FluxCD GitOps integration. Allows scheduling on control planes (no dedicated workers). Good for development environments where you want GitOps automation.

**Key Features:**
- 3 control plane nodes
- GitOps with FluxCD
- Workloads run on control plane

### 1-gpu-cluster
Demonstrates GPU passthrough with NVIDIA GPUs. Shows how to configure PCI devices and GPU-enabled workers. GPU extensions are automatically applied based on GPU type detection.

**Key Features:**
- NVIDIA GPU support
- Automatic GPU extension merging
- PCI passthrough configuration
- Comment showing how to add additional extensions

### 2-bare-cluster
Minimal cluster without GitOps. Uses the published module version. Simplest configuration for testing.

**Key Features:**
- No GitOps
- Published module usage
- Minimal dependencies

### 3-mini-cluster
Small cluster with 1 control plane and 2 workers. Resource-efficient for testing or small environments.

**Key Features:**
- Single control plane
- Dedicated workers
- Smaller resource footprint

### 4-dhcp-cluster
Uses DHCP for IP assignment instead of static IPs. Demonstrates network_dhcp mode with automatic endpoint detection.

**Key Features:**
- DHCP networking
- Automatic IP assignment
- 60-second wait for DHCP

### 5-vars-from-envrc
Configuration using environment variables. Useful for CI/CD pipelines or automated deployments.

**Key Features:**
- Environment variable configuration
- `.envrc` support
- Automation-friendly

### 6-ha-vip-cluster ⭐ NEW
**Production-ready HA cluster with Virtual IP (VIP) for high availability.** Demonstrates best practices for production Kubernetes deployments.

**Key Features:**
- ✅ 3 control plane nodes (HA with quorum)
- ✅ 3 worker nodes (dedicated)
- ✅ VIP (192.168.10.200) for automatic failover
- ✅ kube-vip managed VIP
- ✅ No single point of failure
- ✅ Production best practices

**Architecture:**
```
VIP: 192.168.10.200 (kube-vip)
├── Control Plane 1: 192.168.10.210
├── Control Plane 2: 192.168.10.211
└── Control Plane 3: 192.168.10.212

Workers:
├── Worker 1: 192.168.10.220
├── Worker 2: 192.168.10.221
└── Worker 3: 192.168.10.222
```

## Extension System

All examples use the new schematic-based extension system:

**Base Extensions** (all nodes):
- `siderolabs/qemu-guest-agent`
- `siderolabs/zfs`

**GPU Extensions** (automatic):
- NVIDIA GPUs: `nvidia-container-toolkit-production`, `nonfree-kmod-nvidia-production`
- Intel GPUs: `intel-gpu-firmware`

**Additional Extensions** (optional):
```hcl
additional_extensions = [
  "siderolabs/intel-ucode",
  "siderolabs/iscsi-tools"
]
```

Extensions are defined in `modules/vms_proxmox/schematics/`:
- `base.yaml` - Base extensions
- `nvidia.yaml` - NVIDIA GPU extensions
- `intel.yaml` - Intel GPU extensions

## Cluster Endpoint Priority

The module determines cluster endpoint in this order:

1. **VIP** (if configured) - Recommended for HA
2. **Explicit endpoint** (if provided)
3. **First control plane IP** (default)

See [ENDPOINT.md](../ENDPOINT.md) for details.

## Common Patterns

### Production HA Setup
Use **example 6** (ha-vip-cluster) with:
- 3+ control planes
- VIP configuration
- Dedicated workers
- `allow_scheduling_on_control_planes = false`

### Development Setup
Use **example 0** (demo-cluster) with:
- 3 control planes (allows scheduling)
- GitOps enabled
- No dedicated workers

### GPU Workloads
Use **example 1** (gpu-cluster) with:
- GPU node configuration
- PCI passthrough
- Automatic GPU extension merging

### Resource-Constrained
Use **example 3** (mini-cluster) with:
- Single control plane
- 2 workers
- Smaller resource allocation

## Testing Examples

Each example can be tested independently:

```bash
cd examples/6-ha-vip-cluster
cp variables.auto.tfvars.example variables.auto.tfvars
# Edit variables.auto.tfvars with your settings
terraform init
terraform plan
terraform apply
```

## Related Documentation

- [ENDPOINT.md](../ENDPOINT.md) - Cluster endpoint configuration
- [CLAUDE.md](../CLAUDE.md) - Development guide
- [GPU.md](../modules/talos_k8s/GPU.md) - GPU configuration
- [Main README](../README.md) - Module documentation
