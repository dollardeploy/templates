# vLLM — OpenAI-Compatible Inference Endpoint

## Description

Deploy an OpenAI-compatible REST API using [vLLM](https://github.com/vllm-project/vllm) with GPU acceleration.
This template runs **Qwen/Qwen3-Coder-Next** across 2 GPUs with tensor parallelism and native tool calling support.

Any client that works with the OpenAI SDK can point to this endpoint without code changes:

```python
from openai import OpenAI

client = OpenAI(base_url="http://<your-server>:8080/v1", api_key="none")

response = client.chat.completions.create(
    model="Qwen/Qwen3-Coder-Next",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

## Environment Variables

| Variable | Description |
|---|---|
| `HUGGING_FACE_HUB_TOKEN` | HuggingFace token for downloading gated models |

## Endpoints

| Path | Description |
|---|---|
| `GET /health` | Health check |
| `GET /v1/models` | List available models |
| `POST /v1/chat/completions` | OpenAI-compatible chat endpoint |
| `POST /v1/completions` | OpenAI-compatible completions endpoint |

## Requirements

- 2× NVIDIA A100 / H100 / similar 80GB GPU (tensor-parallel-size 2)
- ~200 GB storage for model weights cache

## Links

- https://github.com/vllm-project/vllm
- https://docs.vllm.ai
- https://huggingface.co/Qwen/Qwen3-Coder-Next
