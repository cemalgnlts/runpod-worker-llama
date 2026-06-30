FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update --yes --quiet && \
    apt-get install --yes --quiet --no-install-recommends \
        software-properties-common \
        gpg-agent \
        netcat-openbsd \
        ca-certificates && \
    add-apt-repository --yes ppa:deadsnakes/ppa && \
    apt-get update --yes --quiet && \
    # install python
    apt-get install --yes --quiet --no-install-recommends \
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        build-essential && \
    # setup pip
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    # clear
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV HF_CACHE_ROOT="/runpod-volume/huggingface-cache/hub"

ENV LLAMA_CACHE="$HF_CACHE_ROOT"
ENV LLAMA_ARG_SPEC_TYPE="ngram-simple"
ENV LLAMA_ARG_CACHE_TYPE_K="q8_0"
ENV LLAMA_ARG_CACHE_TYPE_V="q8_0"
ENV LLAMA_ARG_N_GPU_LAYERS="all"
ENV LLAMA_ARG_CTX_SIZE="32768"
ENV LLAMA_ARG_FLASH_ATTN="on"
ENV LLAMA_ARG_REASONING="off"
ENV LLAMA_ARG_PORT="5000"

WORKDIR /work

COPY ./src/requirements.txt /work/requirements.txt
RUN pip install -r /work/requirements.txt

COPY ./src /work
RUN chmod +x /work/start.sh
RUN mkdir -p "$HF_CACHE_ROOT"

EXPOSE 80

ENTRYPOINT ["/bin/bash", "-c", "/work/start.sh"]