# Runpod Llama.cpp Worker

The fastest and most up-to-date inference template

## How to use

Start a runpod serverless with the docker container `cemalgnlts/runpod-llama:latest`.

[![Runpod](https://api.runpod.io/badge/cemalgnlts/runpod-worker-llama)](https://console.runpod.io/hub/cemalgnlts/runpod-worker-llama)

## Environment variables

### Basic

| Variable Name       | Description            | Default Value                          |
| ------------------- | ---------------------- | -------------------------------------- |
| `LLAMA_ARG_HF_REPO` | HF model repository    | unsloth/Qwen3.5-9B-MTP-GGUF:UD-Q4_K_XL |
| `LLAMA_ARG_ALIAS`   | Set model name aliases | qwen3.5-9b                             |

### Advanced

All varaibles: https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md

## Test

```
{
  "prompt": "ping"
}
```

See the [test_inputs](./test_inputs) directory for example test requests.

## Licence

This project is licensed under the MIT License. You are free to use, share, and adapt the material for any purpose, even commercially, under the following terms:

- **Attribution**: You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- **Reference**: You must reference the original repository at [https://github.com/svenbrnn/runpod-worker-Llama](https://github.com/svenbrnn/runpod-worker-Llama).

For more details, see the [license](https://creativecommons.org/licenses/by/4.0/).
