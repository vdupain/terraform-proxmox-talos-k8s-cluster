# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

A Terraform/OpenTofu module that fully automates provisioning a Kubernetes cluster on Proxmox VE using Talos OS, then optionally bootstraps it with FluxCD for GitOps. It is published to the Terraform registry as `vdupain/talos-k8s-cluster/proxmox`.

## Commands

### Running tests

Tests use `mock_provider` blocks so no real Proxmox/Talos infrastructure is required. All tests use `command = plan`. Use `terraform` (not `tofu` — OpenTofu 1.9 has a crash bug with mock providers for the talos provider schema).

```sh
# Root-level tests (optional module instantiation, cluster name output)
terraform test

# talos_k8s module tests (endpoint priority, node segregation, GPU patches)
cd modules/talos_k8s && terraform test

# vms_proxmox module tests (VM naming, count, networking, PCI mapping)
cd modules/vms_proxmox && terraform test
```

Each module is tested independently in its own `tests/` subdirectory — the standard Terraform convention for module-level tests. Root-level tests can only access module outputs, so internal resource assertions live alongside their module.

### Formatting and validation (run from root or any env/example dir)
```sh
terraform fmt -recursive          # Format all .tf files
terraform validate                # Validate configuration
tflint                            # Lint (uses .tflint.hcl — snake_case naming enforced)
```

### README generation (before releasing)
```sh
./prepare-release.sh
# Runs: terraform fmt -recursive, then terraform-docs to inject docs into README.md
```

### Generate sealed-secrets TLS certificate
```sh
./generate-certificates.sh
# Output: output/my-tls.crt and output/my-tls.key
```

### Working with an environment (e.g. envs/staging)
```sh
cd envs/staging
tofu init
tofu plan
tofu apply
tofu output kube_config    # Get kubeconfig
```

## Architecture

### Module execution order (enforced by `depends_on`)
```
vms_proxmox  →  talos_k8s  →  init_k8s (optional)  →  gitops_k8s (optional)
```

1. **`modules/vms_proxmox`** — Creates Proxmox VMs. Downloads the correct Talos image from `factory.talos.dev` based on the schematic (extensions) for each VM's GPU type. Each unique (host_node, schematic) combination gets its own image download. VMs use OVMF/UEFI, q35 machine type, virtio-scsi-pci. Two disks per VM: system (boots Talos) and user (data).

2. **`modules/talos_k8s`** — Generates Talos machine secrets, applies machine configs to each node via the Talos API, bootstraps etcd on the first control plane, and retrieves the kubeconfig. Config patches are applied per-node using templates in `config/`. Cilium CNI, ZFS setup, and optional GPU patches are embedded inline into the Talos machine config at apply time (not post-boot).

3. **`modules/init_k8s`** — Optional (only runs if `certificate` input is non-null). Installs the sealed-secrets TLS certificate into the cluster as a Kubernetes secret.

4. **`modules/gitops_k8s`** — Optional (only runs if `gitops` input is non-null). Runs `flux_bootstrap_git` to connect the cluster to a Git repository.

### Talos image schematic system
- `modules/vms_proxmox/schematics/base.yaml` — base extensions for all nodes (`qemu-guest-agent`, `zfs`)
- `modules/vms_proxmox/schematics/nvidia.yaml` — additional extensions for NVIDIA GPU nodes
- Extension lists are merged: base + GPU-specific + `additional_extensions` input variable
- Schematic ID is obtained at plan time by POST to `https://factory.talos.dev/schematics`
- Image URL is constructed as `factory.talos.dev/image/{schematic_id}/{version}/nocloud-amd64.raw.gz`

### Cluster endpoint resolution priority (in `modules/talos_k8s/main.tf`)
1. `vip_ip` (if set — HA Virtual IP via Talos VIP feature)
2. `cluster.endpoint` (explicit endpoint)
3. First control plane IP (fallback)

### GPU support
- Set `gpu = "nvidia-gpu-name"` on a VM to enable GPU passthrough
- The regex `(?i)nvidia` determines GPU type from the mapping name
- NVIDIA nodes get additional Talos extensions + a GPU patch YAML applied to machine config
- PCI device passthrough is configured via Proxmox hardware mapping (`var.pci`)

### DHCP vs static networking
- `network_dhcp = true`: VMs use DHCP; a 60-second `time_sleep` is injected after VM creation to allow IPs to be assigned before Talos bootstrap
- Static: IPs come from the `vms` map; `gateway` and `cidr` are required

### Environments vs Examples
- **`envs/`** — real deployed clusters (have `terraform.tfstate`, `output/` with actual kubeconfig/talosconfig, `provider.auto.tfvars` with real credentials). Each env consumes the module from the registry (e.g. `source = "vdupain/talos-k8s-cluster/proxmox"`).
- **`examples/`** — reference implementations for different topologies, also consuming from the registry. Used by `terraform-docs` to generate README documentation.

### Credentials / secrets
- Proxmox credentials are passed via `provider.auto.tfvars` (gitignored) or environment variables (`PROXMOX_VE_ENDPOINT`, `PROXMOX_VE_API_TOKEN`, etc.)
- `.env` / `.env.example` in root and example dirs show the env var pattern
- GitHub Actions uses the `pve0` environment with repository secrets/vars

### Naming conventions
- All Terraform identifiers must be `snake_case` (enforced by TFLint)
- VMs are named `{cluster.name}-{vm_key}` in Proxmox
- Output files go to `output/` inside each env dir: `kube-config.yaml`, `talos-config.yaml`
