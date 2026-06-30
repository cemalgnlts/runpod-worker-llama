FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ENV HF_CACHE_ROOT="/runpod-volume/models"
ENV LLAMA_CACHE="/runpod-volume/models"

ENV LLAMA_ARG_CACHE_TYPE_K="q8_0"
ENV LLAMA_ARG_CACHE_TYPE_V="q8_0"
ENV LLAMA_ARG_N_GPU_LAYERS="all"
ENV LLAMA_ARG_CTX_SIZE="131072"
ENV LLAMA_ARG_FLASH_ATTN="on"
ENV LLAMA_ARG_REASONING="off"
ENV LLAMA_ARG_N_PARALLEL="4"

# llama-server binds to PORT (the main app port); health.py listens on PORT_HEALTH.
ENV PORT_HEALTH="8080"
ENV PORT="80"

WORKDIR /work

COPY ./src/requirements.txt /work/requirements.txt
RUN pip install -r /work/requirements.txt

COPY ./src /work
RUN chmod +x /work/start.sh

EXPOSE 80 8080

ENTRYPOINT ["/bin/bash", "-c", "/work/start.sh"]