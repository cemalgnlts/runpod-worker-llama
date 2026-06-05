FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update --yes --quiet && \
    apt-get install --yes --quiet --no-install-recommends \
        software-properties-common \
        gpg-agent \
        curl \
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

WORKDIR /work

ENV HF_CACHE_ROOT="/runpod-volume/huggingface-cache/hub"
RUN mkdir -p "$HF_CACHE_ROOT" && \
    curl -L -o "$HF_CACHE_ROOT/Qwen3.5-9B-UD-Q4_K_XL.gguf" https://huggingface.co/unsloth/Qwen3.5-9B-GGUF/resolve/main/Qwen3.5-9B-UD-Q4_K_XL.gguf?download=true

COPY ./src/requirements.txt /work/requirements.txt
RUN pip install -r /work/requirements.txt

COPY ./src /work
RUN chmod +x /work/start.sh

ENTRYPOINT ["/bin/bash", "-c", "/work/start.sh"]