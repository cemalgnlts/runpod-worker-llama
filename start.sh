#!/bin/bash

cleanup() {
    echo "Cleaning up..."
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

# Start the llama server and log its output
/app/llama-server \
  --reasoning off \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui 2>&1 | tee "llama.server.log" &

OLLAMA_PID=$! # Store the process ID (PID) of the background command

check_server_is_running() {
    echo "Checking if server is running..."

    if cat llama.server.log | grep -q "model loaded"; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Wait for the server to start
while ! check_server_is_running; do
    sleep 5
done

# IF $MODEL_NAME is set, make sure to pull the model, else just skip
if [ -z "$LLAMA_MODEL_NAME" ]; then
    echo "No model name provided. Skipping model pull..."
else
    echo "Pulled model $LLAMA_MODEL_NAME..."
    # ollama pull $LLAMA_MODEL_NAME
fi

python -u handler.py $1