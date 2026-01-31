# Example 6: HA Cluster with VIP

This example demonstrates a highly available (HA) Kubernetes cluster using a Virtual IP (VIP) for control plane access.

## Overview

- **3 Control Plane Nodes**: Provides quorum and high availability
- **3 Worker Nodes**: Dedicated worker nodes for running workloads
- **VIP (Virtual IP)**: `192.168.10.200` - Single endpoint for control plane access
- **Automatic Failover**: kube-vip manages VIP failover between control plane nodes
- **Production Ready**: Separate control plane and worker nodes

## VIP Configuration

The VIP configuration automatically:
1. Becomes the cluster endpoint (highest priority)
2. Configures kube-vip on all control plane nodes
3. Provides automatic failover if a control plane node fails
4. Enables seamless HA without external load balancers

### Key Configuration

```hcl
cluster = {
  vip_ip        = "192.168.10.200"  # Virtual IP address
  vip_interface = "eth0"            # Network interface

  # VIP automatically becomes cluster endpoint
  # No need to set endpoint explicitly

  allow_scheduling_on_control_planes = false  # Dedicated control plane
}
```

## Network Topology

```
┌─────────────────────────────────────┐
│  VIP: 192.168.10.200 (kube-vip)    │
│  Cluster Endpoint (Automatic)       │
└────────────┬────────────────────────┘
             │
     ┌───────┴──────┬──────────┐
     │              │          │
┌────▼─────┐  ┌────▼─────┐  ┌▼────────┐
│  cp-01   │  │  cp-02   │  │  cp-03  │
│ .10.210  │  │ .10.211  │  │ .10.212 │
│  pve1    │  │  pve2    │  │  pve3   │
└──────────┘  └──────────┘  └─────────┘

┌──────────┐  ┌──────────┐  ┌─────────┐
│worker-01 │  │worker-02 │  │worker-03│
│ .10.220  │  │ .10.221  │  │ .10.222 │
│  pve1    │  │  pve2    │  │  pve3   │
└──────────┘  └──────────┘  └─────────┘
```

## VIP Behavior

### Priority Order
The module determines cluster endpoint in this order:
1. **VIP** (if configured) ← **This example**
2. Explicit endpoint (if provided)
3. First control plane IP (default)

### How kube-vip Works
- VIP is managed by kube-vip running on control plane nodes
- Failover happens automatically if the active node fails
- All control plane nodes can answer on the VIP
- No external load balancer needed

## Prerequisites

- Proxmox VE cluster with 3 nodes
- Network configured to allow VIP (192.168.10.200 must be available)
- No IP conflicts with the VIP address

## Usage

1. Copy `variables.auto.tfvars.example` to `variables.auto.tfvars`
2. Update Proxmox credentials and cluster settings
3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## After Deployment

### Access the Cluster

The kubeconfig will use the VIP as the cluster endpoint:

```bash
kubectl --kubeconfig ../../output/kube-config.yaml get nodes
```

Expected output:
```
NAME        STATUS   ROLES           AGE   VERSION
cp-01       Ready    control-plane   5m    v1.31.x
cp-02       Ready    control-plane   5m    v1.31.x
cp-03       Ready    control-plane   5m    v1.31.x
worker-01   Ready    <none>          5m    v1.31.x
worker-02   Ready    <none>          5m    v1.31.x
worker-03   Ready    <none>          5m    v1.31.x
```

### Verify VIP

Check kube-vip is running:

```bash
kubectl --kubeconfig ../../output/kube-config.yaml get pods -n kube-system | grep kube-vip
```

Test VIP connectivity:

```bash
# Should respond from the VIP
curl -k https://192.168.10.200:6443/version
```

### Test Failover

1. Identify which control plane holds the VIP:
```bash
talosctl --talosconfig ../../output/talos-config.yaml \
  -n 192.168.10.210,192.168.10.211,192.168.10.212 \
  get members
```

2. Shutdown the active node (in Proxmox UI)
3. Verify VIP fails over to another control plane node
4. Verify cluster remains accessible via VIP

## Benefits

✅ **High Availability**: No single point of failure
✅ **Automatic Failover**: kube-vip handles VIP migration
✅ **Production Ready**: Dedicated control plane nodes
✅ **Simple**: No external load balancer needed
✅ **Cost Effective**: Uses built-in kube-vip

## Comparison with Other Examples

| Example | Control Planes | Workers | VIP | Use Case |
|---------|---------------|---------|-----|----------|
| 0-demo-cluster | 3 | 0 | No | Development, workloads on control plane |
| 2-bare-cluster | 3 | 0 | No | Minimal setup without GitOps |
| 3-mini-cluster | 1 | 2 | No | Small clusters, testing |
| **6-ha-vip-cluster** | **3** | **3** | **Yes** | **Production HA cluster** |

## Related Documentation

- [ENDPOINT.md](../../ENDPOINT.md) - Cluster endpoint configuration guide
- [VIP Configuration Tests](../../tests/vip_configuration.tftest.hcl) - VIP test examples
- [Cluster Endpoint Tests](../../tests/cluster_endpoint.tftest.hcl) - Endpoint priority tests
