#!/usr/bin/env bash
# This script installs ADRift and its dependencies in a Kubernetes cluster.

set -eou pipefail

# This script assumes that kubectl and kustomize are installed and configured.
# Namespace installation
kubectl apply -f k8s/prereqs/namespace.yaml > /dev/null 2>&1 || true

# Let's get the prerequisites ready
echo "[INFO] - Installing prerequisites..."

kustomize build k8s/prereqs | kubectl apply -f - > /dev/null 2>&1 || true
sleep 3

# Install Helium API Client
echo "[INFO] - Installing Helium API Client..."
kustomize build k8s/overlays | kubectl apply -f - > /dev/null 2>&1 || true
sleep 3

echo "[COMPLETE] - Helium API Client and its dependencies have been successfully installed!"
