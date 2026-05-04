#!/bin/bash
# symlinks.sh - Create symlinks for shared models in Olares OS

set -e

BASE="/mnt/models"
echo "=== Creating symlinks to shared models at $BASE ==="

# ComfyUI
mkdir -p ~/.local/share/comfyui
ln -sfn "$BASE/SD/checkpoints" ~/.local/share/comfyui/checkpoints
ln -sfn "$BASE/SD/vae" ~/.local/share/comfyui/vae
ln -sfn "$BASE/SD/lora" ~/.local/share/comfyui/lora
ln -sfn "$BASE/SD/controlnet" ~/.local/share/comfyui/controlnet
ln -sfn "$BASE/SD/embeddings" ~/.local/share/comfyui/embeddings
ln -sfn "$BASE/SD/upscale" ~/.local/share/comfyui/upscale_models

# LLM
mkdir -p ~/llm
ln -sfn "$BASE/LLM" ~/llm/models

# Video
mkdir -p ~/video
ln -sfn "$BASE/Video" ~/video/models

# Tools
mkdir -p ~/tools
ln -sfn "$BASE/Tools" ~/tools/models

echo "✅ Symlinks created successfully!"
echo "Run: chmod +x symlinks.sh && ./symlinks.sh"