#!/usr/bin/env bash
# 安装 cert-manager + KServe v0.14.1，并切换为 RawDeployment（不装 Istio/Knative，省内存）
set -euxo pipefail
CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.16.3}"
KSERVE_VERSION="${KSERVE_VERSION:-v0.14.1}"

# 1) cert-manager（KServe webhook 的 Certificate/Issuer CRD 依赖）
kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml"
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=300s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=300s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=300s
kubectl -n cert-manager get pods -o wide

# 2) KServe —— 用 server-side apply（大 CRD 的 last-applied 注解会超 262144 字节限制，SSA 绕开）
kubectl apply --server-side -f "https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml"

# 3) 关键: 默认部署模式 = RawDeployment
kubectl -n kserve patch configmap kserve-config --type merge \
  -p '{"data":{"inferenceConfig":"{\"deploy\":{\"defaultDeploymentMode\":\"RawDeployment\"}}"}}'

kubectl -n kserve rollout status deploy/kserve-controller-manager --timeout=300s
kubectl -n kserve rollout status deploy/kserve-localmodel-controller-manager --timeout=300s || true
kubectl -n kserve get pods -o wide