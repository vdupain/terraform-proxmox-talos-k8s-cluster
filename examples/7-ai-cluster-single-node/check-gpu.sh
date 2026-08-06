#!/bin/sh
# Check GPU availability on the ai-cluster single node.
# Run from examples/7-ai-cluster-single-node/ after bootstrap.

export CONTROL_PLANE_IP=192.168.10.203
export TALOSCONFIG="output/talos-config.yaml"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
talosctl read /proc/modules
talosctl get extensions
talosctl read /proc/driver/nvidia/version
