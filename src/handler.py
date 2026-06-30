import json
import os
from fastapi import FastAPI
from fastapi.responses import JSONResponse, StreamingResponse
from engine import LlamaOpenAiEngine

DEFAULT_MAX_CONCURRENCY = 4
max_concurrency = int(os.getenv("MAX_CONCURRENCY", DEFAULT_MAX_CONCURRENCY))

app = FastAPI()

@app.get("/ping")
async def health_check():
    return {"status": "healthy"}

@app.get("/version")
async def version():
    return "1.0.0"

@app.post("/generate")
async def generate(request: dict):
    engine = LlamaOpenAiEngine()
    result = engine._handle_chat_or_completion_request(request, True)

    if not request.get("stream", False):
        # Engine yields a single dict for non-streaming requests
        async for chunk in result:
            status = 500 if "error" in chunk else 200
            return JSONResponse(content=chunk, status_code=status)

    async def serialize():
        async for chunk in result:
            yield chunk if isinstance(chunk, str) else json.dumps(chunk)

    return StreamingResponse(serialize(), media_type="text/event-stream")

# Original code from vllm runpod_wrapper.py
#async def handler(job):
#    job_input = JobInput(job["input"])
#    engine = OpenAIvLLMEngine if job_input.openai_route else vllm_engine
#    results_generator = engine.generate(job_input)
#    async for batch in results_generator:
#        yield batch

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "80")))

# runpod.serverless.start(
#     {
#         "handler": handler,
#         "concurrency_modifier": lambda _x: max_concurrency,
#         "return_aggregate_stream": True,
#     }
# )