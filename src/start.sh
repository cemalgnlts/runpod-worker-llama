#!/bin/bash

echo "start.sh: Begin";

set -e -o pipefail

cleanup() {
    echo "start.sh: Cleaning up..."

    if [ -n "$LLAMA_SERVER_PID" ]; then
        echo "start.sh: Killing llama-server (PID: $LLAMA_SERVER_PID)..."
        kill $LLAMA_SERVER_PID 2>/dev/null || true
    fi

    exit 0
}

trap cleanup SIGINT SIGTERM

pgrep llama-server | xargs -r kill -9 || true

export LLAMA_ARG_HF_REPO="unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL"
export LLAMA_ARG_ALIAS="qwen3.5-9b"
export LLAMA_ARG_CTX_SIZE=131072
export LLAMA_ARG_N_GPU_LAYERS=99
export LLAMA_ARG_FLASH_ATTN="on"
export LLAMA_ARG_KV_UNIFIED="on"
export LLAMA_ARG_N_PARALLEL=4
export LLAMA_ARG_PORT=5000

echo "start.sh: Starting llama-server..."

LD_LIBRARY_PATH=/app /app/llama-server \
  --reasoning off \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui 2>&1 &

LLAMA_SERVER_PID=$!

echo "start.sh: Waiting for llama-server to load model..."

secs=0

while true; do
    if nc -z 127.0.0.1 "$LLAMA_ARG_PORT" >/dev/null 2>&1; then
        break
    fi

    sleep 1
    secs=$((secs + 1))

    if [ $secs -ge 120 ]; then
        echo "start.sh: Error: llama-server did not start within 120 seconds."
        exit 1
    fi
done

echo "start.sh: llama-server is ready!"

python -u handler.py $1