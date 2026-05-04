#!/bin/bash
# symlinks.sh - Create symlinks from Olares to shared Windows NTFS models
# Run this after mounting the MODELS partition and running Windows setup

set -e  # Exit on any error

echo "=== Olares One Shared Models Symlink Setup ==="
echo "RTX 5090 Blackwell Dual-Boot Linker"
echo

# ========================= CONFIGURATION =========================
MODELS_MOUNT="/mnt/models"          # Main shared models mount point
SCRATCH_MOUNT="/mnt/scratch"        # Optional scratch space

COMFY_DIR="$HOME/ComfyUI"
AI_TOOLKIT_DIR="$HOME/ai-toolkit"
# ================================================================

# ====================== PRE-FLIGHT CHECKS ======================
echo "[CHECK] Running pre-flight checks..."

# Check if running as root (not strictly needed but recommended for mounts)
if [ "$(id -u)" -eq 0 ]; then
    echo "[WARNING] Running as root. This is usually not necessary."
fi

# Check internet (for potential git pulls)
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "[WARNING] No internet connection. Symlinks can still be created."
fi

# Check if MODELS partition is mounted
if [ ! -d "$MODELS_MOUNT" ] || [ -z "$(ls -A "$MODELS_MOUNT" 2>/dev/null)" ]; then
    echo "[ERROR] MODELS mount point ($MODELS_MOUNT) not found or empty."
    echo "        Make sure the NTFS partition is mounted (see docs/fstab.example)"
    echo "        Example: sudo mkdir -p $MODELS_MOUNT && sudo mount -t ntfs-3g /dev/nvmeXnY $MODELS_MOUNT"
    exit 1
fi

echo "✓ MODELS partition detected at $MODELS_MOUNT"
echo "✓ Shared models available"

# Create base directories if missing
mkdir -p "$MODELS_MOUNT/AI/Models" "$MODELS_MOUNT/AI/Scratch" 2>/dev/null || true

# ====================== HELPER FUNCTION ======================
create_symlink() {
    local target="$1"
    local link="$2"

    # Remove existing symlink or directory safely
    if [ -L "$link" ]; then
        rm -f "$link"
    elif [ -d "$link" ] || [ -f "$link" ]; then
        echo "[WARNING] $link exists and is not a symlink. Backing up..."
        mv "$link" "${link}.bak_$(date +%Y%m%d_%H%M)"
    fi

    # Create parent directory
    mkdir -p "$(dirname "$link")"

    # Create the symlink
    if ln -s "$target" "$link"; then
        echo "✓ Linked: $link → $target"
    else
        echo "[ERROR] Failed to create symlink: $link"
        return 1
    fi
}

# ====================== CREATE SYMLINKS ======================
echo
echo "Creating symlinks to shared models..."

# ComfyUI symlinks
if [ -d "$COMFY_DIR" ]; then
    create_symlink "$MODELS_MOUNT/AI/Models/SD"           "$COMFY_DIR/models/checkpoints"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/vae"       "$COMFY_DIR/models/vae"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/lora"      "$COMFY_DIR/models/loras"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/controlnet" "$COMFY_DIR/models/controlnet"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/embeddings" "$COMFY_DIR/models/embeddings"
    create_symlink "$MODELS_MOUNT/AI/Models/SD/upscale"   "$COMFY_DIR/models/upscale_models"
    create_symlink "$MODELS_MOUNT/AI/Models/LLM"          "$COMFY_DIR/models/llm"
else
    echo "[INFO] ComfyUI not found at $COMFY_DIR (skipping)"
fi

# AI-Toolkit / Ostris
if [ -d "$AI_TOOLKIT_DIR" ]; then
    create_symlink "$MODELS_MOUNT/AI/Models"              "$AI_TOOLKIT_DIR/models"
else
    echo "[INFO] ai-toolkit not found (skipping)"
fi

# General LLM tools (Ollama, LM Studio via paths, etc.)
create_symlink "$MODELS_MOUNT/AI/Models/LLM"              "$HOME/.ollama/models" 2>/dev/null || true

# Scratch space symlinks (for temp/cache)
if [ -d "$SCRATCH_MOUNT" ]; then
    mkdir -p "$HOME/.cache/torch" "$HOME/.cache/huggingface"
    create_symlink "$SCRATCH_MOUNT/torch-cache"           "$HOME/.cache/torch"
    create_symlink "$SCRATCH_MOUNT/hf-cache"              "$HOME/.cache/huggingface"
fi

echo
echo "=============================================="
echo "✅ SYMLINKS CREATED SUCCESSFULLY!"
echo "=============================================="
echo
echo "Next steps:"
echo "   1. Copy extra_model_paths.yaml to ~/ComfyUI/"
echo "   2. Test ComfyUI: mamba activate comfy && cd ~/ComfyUI && python main.py"
echo "   3. Verify links with: ls -l ~/ComfyUI/models/"
echo
echo "You can re-run this script anytime — it safely updates symlinks."
