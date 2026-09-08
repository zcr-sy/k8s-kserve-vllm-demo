#!/usr/bin/env bash
# 部署 InferenceService (vLLM CPU + Qwen2.5-0.5B) 并等待就绪 (含快速失败探测)
set -euxo pipefail

kubectl apply -f manifests/qwen-vllm.yaml
kubectl get isvc qwen-vllm -o wide

# 快速探测 pod 状态: CrashLoop/镜像拉取失败 立即打印详情退出, 避免干等 rollout 超时
for i in $(seq 1 30); do   # 最长 ~5 分钟探测
  PHASE=$(kubectl get pods -l serving.kserve.io/inferenceservice=qwen-vllm -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo '')
  REASON=$(kubectl get pods -l serving.kserve.io/inferenceservice=qwen-vllm -o jsonpath='{.items[0].status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || echo '')
  echo "[probe $i] phase=$PHASE reason=$REASON"
  if [ "$PHASE" = "Running" ]; then break; fi
  case "$REASON" in
    CrashLoopBackOff|ImagePullBackOff|ErrImagePull)
      echo "!! pod 异常: $REASON —— 打印详情提前退出"
      kubectl describe pod -l serving.kserve.io/inferenceservice=qwen-vllm 2>/dev/null | tail -40 || true
      kubectl logs -l serving.kserve.io/inferenceservice=qwen-vllm --tail=80 2>/dev/null || true
      exit 1;;
  esac
  sleep 10
done

# raw 模式下 deployment 可用 = pod 就绪 = vLLM /health 通了
kubectl rollout status deploy/qwen-vllm-predictor-default --timeout=600s
kubectl wait --for=condition=Ready --timeout=300s isvc/qwen-vllm 2>/dev/null || true

kubectl get isvc,pods -A -o wide