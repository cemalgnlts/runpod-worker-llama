#!/bin/bash

echo "start.sh: Begin";

set -e -o pipefail

# llama-server serves the OpenAI-compatible API directly on the main PORT.
# health.py answers RunPod's /ping && /health on PORT_HEALTH.
export LLAMA_ARG_PORT="${PORT:-80}"
export PORT_HEALTH="${PORT_HEALTH:-8080}"

cleanup() {
    echo "start.sh: Cleaning up..."

    if [ -n "$HEALTH_PID" ]; then
        kill $HEALTH_PID 2>/dev/null || true
    fi

    if [ -n "$LLAMA_SERVER_PID" ]; then
        echo "start.sh: Killing llama-server (PID: $LLAMA_SERVER_PID)..."
        kill $LLAMA_SERVER_PID 2>/dev/null || true
    fi

    exit
}

trap cleanup SIGINT SIGTERM

# Start the health server first so /ping returns 204 (initializing) while the
# model loads, instead of refusing connections.
echo "start.sh: Starting health server on port $PORT_HEALTH..."
python -u health.py &
HEALTH_PID=$!

echo "start.sh: Starting llama-server on port $LLAMA_ARG_PORT... Cache Folder: $LLAMA_CACHE"

mkdir -p "$LLAMA_CACHE"

LD_LIBRARY_PATH=/app /app/llama-server \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui &

LLAMA_SERVER_PID=$!

# Keep the container alive; exit when llama-server exits.
wait $LLAMA_SERVER_PID
