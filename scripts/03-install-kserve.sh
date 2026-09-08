#!/usr/bin/env bash
# 安装 KServe v0.14.1，并切换为 RawDeployment（不装 Istio/Knative，省内存）
set -euxo pipefail
KSERVE_VERSION="${KSERVE_VERSION:-v0.14.1}"

kubectl apply -f "https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml"

# 关键: 默认部署模式 = RawDeployment
kubectl -n kserve patch configmap kserve-config --type merge \
  -p '{"data":{"inferenceConfig":"{\"deploy\":{\"defaultDeploymentMode\":\"RawDeployment\"}}"}}'

kubectl -n kserve rollout status deploy/kserve-controller-manager --timeout=300s
kubectl -n kserve get pods -o wide