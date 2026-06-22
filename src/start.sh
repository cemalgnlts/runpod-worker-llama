#!/bin/bash

echo "start.sh: Begin";

set -e -o pipefail

cleanup() {
    echo "start.sh: Cleaning up..."

    if [ -n "$LLAMA_SERVER_PID" ]; then
        echo "start.sh: Killing llama-server (PID: $LLAMA_SERVER_PID)..."
        kill $LLAMA_SERVER_PID 2>/dev/null || true
    fi

    exit
}

trap cleanup SIGINT SIGTERM

pgrep llama-server | xargs -r kill -9 || true

echo "start.sh: Starting llama-server... Cache Folder: $LLAMA_CACHE"

LD_LIBRARY_PATH=/app /app/llama-server \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --no-ui &

LLAMA_SERVER_PID=$!

echo "start.sh: Waiting for llama-server to load model..."

secs=0

while true; do
    if nc -z 0.0.0.0 "$LLAMA_ARG_PORT" >/dev/null 2>&1; then
        break
    fi

    sleep 0.5
    secs=$((secs + 1))

    if [ $((secs % 120)) -eq 0 ] && [ $secs -ne 0 ]; then
        echo "start.sh: Warn: llama-server did not start within $((secs / 2)) sec."
    fi
done

echo "start.sh: llama-server is ready!"

python -u handler.py $1