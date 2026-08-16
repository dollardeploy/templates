# vLLM (native)

Run an OpenAI-compatible inference endpoint with vLLM natively via systemd — no Docker.

> **Experimental template.** Verify the deployment on your own GPU server before relying on it.

## What you get

- An OpenAI Chat Completions-compatible endpoint served by [vLLM](https://github.com/vllm-project/vllm)
- Qwen/Qwen3.8-27B-FP8 on a single FP8-native GPU with tool-calling support
- Runs natively under systemd — no Docker layer

## Requirements

- A GPU server with **NVIDIA drivers already installed** and **native FP8 support** (Hopper or newer — Verda 1xH200, or scale to 2x/4x/8x for larger models). No CUDA toolkit install is needed — but the driver must be present.
- `HF_TOKEN` set to a HuggingFace token for gated model downloads.

## How it works

Dependencies are declared in a native uv [`pyproject.toml`](./pyproject.toml) and installed with `uv sync`.

| Phase | Command |
| --- | --- |
| preStart | installs [uv](https://astral.sh/uv) |
| start | `uv sync && uv run vllm serve Qwen/Qwen3.8-27B-FP8 --tensor-parallel-size 1 …` |

### PyTorch / driver matching

`UV_TORCH_BACKEND=auto` (also set as `torch-backend = "auto"` in `pyproject.toml`) tells uv to
select the PyTorch CUDA wheels that match the NVIDIA driver installed on the host. Without it, uv
installs a generic CUDA build of torch that fails to initialize NVML on newer drivers (CUDA 12.9 /
13.0), and vLLM aborts device detection with:

```
RuntimeError: Failed to infer device type ... vLLM is running on UnspecifiedPlatform
```

### Managed Python & writable caches

`UV_PYTHON_PREFERENCE=only-managed` makes uv use its own standalone CPython, which ships the
development headers Triton needs to JIT-compile Qwen3.8's linear-attention kernels (the host's
`/usr/bin/python3` has none, so the build fails with `fatal error: Python.h: No such file or
directory`). Because the systemd unit runs with a read-only filesystem, `startCmd` points uv's
Python install dir and the uv/Triton caches at the app's writable, backup-excluded `cache/`
directory (`UV_PYTHON_INSTALL_DIR`, `UV_CACHE_DIR`, `TRITON_CACHE_DIR`).

GPU device access is granted to the service via `SYSTEMD_PRIVATE_DEVICES=false` (a private `/dev`
would hide `/dev/nvidia*`).

## Tuning

- **GPU count:** set `TENSOR_PARALLEL_SIZE` (env) to match the number of GPUs on your server.
- **Model:** set `MODEL_NAME` (env) to any vLLM-supported model, and `MODEL_CALL_PARSER` to its matching tool-call parser (e.g. `qwen3_xml` for Qwen3.x, `glm45` for GLM, `kimi_k2`/`kimi_k3` for Kimi).

### Sizing (FP8, single request)

| Model | Params | GPUs (Verda) |
| --- | --- | --- |
| Qwen/Qwen3.8-27B-FP8 | 27B dense | 1× H200 141GB |
| zai-org/GLM-5.2-FP8 | ~355B MoE | 4× H200 / 4× B200 |
| moonshotai/Kimi-K3 | ~1T MoE | 8× B200 |

## Usage

```bash
curl https://<your-app-url>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Qwen/Qwen3.8-27B-FP8", "messages": [{"role": "user", "content": "Hello"}]}'
```
