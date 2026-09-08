#!/usr/bin/env bash
# 部署 InferenceService (vLLM CPU + Qwen2.5-0.5B) 并等待就绪
set -euxo pipefail

kubectl apply -f manifests/qwen-vllm.yaml
kubectl get isvc qwen-vllm -o wide

# raw 模式下 deployment 可用 = pod 就绪 = vLLM /health 通了
kubectl rollout status deploy/qwen-vllm-predictor-default --timeout=900s
kubectl wait --for=condition=Ready --timeout=900s isvc/qwen-vllm 2>/dev/null || true

kubectl get isvc,pods -A -o wide