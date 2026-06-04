#!/bin/bash

set -e -o pipefail

cleanup() {
    echo "start.sh: Cleaning up..."
    pkill -P $$ # Kill all child processes of the current script
    exit 0
}

# Trap exit signals and call the cleanup function
trap cleanup SIGINT SIGTERM

pgrep llama-server | xargs kill

export LLAMA_ARG_HF_REPO="unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL"
export LLAMA_ARG_ALIAS="qwen3.5-9b"
export LLAMA_ARG_CTX_SIZE=131072
export LLAMA_ARG_N_GPU_LAYERS=99
export LLAMA_ARG_FLASH_ATTN="on"
export LLAMA_ARG_KV_UNIFIED="on"
export LLAMA_ARG_N_PARALLEL=4
export LLAMA_ARG_PORT=5000

touch llama.server.log

# Start the llama server and log its output
LD_LIBRARY_PATH=/app  /app/llama-server \
  --reasoning off \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui 2>&1 | tee "llama.server.log" &

OLLAMA_PID=$! # Store the process ID (PID) of the background command

tries_so_far=0

check_server_is_running() {
    echo "Checking if server is running..."

    if cat llama.server.log | grep -q "llama_server: model loaded"; then
        return 0 # Success
    else
        return 1 # Failure
    fi

    tries_so_far=$((tries_so_far + 1))

    if [ $tries_so_far -ge 120 ]; then
        echo "start.sh: Error: llama-server did not start within 60 seconds."
        exit 1
    fi

    # check if the process is still running
    if ! kill -0 $LLAMA_SERVER_PID 2>/dev/null; then
        echo "start.sh: Error: llama-server process has exited unexpectedly."
        exit 1
    fi
}

echo "start.sh: Waiting for llama-server to start..."

# Wait for the server to start
while ! check_server_is_running; do
    sleep 0.5
done

python -u handler.py $1