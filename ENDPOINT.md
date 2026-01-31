# Cluster Endpoint Configuration

This document explains how the Kubernetes cluster endpoint is automatically determined in this Terraform module.

## Overview

The cluster endpoint is the address that all Kubernetes components and clients use to communicate with the control plane. This module intelligently determines the cluster endpoint based on your configuration, using a priority-based system.

## Priority Order

The module determines the cluster endpoint using the following priority:

### 1. VIP (Virtual IP) - Highest Priority

**When to use:** HA control plane setups with multiple control plane nodes

If `cluster.vip_ip` is configured, it automatically becomes the cluster endpoint, regardless of other settings.

```hcl
cluster = {
  name          = "prod-cluster"
  vip_ip        = "192.168.1.100"
  vip_interface = "eth0"
  gateway       = "192.168.1.1"
  cidr          = 24
}

vms = {
  cp-01 = {
    host_node    = "pve1"
    machine_type = "controlplane"
    ip           = "192.168.1.10"
    # ...
  }
  cp-02 = {
    host_node    = "pve2"
    machine_type = "controlplane"
    ip           = "192.168.1.11"
    # ...
  }
  cp-03 = {
    host_node    = "pve3"
    machine_type = "controlplane"
    ip           = "192.168.1.12"
    # ...
  }
}
```

**Result:** Cluster endpoint = `https://192.168.1.100:6443`

**Benefits:**
- High availability - kube-vip automatically manages VIP failover
- No single point of failure
- Transparent failover if a control plane node fails
- Recommended for production environments

### 2. Explicit Endpoint - Medium Priority

**When to use:** External load balancers or DNS entries

If `cluster.endpoint` is set (and VIP is not configured), it will be used as the cluster endpoint.

```hcl
cluster = {
  name     = "prod-cluster"
  endpoint = "k8s-api.example.com"  # Or an IP: "192.168.1.200"
  gateway  = "192.168.1.1"
  cidr     = 24
}

vms = {
  cp-01 = {
    host_node    = "pve1"
    machine_type = "controlplane"
    ip           = "192.168.1.10"
    # ...
  }
  # ...
}
```

**Result:** Cluster endpoint = `https://k8s-api.example.com:6443`

**Use cases:**
- Using an external hardware load balancer
- Using a DNS name with round-robin or load balancer
- Custom HA solutions outside of kube-vip

### 3. First Control Plane IP - Default/Fallback

**When to use:** Development, testing, or single control plane clusters

If neither VIP nor explicit endpoint is configured, the module uses the first control plane node's IP address.

```hcl
cluster = {
  name    = "dev-cluster"
  gateway = "192.168.1.1"
  cidr    = 24
  # No vip_ip or endpoint specified
}

vms = {
  cp-01 = {
    host_node    = "pve1"
    machine_type = "controlplane"
    ip           = "192.168.1.10"
    # ...
  }
}
```

**Result:** Cluster endpoint = `https://192.168.1.10:6443`

**Use cases:**
- Single node clusters
- Development environments
- Testing and proof-of-concept deployments

## Configuration Matrix

| VIP Configured | Endpoint Configured | Cluster Endpoint Used        | Use Case                          |
|----------------|---------------------|------------------------------|-----------------------------------|
| Yes            | Yes                 | VIP                          | HA with VIP (VIP takes priority)  |
| Yes            | No                  | VIP                          | HA with VIP                       |
| No             | Yes                 | Explicit Endpoint            | External LB or DNS                |
| No             | No                  | First Control Plane IP       | Development/Single node           |

## DHCP Mode

When using DHCP mode (`cluster.network_dhcp = true`):

```hcl
cluster = {
  name         = "dhcp-cluster"
  network_dhcp = true
  vip_ip       = "192.168.1.100"  # Optional but recommended for HA
  vip_interface = "eth0"
}
```

- The endpoint priority system still applies
- VIP is recommended for HA clusters even with DHCP
- Without VIP or explicit endpoint, uses first control plane's DHCP-assigned IP
- Module waits 60 seconds after VM creation for DHCP assignment

## Best Practices

### Production Environments

**Recommended:** Use VIP for HA control plane

```hcl
cluster = {
  name                               = "prod-cluster"
  vip_ip                             = "192.168.1.100"
  vip_interface                      = "eth0"
  allow_scheduling_on_control_planes = false  # Separate control/worker planes
  # ...
}
```

Benefits:
- Built-in HA with automatic failover
- No external dependencies
- Simple configuration

### Development/Testing

**Recommended:** Single control plane with default endpoint

```hcl
cluster = {
  name                               = "dev-cluster"
  allow_scheduling_on_control_planes = true  # Allow workloads on control plane
  # ...
}
```

Benefits:
- Minimal resource usage
- Simple setup
- Quick iteration

### Hybrid Cloud or Complex Networks

**Recommended:** Explicit endpoint with external load balancer

```hcl
cluster = {
  name     = "hybrid-cluster"
  endpoint = "k8s-api.internal.example.com"
  # ...
}
```

Benefits:
- Integration with existing infrastructure
- Flexible routing options
- DNS-based service discovery

## Troubleshooting

### Cluster endpoint mismatch

**Symptom:** kubeconfig points to wrong endpoint

**Solution:** Check priority order - VIP overrides endpoint configuration

```bash
# Check the actual endpoint in use
kubectl --kubeconfig output/kube-config.yaml config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

### VIP not responding

**Symptom:** Cannot connect to VIP address

**Checks:**
1. Verify at least one control plane is healthy: `talosctl health`
2. Check VIP interface matches network configuration
3. Ensure no IP conflicts with VIP address
4. Verify kube-vip is running: `kubectl get pods -n kube-system -l app.kubernetes.io/name=kube-vip`

### DHCP endpoint issues

**Symptom:** Endpoint changes after reboot

**Solution:** Use VIP even with DHCP to ensure stable endpoint

```hcl
cluster = {
  name         = "stable-cluster"
  network_dhcp = true
  vip_ip       = "192.168.1.100"  # Static VIP with DHCP nodes
}
```

## Implementation Details

The endpoint determination logic is implemented in `modules/talos_k8s/main.tf`:

```hcl
locals {
  cluster_endpoint = (
    var.cluster.vip_ip != null ? var.cluster.vip_ip :
    var.cluster.endpoint != null ? var.cluster.endpoint :
    local.first_control_plane
  )
}
```

This ensures consistent endpoint usage across:
- Talos machine configurations
- Kubernetes API server certificates
- kubeconfig generation
- Client configurations

## Related Documentation

- [CLAUDE.md](CLAUDE.md) - Project overview and development guide
- [Network Configuration](CLAUDE.md#network-configuration-modes) - Network modes and DHCP setup
- [VIP Configuration Tests](tests/cluster_endpoint.tftest.hcl) - Automated tests for endpoint logic
