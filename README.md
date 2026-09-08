# k8s → KServe → vLLM 全流程 demo（免费 GitHub Actions, CPU）

- 平台: GitHub Actions (公开仓库, 免费不限分钟; runner 为真实 VM)
- 链路: kind(k8s) → KServe(RawDeployment) → vLLM(CPU) → Qwen2.5-0.5B-Instruct → OpenAI API
- 配置: `.github/workflows/kserve-vllm-demo.yml`
- 脚本: `scripts/01..05` (安装工具/建集群/装KServe/部署ISVC/冒烟)
- 清单: `manifests/qwen-vllm.yaml`

## 运行

```bash
# 推送到 main 即自动触发; 也可手动:
gh workflow run kserve-vllm-demo
gh run watch
```

## 替换模型

编辑 `manifests/qwen-vllm.yaml` 的 `--model` 参数即可 (如 `Qwen/Qwen2.5-1.5B-Instruct`, 注意资源配额)。