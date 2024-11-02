# Talos

## Provisionner un cluster k8s

```sh
terraform apply -auto-approve
terraform output -raw kubeconfig > kubeconfig-talos-cluster
terraform output -raw talosconfig > talosconfig-talos-cluster

cp kubeconfig-talos-cluster $HOME/.kube/config
k9s --kubeconfig kubeconfig-talos-cluster
```

Et voila !

En gros le provisionning Terraform pour Talos est l'équivalent de ceci en ligne de commande:

```sh
# generate Machine Configurations
export CONTROL_PLANE_IP=192.168.10.220
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out --force

# create Control Plane Node
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml
talosctl apply-config --insecure --nodes 192.168.10.221 --file _out/controlplane.yaml

# create Worker Node
talosctl apply-config --insecure --nodes 192.168.10.233 --file _out/worker.yaml
talosctl apply-config --insecure --nodes 192.168.10.234 --file _out/worker.yaml


# using the Cluster
export TALOSCONFIG="_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP

# bootstrap Etcd
talosctl bootstrap

# retrieve the kubeconfig
talosctl kubeconfig .
```

## Utiliser le cluster

```sh
export CONTROL_PLANE_IP=192.168.10.220
export WORKER_IP=192.168.10.226
export TALOSCONFIG="talosconfig-talos-cluster"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $WORKER_IP
```

## Docs

* <https://www.talos.dev/v1.7/talos-guides/install/virtualized-platforms/proxmox/>
* <https://github.com/siderolabs/contrib/tree/main/examples/terraform/basic>
