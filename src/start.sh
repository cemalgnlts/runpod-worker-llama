#!/bin/bash

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

pgrep llama-server | xargs -r kill -9

export LLAMA_ARG_HF_REPO="unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL"
export LLAMA_ARG_ALIAS="qwen3.5-9b"
export LLAMA_ARG_CTX_SIZE=131072
export LLAMA_ARG_N_GPU_LAYERS=99
export LLAMA_ARG_FLASH_ATTN="on"
export LLAMA_ARG_KV_UNIFIED="on"
export LLAMA_ARG_N_PARALLEL=4
export LLAMA_ARG_PORT=5000

touch llama.server.log

echo "start.sh: Starting llama-server..."

LD_LIBRARY_PATH=/app /app/llama-server \
  --reasoning off \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui 2>&1 | tee "llama.server.log" &

LLAMA_SERVER_PID=$!

tries_so_far=0

check_server_is_running() {
    tries_so_far=$((tries_so_far + 1))

    if [ $tries_so_far -ge 120 ]; then
        echo "start.sh: Error: llama-server did not start within 60 seconds."
        exit 1
    fi

    if ! kill -0 $LLAMA_SERVER_PID 2>/dev/null; then
        echo "start.sh: Error: llama-server process has exited unexpectedly."
        echo "--- LAST LOGS ---"
        tail -n 20 llama.server.log
        exit 1
    fi

    if grep -q "llama_server: model loaded" llama.server.log; then
        return 0
    else
        return 1
    fi
}

echo "start.sh: Waiting for llama-server to load model..."

while ! check_server_is_running; do
    sleep 0.5
done

echo "start.sh: llama-server is ready! Starting handler.py..."

python -u handler.py $1