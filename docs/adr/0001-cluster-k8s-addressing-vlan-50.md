# ADR 0001 — Cluster Kubernetes Addressing Convention on VLAN 50 (HOMELAB)

- **Status**: Accepted
- **Date**: 2026-08-18
- **Owner**: HAL (convention owner, updated per decisions)
- **Applies to**: homelab K8s clusters (ai-cluster, future prod/staging)

## Context

The homelab network is segmented by VLAN (migration operational, 12/08): K8s clusters
live on **VLAN 50 (HOMELAB)**, `192.168.50.0/24`, gateway `192.168.50.1`.

Clusters previously used ad-hoc IP allocation on VLAN 10 (USER), which caused
collision-prone, unpredictable addressing (e.g. ai-cluster LB pool on
`192.168.10.230-.235`). A deterministic convention is needed so IP allocation for
cluster nodes and LoadBalancer services is predictable and collision-free.

## Decision

### Address blocks

Each cluster gets a **16-IP block** starting at `192.168.50.(200 + 16 × N)`:

| Block | Base | Range | Cluster |
|---|---|---|---|
| 0 | `.200` | `.200` – `.215` | staging |
| 1 | `.216` | `.216` – `.231` | prod |
| 2 | `.232` | `.232` – `.247` | autre (ai-cluster) |

### Node addressing

- The first IP of the block is reserved as the **cluster base** (reserved).
- Single-node clusters use the base IP for the control-plane/worker node.
- Multi-node clusters allocate node IPs sequentially from the base.

### LoadBalancer pool

- The LB pool covers **`base + 8` through `base + 13`** (6 IPs).
- IPs are allocated **sequentially** within the pool:
  1. **coredns** — first IP of the pool (`base + 8`)
  2. **ingress / traefik** — second IP of the pool (`base + 9`)
  3. **Gateway API (Cilium)** — third IP of the pool (`base + 10`)
  4. other services — sequential order, one IP each

### Example — ai-cluster (block 2, base `.232`)

| Item | Value |
|---|---|
| Node (single) | `192.168.50.232` |
| LB pool | `192.168.50.240` – `192.168.50.245` |
| coredns | `192.168.50.240` |
| ingress (traefik) | `192.168.50.241` |
| Gateway API (Cilium) | `192.168.50.242` |
| Gateway | `192.168.50.1` |
| VLAN tag | 50 |
| MTU | 1400 (adapted to the VXLAN path) |

DNS: `*.ai.vincentdupain.com` points to the **ingress LB IP only** (`192.168.50.241`),
not the whole pool.

## Consequences

- Cluster IPs are predictable: any cluster is located by its block number.
- LB service IPs are collision-free within a cluster and stable across clusters.
- Existing clusters must be migrated to the convention (ai-cluster: ticket #38).
- prod/staging are **not deployed** — the convention only reserves their blocks
  (no config change needed today).

## Source of truth

This ADR is the source of truth for the convention. The French reference in the
vault (`Personal/Homelab/Reseau/.../convention-adressage-clusters-k8s.md`) links here.
