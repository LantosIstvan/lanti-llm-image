# lanti-llm-image

## Usage

```sh
$ cd "/mnt/c/www-llm/lanti-llm-image"
$ ./bin/compose.sh bootstrap
$ ./bin/compose.sh up
$ ./bin/compose.sh down
```

## Web Interfaces

- **Stable Diffusion Web UI:** [stable_diffusion_webui](http://localhost:7860)
- **ComfyUI:** [comfyui](http://localhost:8188)

## Tutorials

- **ComfyUI examples:** [ComfyUI_examples](https://comfyanonymous.github.io/ComfyUI_examples/)
- **Professor Patterns** [How to Enable Web Search in Open WebUI](https://www.youtube.com/watch?v=fwscnJu_Md0)
- **NetworkChuck:** [I’m changing how I use AI (Open WebUI + LiteLLM)](https://www.youtube.com/watch?v=nQCOTzS5oU0)

## Useful Linux commands

```sh
# Size of the folders in a directory
$ du -h --max-depth=1 /usr/src/ComfyUI | sort -hr
```

## WSL2

[Configure global settings](https://learn.microsoft.com/en-us/windows/wsl/wsl-config) to maximum memory resource usage at `%UserProfile%\.wslconfig`:

```.wslconfig
# Settings apply across all Linux distros running on WSL 2
[wsl2]

# Limits VM memory to use no more than 28 GB, this can be set as whole numbers using GB or MB
memory=28GB

# Sets amount of swap storage space to 32GB, default is 25% of available RAM
swap=32GB
```

## Repomix

```batch
repomix "C:\www-llm\lanti-llm-chat" --output "C:\www-llm\lanti-llm-chat\repomix-output-llm.md" --style markdown --parsable-style --include-empty-directories --ignore ".git/**,**/*.safetensors,models/**,outputs/**,.editorconfig,.env,.gitignore,repomix-output-llm.md"
```
