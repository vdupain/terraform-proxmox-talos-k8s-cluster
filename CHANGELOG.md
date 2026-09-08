# Changelog

## v2.1.0-rc0 (2026-08-26)

### Changed

- **Terraform version constraint**: `>= 1.8` → `>= 1.10` (required for mock provider tests)
- **CI**: `actions/checkout@v3` → `@v4`; Terraform binary `1.10.5` → `~> 1.11`; removed redundant `terraform init` calls before test suites

### Fixed

- `modules/vms_proxmox/variables.tf`: added `install_disk` (optional, default `/dev/sda`) to VM object type — previously silently dropped by the submodule
- `modules/vms_proxmox/variables.tf`: changed `ip` from required to `optional(string)` — matches root module type, fixes DHCP clusters where IP is omitted
- `provider.auto.tfvars.template`: removed stale `github` variable block that no longer exists in root module

### Added

- CHANGELOG.md
- `docs/adr/0001-cluster-k8s-addressing-vlan-50.md` (copied from `gitops-k8s`) — IP addressing convention for K8s clusters on VLAN 50