import os

import httpx
import uvicorn
from fastapi import FastAPI, Response

app = FastAPI()

# llama-server runs on the main PORT; we probe its native /health endpoint.
LLAMA_HEALTH_URL = f"http://localhost:{os.getenv('LLAMA_ARG_PORT', '80')}/health"


@app.get("/ping")
async def ping():
    # llama-server: 200 = model loaded/ready, 503 = still loading.
    # RunPod load balancer: 200 = Healthy, 204 = Initializing, other = Unhealthy.
    try:
        async with httpx.AsyncClient() as client:
            res = await client.get(LLAMA_HEALTH_URL, timeout=2)
        return Response(status_code=200 if res.status_code == 200 else 204)
    except Exception:
        # Not reachable yet -> still initializing.
        return Response(status_code=204)


if __name__ == "__main__":
    port = int(os.getenv("PORT_HEALTH", "8080"))
    uvicorn.run(app, host="0.0.0.0", port=port)
