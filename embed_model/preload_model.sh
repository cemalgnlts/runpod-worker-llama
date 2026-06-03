#!/bin/bash

# Start the Ollama server in the background
echo "Starting llama server to preload models: $MODEL_NAMES"
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

# Capture the PID of the Ollama server
LLAMA_PID=$!

# Wait for the server to be ready (adjust if necessary)
echo "Waiting for llama server to start..."
sleep 5

# Split the comma-separated model names into an array
IFS=',' read -r -a MODELS <<< "$MODEL_NAMES"

# Loop through each model and pull it
for MODEL_NAME in "${MODELS[@]}"; do
  echo "Pulling model: $MODEL_NAME"
  if ollama pull "$MODEL_NAME"; then
    echo "Successfully pulled model: $MODEL_NAME"
  else
    echo "Failed to pull model: $MODEL_NAME"
    kill $LLAMA_PID
    exit 1
  fi
done

# Stop the Ollama server
echo "Stopping llama server..."
kill $LLAMA_PID

# Wait for the server to terminate
wait $LLAMA_PID

echo "Model preloading complete."
