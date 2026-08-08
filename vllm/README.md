# vLLM (native)

Run an OpenAI-compatible inference endpoint with vLLM natively via systemd — no Docker.

> **Experimental template.** Verify the deployment on your own GPU server before relying on it.

## What you get

- An OpenAI Chat Completions-compatible endpoint served by [vLLM](https://github.com/vllm-project/vllm)
- Qwen/Qwen3-Coder-Next across 2 GPUs with tensor parallelism and tool-calling support
- Runs natively under systemd — no Docker layer

## Requirements

- A GPU server with **NVIDIA drivers already installed** (Verda 2xA100, 2xH100, or similar). The pip `vllm` wheels bundle the CUDA runtime, so no CUDA toolkit install is needed — but the driver must be present.
- `HF_TOKEN` set to a HuggingFace token for gated model downloads.

## How it works

| Phase | Command |
| --- | --- |
| preStart | installs [uv](https://astral.sh/uv) |
| build | `uv venv && uv pip install -r requirements.txt` (installs vLLM) |
| start | `uv run vllm serve Qwen/Qwen3-Coder-Next --tensor-parallel-size 2 …` |

## Tuning

- **GPU count:** change `--tensor-parallel-size` in `startCmd` to match the number of GPUs on your server.
- **Model:** replace `Qwen/Qwen3-Coder-Next` in `startCmd` with any vLLM-supported model.

## Usage

```bash
curl https://<your-app-url>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Qwen/Qwen3-Coder-Next", "messages": [{"role": "user", "content": "Hello"}]}'
```
