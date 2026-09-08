#!/usr/bin/env bash
# 前置依赖: kind + kubectl (GitHub Actions ubuntu-latest / 通用 Linux amd64)
set -euxo pipefail
KIND_VERSION="${KIND_VERSION:-v0.27.0}"
KUBECTL_VERSION="${KUBECTL_VERSION:-v1.31.2}"

curl -sSLo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x /tmp/kind && sudo mv /tmp/kind /usr/local/bin/kind

curl -sSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

kind version
kubectl version --client