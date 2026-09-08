#!/usr/bin/env bash
# Codespaces 内自动部署: k8s(kind) -> KServe(RawDeployment) -> vLLM(CPU) -> Qwen2.5-0.5B -> OpenAI API 冒烟
# 全程输出到 stdout (devcontainer.json 重定向到 RESULT.txt 并 push 回仓库)
set -x

echo "=== [0] 环境准备 ==="
id
sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
for i in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done
docker version

echo "=== [1] 安装 kind + kubectl ==="
bash scripts/01-install-tools.sh

echo "=== [2] 创建 kind 集群 ==="
bash scripts/02-create-kind.sh

echo "=== [3] 安装 KServe (RawDeployment) ==="
bash scripts/03-install-kserve.sh

echo "=== [4] 部署 InferenceService (vLLM + Qwen2.5-0.5B, CPU) ==="
bash scripts/04-deploy-isvc.sh

echo "=== [5] 冒烟测试: OpenAI /v1/chat/completions ==="
bash scripts/05-smoke-test.sh

echo "=== [6] 状态汇总 ==="
kubectl get isvc,deploy,svc,pods -A -o wide 2>/dev/null || true
kubectl logs deploy/qwen-vllm-predictor -n default --tail=20 2>/dev/null || true

echo "=== DEMO COMPLETED ==="