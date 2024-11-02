# NVIDA GPU

```sh
crane export ghcr.io/siderolabs/extensions:v1.7.1 | tar x -O image-digests | grep -E 'nvidia-container-toolkit|nvidia-open-gpu-kernel-modules'
ghcr.io/siderolabs/nvidia-container-toolkit:535.129.03-v1.14.6@sha256:b66c197c3962fca5ddc4dccc62e51935b53e5dbdb84d254b046f0289d87cea42
ghcr.io/siderolabs/nvidia-open-gpu-kernel-modules:535.129.03-v1.7.1@sha256:1250e7accfaf153c4dd470a08da9caca9cfa90a3357b4492d86c8cfba26bbc02
```

## OSS drivers

```sh
docker run --rm -t -v $PWD/_out:/out -v /dev:/dev --privileged ghcr.io/siderolabs/imager:v1.7.1 nocloud \
    --system-extension-image ghcr.io/siderolabs/nvidia-container-toolkit:535.129.03-v1.14.6@sha256:b66c197c3962fca5ddc4dccc62e51935b53e5dbdb84d254b046f0289d87cea42 \
    --system-extension-image ghcr.io/siderolabs/nvidia-open-gpu-kernel-modules:535.129.03-v1.7.1@sha256:1250e7accfaf153c4dd470a08da9caca9cfa90a3357b4492d86c8cfba26bbc02 \
    --extra-kernel-arg net.ifnames=0 --extra-kernel-arg=-console --extra-kernel-arg=console=ttyS1 --arch=amd64
```

## Proprietary drivers

```sh
docker run --rm -t -v $PWD/_out:/out -v /dev:/dev --privileged ghcr.io/siderolabs/imager:v1.7.1 nocloud \
    --system-extension-image ghcr.io/siderolabs/nvidia-container-toolkit:535.129.03-v1.14.6@sha256:b66c197c3962fca5ddc4dccc62e51935b53e5dbdb84d254b046f0289d87cea42 \
    --system-extension-image ghcr.io/siderolabs/nonfree-kmod-nvidia:535.129.03-v1.7.1@sha256:ada00f51f2abf24287ac0dc1751c1dfbabc0ac498faacca764310bb9582da784 \
    --extra-kernel-arg net.ifnames=0 --extra-kernel-arg=-console --extra-kernel-arg=console=ttyS1 --arch=amd64
```

## Talos Linux Image Factory

Au lieu de contruire son image, il est possible d'utiliser <https://factory.talos.dev/> qui permet de générer des images avec des extensions

```sh
export CONTROL_PLANE_IP=192.168.10.210
export GPU_WORKER_IP=192.168.10.213
export TALOSCONFIG="talosconfig-talos-cluster"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $GPU_WORKER_IP
talosctl patch mc --patch @files/gpu-worker-patch.yaml
talosctl read /proc/modules
talosctl get extensions
talosctl read /proc/driver/nvidia/version
talosctl patch mc --patch @files/nvidia-default-runtimeclass.yaml
```
