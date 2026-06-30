import json
import os

from dotenv import load_dotenv
from openai import OpenAI
from utils import JobInput

client = OpenAI(
    base_url=f"http://localhost:{os.getenv('LLAMA_ARG_PORT', '5000')}/v1/",

    # required but ignored
    api_key="llama",
)

class LlamaEngine:
    def __init__(self):
        load_dotenv()
        print ("Engine initialized")

    async def generate(self, job_input):
        model = os.getenv("LLAMA_ARG_ALIAS", "qwen3.5-9b")

        # Eğer gelen prompt düz yazı (string) ise, onu Chat formatına (Messages) çeviriyoruz
        if isinstance(job_input.prompt, str):
            messages = [{"role": "user", "content": job_input.prompt}]
        else:
            messages = job_input.prompt

        openAiJob = JobInput({
            "openai_route": "/v1/chat/completions",
            "openai_input": {
                "model": model,
                "messages": messages,
                "stream": job_input.stream
            }
        })

        print ("Generating response for job_input:", job_input)
        print ("OpenAI job:", openAiJob)
        
        openAIEngine = LlamaOpenAiEngine()
        generate = openAIEngine.generate(openAiJob)

        async for batch in generate:
            yield batch

class LlamaOpenAiEngine(LlamaEngine):
    def __init__(self):
        load_dotenv()
        print ("LlamaOpenAiEngine initialized")
    
    async def generate(self, job_input):
        print("Generating response for job_input:", job_input)

        # Dump job_input to console
        openai_input = job_input.openai_input

        # for now e just mock the response
        if job_input.openai_route == "/v1/models":
            # Async response
            async for response in self._handle_model_request():
                yield response
        elif job_input.openai_route in ["/v1/chat/completions", "/v1/completions"]:
            async for response in self._handle_chat_or_completion_request(openai_input, chat=job_input.openai_route == "/v1/chat/completions"):
                yield response
        else:
            yield {"error": "Invalid route"}

    async def _handle_model_request(self):
        try:
            response = client.models.list()
            # build a json response from the response object
            # SyncPage[Model](data=[Model(id='llama3.2:1b', created=1737206544, object='model', owned_by='library')], object='list')\n
            yield {"object": "list", "data": [model.to_dict() for model in response.data]} 
        except Exception as e:
            yield {"error": str(e)}

    async def _handle_chat_or_completion_request(self, openai_input, chat=False):
        try:
            # Call openai.chat.completions.create or openai.completions.create based on the route
            if chat:
                response = client.chat.completions.create(**openai_input)
            else:
                response = client.completions.create(**openai_input)

            # If streaming is False, we can just return the response
            if not openai_input.get("stream", False):
                yield response.to_dict()
                return

            for chunk in response:
                # Log message to console
                print("Message:", chunk)
                # Return json of the chunk without any line breaks
                yield "data: " + json.dumps(chunk.to_dict(), separators=(',', ':')) + "\n\n"

            yield "data: [DONE]"
        except Exception as e:
            yield {"error": str(e)}