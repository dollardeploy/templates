from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import httpx
import requests
import json

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

OLLAMA_API_URL = "http://ollama:11434/api/generate"

@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    prompt = data.get("prompt", "")

    payload = {
        "model": "gpt-oss",
        "prompt": prompt,
        "stream": False
    }

    timeout = httpx.Timeout(60.0, connect=10.0)  

    async with httpx.AsyncClient(timeout=timeout) as client:
        try:
            response = await client.post(OLLAMA_API_URL, json=payload)
            result = response.json()
        except Exception as e:
            return {"response": f"Error: {str(e)}"}

    return {"response": result.get("response", "No response from model.")}

@app.post("/stream")
async def chat(request: Request):
    data = await request.json()
    prompt = data.get("prompt", "")

    payload = {
        "model": "gpt-oss",
        "prompt": prompt,
        "stream": True
    }

    async def generate():
        """
        generate is an asynchronous function that generates a streaming response to a given prompt.
        It uses the Ollama API to generate the streaming response.
        """
        try:
            response = requests.post(url, json=data, stream=True)
            for line in response.iter_lines():
                if line:
                    yield line + b'\n'
        except requests.exceptions.RequestException as e:
            yield json.dumps({"error": str(e)}).encode() + b'\n'
    
    return StreamingResponse(generate(), media_type="application/x-ndjson")

