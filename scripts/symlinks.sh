#!/bin/bash
# symlinks.sh - Robust shared models symlinking for Olares ↔ Windows
# Run this after mounting the MODELS partition

set -euo pipefail

echo "=== Olares One RTX 5090 Shared Models Symlink Setup ==="
echo

# ========================= CONFIGURATION =========================
MODELS_MOUNT="/mnt/models"
SCRATCH_MOUNT="/mnt/scratch"

COMFY_DIR="$HOME/ComfyUI"
AI_TOOLKIT_DIR="$HOME/ai-toolkit"
# ================================================================

# ====================== PRE-FLIGHT CHECKS ======================
echo "[CHECK] Pre-flight validation..."

if [ ! -d "$MODELS_MOUNT" ] || [ -z "$(ls -A "$MODELS_MOUNT" 2>/dev/null)" ]; then
    echo "[ERROR] MODELS mount point ($MODELS_MOUNT) not found or empty."
    echo "        Mount the NTFS partition first."
    exit 1
fi

echo "✓ MODELS partition detected at $MODELS_MOUNT"

# Create base directories
mkdir -p "$MODELS_MOUNT/AI/Models" "$MODELS_MOUNT/AI/Scratch" 2>/dev/null || true

# ====================== HELPER FUNCTION ======================
create_symlink() {
    local target="$1"
    local link="$2"

    # Remove existing symlink or backup folder
    if [ -L "$link" ]; then
        rm -f "$link"
    elif [ -d "$link" ] || [ -f "$link" ]; then
        echo "[BACKUP] $link exists → renamed to ${link}.bak_$(date +%Y%m%d_%H%M)"
        mv "$link" "${link}.bak_$(date +%Y%m%d_%H%M)"
    fi

    mkdir -p "$(dirname "$link")"
    
    if ln -s "$target" "$link"; then
        echo "✓ Linked: $link → $target"
    else
        echo "[ERROR] Failed to create symlink: $link"
        return 1
    fi
}

# ====================== CREATE SYMLINKS ======================
echo
echo "Creating symlinks..."

# ComfyUI
if [ -d "$COMFY_DIR" ]; then
    create_symlink "$MODELS_MOUNT/AI/Models/SD/checkpoints"  "$COMFY_DIR/models/checkpoints"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/vae"          "$COMFY_DIR/models/vae"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/lora"         "$COMFY_DIR/models/loras"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/controlnet"   "$COMFY_DIR/models/controlnet"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/embeddings"   "$COMFY_DIR/models/embeddings"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/upscale"      "$COMFY_DIR/models/upscale_models"
    create_symlink "$MODELS_MOUNT/AI/Models/LLM"             "$COMFY_DIR/models/llm"
else
    echo "[INFO] ComfyUI not found at $COMFY_DIR"
fi

# AI-Toolkit
if [ -d "$AI_TOOLKIT_DIR" ]; then
    create_symlink "$MODELS_MOUNT/AI/Models" "$AI_TOOLKIT_DIR/models"
fi

# Ollama models
create_symlink "$MODELS_MOUNT/AI/Models/LLM" "$HOME/.ollama/models" 2>/dev/null || true

# Scratch cache
if [ -d "$SCRATCH_MOUNT" ]; then
    create_symlink "$SCRATCH_MOUNT/torch-cache"   "$HOME/.cache/torch"
    create_symlink "$SCRATCH_MOUNT/hf-cache"      "$HOME/.cache/huggingface"
fi

echo
echo "=============================================="
echo "✅ ALL SYMLINKS CREATED SUCCESSFULLY!"
echo "=============================================="
echo "You can re-run this script anytime."
