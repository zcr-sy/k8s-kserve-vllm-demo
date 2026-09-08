#!/usr/bin/env bash
# 创建 kind 单节点集群
set -euxo pipefail

cat > /tmp/kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF

kind create cluster --config /tmp/kind-config.yaml --wait 240s
kubectl cluster-info
kubectl get nodes -o wide