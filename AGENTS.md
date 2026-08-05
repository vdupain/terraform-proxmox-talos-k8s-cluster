# AGENTS.md

Terraform/OpenTofu module: provisions a K8s cluster on Proxmox VE with Talos OS, optionally bootstraps FluxCD.

## Commands

```sh
# Tests MUST use `terraform` (NOT `tofu` — OpenTofu 1.9 crashes on talos mock provider)
terraform test                           # root tests
cd modules/talos_k8s && terraform test   # endpoint priority, node segregation, GPU patches
cd modules/vms_proxmox && terraform test # VM naming, count, networking, PCI mapping

# Format / validate / lint (run from root or any env/example dir)
terraform fmt -recursive
terraform validate
tflint                                    # enforces snake_case

# README generation (before release)
./prepare-release.sh                      # terraform fmt + terraform-docs injection

# Working env (e.g. envs/staging)
tofu init && tofu plan && tofu apply
tofu output kube_config                   # get kubeconfig
```

## Architecture

Execution order (enforced by `depends_on`):
`vms_proxmox → talos_k8s → init_k8s (optional) → gitops_k8s (optional)`

- **`modules/vms_proxmox`** — Creates VMs. Talos image per (host_node, schematic) combo. OVMF/UEFI, q35, virtio-scsi-pci. Two disks (system + user).
- **`modules/talos_k8s`** — Machine secrets, config templates in `config/`, bootstraps etcd, retrieves kubeconfig. Cilium/ZFS/GPU patches embedded inline.
- **`modules/init_k8s`** — Optional; runs if `certificate != null`. Installs sealed-secrets TLS cert.
- **`modules/gitops_k8s`** — Optional; runs if `gitops != null`. `flux_bootstrap_git`.

## Agent skills

### Issue tracker

Issues and specs live on GitHub Issues (`gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Triage labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Cluster endpoint priority (`modules/talos_k8s/main.tf`)
1. `vip_ip` (HA Virtual IP)
2. `cluster.endpoint` (explicit)
3. First control plane IP (fallback)

## GPU support
- Set `gpu = "nvidia-<model>"` on a VM → NVIDIA passthrough
- Regex `(?i)nvidia` determines GPU type → triggers Talos extensions + `gpu-nvidia-patch.yaml`
- PCI passthrough via Proxmox hardware mapping (`var.pci`)

## Networking
- `network_dhcp = true`: DHCP; 60s `time_sleep` after VM creation for IP assignment
- Static: IPs from `vms` map; `gateway` and `cidr` required

## Talos image schematic system
- `modules/vms_proxmox/schematics/base.yaml` — `qemu-guest-agent`, `zfs` for all nodes
- `modules/vms_proxmox/schematics/nvidia.yaml` — NVIDIA extensions
- Extensions merged: base + GPU-specific + `additional_extensions` input
- Schematic ID at plan time via POST to `https://factory.talos.dev/schematics`

## Key conventions
- All Terraform identifiers `snake_case` (enforced by TFLint)
- VMs named `{cluster.name}-{vm_key}` in Proxmox
- Output files: `output/kube-config.yaml`, `output/talos-config.yaml` (`0600`)
- Also written to `~/.kube/{cluster.name}.yaml` and `~/.talos/{cluster.name}.yaml`
- `envs/` = real deployed clusters (state + credentials), consume from registry
- `examples/` = reference impls, also from registry; used by terraform-docs
- Proxmox creds via `provider.auto.tfvars` (gitignored) or env vars
- CI: self-hosted runner, `pve0` env, runs init → fmt -check → validate → test (3 suites) → plan
