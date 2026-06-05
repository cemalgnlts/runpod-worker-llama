# Runpod Serverless Runner For Llama.cpp

## How to use

Start a runpod serverless with the docker container ``cemalgnlts/runpod-llama:latest``. Set ``LLAMA_MODEL_NAME`` environment to a model from [hugging face](https://huggingface.co/) to automatically download a model.
A mounted volume will be automatically used.

[![RunPod](https://api.runpod.io/badge/cemalgnlts/runpod-worker-llama)](https://www.runpod.io/console/hub/cemalgnlts/runpod-worker-llama)

## Environment variables

| Variable Name       | Description                              | Default Value       |
|---------------------|------------------------------------------|---------------------|
| `LLAMA_MODEL_NAME`  | The name of the model to download        | unsloth/Qwen35-9B-GGUF:UD-Q4_K_XL                |

## Test requests for runpod.io console

See the [test_inputs](./test_inputs) directory for example test requests. 


## Streaming

Streaming for openai requests are fully working.

## Preload model into the docker image

See the [embed_model](./embed_model/) directory for instructions.

## Licence

This project is licensed under the Creative Commons Attribution 4.0 International License. You are free to use, share, and adapt the material for any purpose, even commercially, under the following terms:

- **Attribution**: You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- **Reference**: You must reference the original repository at [https://github.com/svenbrnn/runpod-worker-Llama](https://github.com/svenbrnn/runpod-worker-Llama).

For more details, see the [license](https://creativecommons.org/licenses/by/4.0/).