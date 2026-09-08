#!/usr/bin/env bash
# 冒烟测试: port-forward -> OpenAI /v1/chat/completions 真实推理
set -euxo pipefail

# v0.14 raw 模式资源名: <name>-predictor (无 -default 后缀); svc 端口 80 -> 容器 8000
kubectl port-forward svc/qwen-vllm-predictor 8000:80 >/tmp/pf.log 2>&1 &
PF_PID=$!
trap 'kill $PF_PID 2>/dev/null || true' EXIT
sleep 12

echo "===== /health ====="
curl -sS --max-time 90 http://127.0.0.1:8000/health || echo "(health failed)"
echo

echo "===== /v1/chat/completions ====="
curl -sS --max-time 300 http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen","messages":[{"role":"user","content":"用一句中文介绍你自己，不超过30字"}],"max_tokens":80}' \
  || echo "(completion failed)"
echo