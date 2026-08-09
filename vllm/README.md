# vLLM (native)

Run an OpenAI-compatible inference endpoint with vLLM natively via systemd — no Docker.

> **Experimental template.** Verify the deployment on your own GPU server before relying on it.

## What you get

- An OpenAI Chat Completions-compatible endpoint served by [vLLM](https://github.com/vllm-project/vllm)
- Qwen/Qwen3-Coder-Next across 2 GPUs with tensor parallelism and tool-calling support
- Runs natively under systemd — no Docker layer

## Requirements

- A GPU server with **NVIDIA drivers already installed** (Verda 2xA100, 2xH100, or similar). No CUDA toolkit install is needed — but the driver must be present.
- `HF_TOKEN` set to a HuggingFace token for gated model downloads.

## How it works

Dependencies are declared in a native uv [`pyproject.toml`](./pyproject.toml) and installed with `uv sync`.

| Phase | Command |
| --- | --- |
| preStart | installs [uv](https://astral.sh/uv) |
| start | `uv sync && uv run vllm serve Qwen/Qwen3-Coder-Next --tensor-parallel-size 2 …` |

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
development headers Triton needs to JIT-compile Qwen3-Next's linear-attention kernels (the host's
`/usr/bin/python3` has none, so the build fails with `fatal error: Python.h: No such file or
directory`). Because the systemd unit runs with a read-only filesystem, `startCmd` points uv's
Python install dir and the uv/Triton caches at the app's writable, backup-excluded `cache/`
directory (`UV_PYTHON_INSTALL_DIR`, `UV_CACHE_DIR`, `TRITON_CACHE_DIR`).

GPU device access is granted to the service via `SYSTEMD_PRIVATE_DEVICES=false` (a private `/dev`
would hide `/dev/nvidia*`).

## Tuning

- **GPU count:** change `--tensor-parallel-size` in `startCmd` to match the number of GPUs on your server.
- **Model:** replace `Qwen/Qwen3-Coder-Next` in `startCmd` with any vLLM-supported model.

## Usage

```bash
curl https://<your-app-url>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Qwen/Qwen3-Coder-Next", "messages": [{"role": "user", "content": "Hello"}]}'
```
