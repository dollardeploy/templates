from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx

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
