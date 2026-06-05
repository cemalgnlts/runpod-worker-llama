class JobInput:
    def __init__(self, job):
        self.prompt = job.get("prompt", job.get("messages"))
        self.stream = job.get("stream", False)
        self.openai_route = job.get("openai_route")
        self.openai_input = job.get("openai_input")