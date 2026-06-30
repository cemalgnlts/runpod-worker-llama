import os
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from engine import LlamaOpenAiEngine

DEFAULT_MAX_CONCURRENCY = 4
max_concurrency = int(os.getenv("MAX_CONCURRENCY", DEFAULT_MAX_CONCURRENCY))

app = FastAPI()

@app.get("/ping")
async def health_check():
    return {"status": "healthy"}

@app.post("/generate")
async def generate(request: dict):
    engine = LlamaOpenAiEngine()
    job = engine._handle_chat_or_completion_request(request, True)
    return StreamingResponse(job, media_type="text/event-stream")

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