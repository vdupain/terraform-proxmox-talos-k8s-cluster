#!/bin/sh

export CONTROL_PLANE_IP=192.168.10.220
export GPU_WORKER_IP=192.168.10.223
export TALOSCONFIG="output/talos-config.yaml"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $GPU_WORKER_IP
talosctl read /proc/modules
talosctl get extensions
talosctl read /proc/driver/nvidia/version
