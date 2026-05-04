#!/bin/bash
# master_install_fp8.sh - Enhanced RTX 5090 Blackwell FP8/SageAttention setup for Olares OS
# Last updated: May 2026

set -e  # Exit on error (but we override with better handling)

echo "=== Olares One RTX 5090 Master Installer (Linux / FP8 + SageAttention) ==="
echo

# ========================= CONFIGURATION =========================
SAGE_WHEEL="https://github.com/mobcat40/sageattention-blackwell/releases/latest/download/sageattention-2.2.0+cu128.torch2.11-cp311-cp311-linux_x86_64.whl"
TORCH_INDEX="https://download.pytorch.org/whl/nightly/cu128"
PYTHON_VER="3.11"

BASE_DIR="$HOME"
MAMBA_ROOT="$HOME/mambaforge"
# ================================================================

# ====================== PRE-FLIGHT CHECKS ======================
echo "[CHECK] Running pre-flight checks..."

# Internet check
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "[ERROR] No internet connection detected. Please connect and retry."
    exit 1
fi

# NVIDIA GPU check
if ! command -v nvidia-smi &> /dev/null; then
    echo "[WARNING] nvidia-smi not found. Drivers may not be installed."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ NVIDIA GPU detected: $(nvidia-smi --query-gpu=name --format=csv,noheader)"
fi

# Disk space check on home (/home)
FREE_SPACE=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
if (( $(echo "$FREE_SPACE < 50" | bc -l 2>/dev/null || echo 0) )); then
    echo "[WARNING] Low disk space on $HOME (<50GB free)"
fi

echo "All checks passed."
echo

# ====================== INSTALL MAMBAFORGE ======================
if [ ! -d "$MAMBA_ROOT" ]; then
    echo "Installing Mambaforge..."
    curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o /tmp/Mambaforge.sh
    bash /tmp/Mambaforge.sh -b -p "$MAMBA_ROOT"
    echo "✓ Mambaforge installed"
fi

# Initialize conda/mamba
source "$MAMBA_ROOT/etc/profile.d/conda.sh"
mamba init bash --quiet

# ====================== HELPER FUNCTIONS ======================
make_env() {
    local NAME=$1
    echo -e "\n=== Creating environment: $NAME ==="
    
    if mamba env list | grep -q "^$NAME "; then
        echo "Environment $NAME already exists. Skipping creation."
        return 0
    fi

    mamba create -n "$NAME" python=$PYTHON_VER -y --quiet || {
        echo "[ERROR] Failed to create environment $NAME"
        return 1
    }

    mamba run -n "$NAME" pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX || {
        echo "[ERROR] Failed to install PyTorch nightly in $NAME"
        return 1
    }

    echo "✓ Environment $NAME ready"
}

# ====================== MAIN INSTALLATION ======================
echo "Starting environment setup..."

# SageAttention repo
if [ ! -d "$BASE_DIR/sageattention-blackwell" ]; then
    echo "Cloning SageAttention Blackwell repo..."
    git clone https://github.com/mobcat40/sageattention-blackwell "$BASE_DIR/sageattention-blackwell" || true
fi

# 1. ComfyUI
make_env comfy
mamba run -n comfy pip install "$SAGE_WHEEL" comfy-kitchen

if [ ! -d "$BASE_DIR/ComfyUI" ]; then
    echo "Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$BASE_DIR/ComfyUI"
fi
mamba run -n comfy pip install -r "$BASE_DIR/ComfyUI/requirements.txt" --extra-index-url $TORCH_INDEX

# 2. Ostris AI-Toolkit
make_env aitools
if [ ! -d "$BASE_DIR/ai-toolkit" ]; then
    git clone https://github.com/ostris/ai-toolkit.git "$BASE_DIR/ai-toolkit"
    cd "$BASE_DIR/ai-toolkit" && git submodule update --init --recursive
fi
mamba run -n aitools pip install -r "$BASE_DIR/ai-toolkit/requirements.txt"

# 3. StabilityMatrix / Video tools
make_env stability
mamba run -n stability pip install "$SAGE_WHEEL"

# 4. SillyTavern + LLM
make_env llm
mamba run -n llm pip install vllm transformers accelerate sentencepiece huggingface_hub

# Final verification
echo ""
echo "=============================================="
echo "✅ ALL ENVIRONMENTS INSTALLED SUCCESSFULLY!"
echo "=============================================="
echo "Environments created: comfy, aitools, stability, llm"
echo "SageAttention wheel: $SAGE_WHEEL"
echo ""
echo "Next steps:"
echo "   1. Run: symlinks.sh"
echo "   2. mamba activate comfy && cd ~/ComfyUI && python main.py --listen"
echo "   3. Use extra_model_paths.yaml for shared models"
echo ""
echo "You can re-run this script safely — it skips existing environments."
