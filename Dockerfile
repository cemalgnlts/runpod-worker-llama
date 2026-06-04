FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# RUN apt-get update --yes --quiet && \
#     apt-get install --yes --quiet --no-install-recommends \
#         software-properties-common \
#         gpg-agent \
#         curl \
#         ca-certificates && \
#     add-apt-repository --yes ppa:deadsnakes/ppa && \
#     apt-get update --yes --quiet && \
#     # install python
#     apt-get install --yes --quiet --no-install-recommends \
#         python3.11 \
#         python3.11-dev \
#         python3.11-venv \
#         build-essential && \
#     # setup pip
#     curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
#     ln -sf /usr/bin/python3.11 /usr/bin/python && \
#     ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
#     # clear
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY ./src/requirements.txt /work/requirements.txt
RUN pip install -r /work/requirements.txt

COPY ./src /work
RUN chmod +x /work/start.sh

ENTRYPOINT ["/work/start.sh"]