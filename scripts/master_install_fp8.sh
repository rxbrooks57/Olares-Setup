#!/bin/bash
# master_install_fp8.sh - Full RTX 5090 Blackwell FP8/SageAttention setup for Olares OS
# Last updated: May 2026 - Uses mobcat40 wheels + cu128

set -e

echo "=== Olares One RTX 5090 Master Installer (Linux) ==="

# ========================= CONFIGURATION =========================
SAGE_WHEEL="https://github.com/mobcat40/sageattention-blackwell/releases/latest/download/sageattention-2.2.0+cu128.torch2.11-cp311-cp311-linux_x86_64.whl"
# Update the URL above if a newer wheel is released

BASE_DIR="$HOME"
TORCH_INDEX="https://download.pytorch.org/whl/nightly/cu128"
PYTHON_VER="3.11"
# ================================================================

# Install Mambaforge
if [ ! -d "$HOME/mambaforge" ]; then
    echo "Installing Mambaforge..."
    curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o Mambaforge.sh
    bash Mambaforge.sh -b -p "$HOME/mambaforge"
fi

source "$HOME/mambaforge/etc/profile.d/conda.sh"
mamba init bash

# Helper function
make_env() {
    local NAME=$1
    echo "=== Creating environment: $NAME ==="
    mamba create -n "$NAME" python=$PYTHON_VER -y
    mamba activate "$NAME"
    pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX
}

# SageAttention repo
if [ ! -d "$BASE_DIR/sageattention-blackwell" ]; then
    git clone https://github.com/mobcat40/sageattention-blackwell "$BASE_DIR/sageattention-blackwell"
fi

# 1. ComfyUI Environment
make_env comfy
pip install "$SAGE_WHEEL"
pip install comfy-kitchen

if [ ! -d "$BASE_DIR/ComfyUI" ]; then
    git clone https://github.com/comfyanonymous/ComfyUI.git "$BASE_DIR/ComfyUI"
fi
pip install -r "$BASE_DIR/ComfyUI/requirements.txt"

# 2. Ostris AI-Toolkit
make_env aitools
git clone https://github.com/ostris/ai-toolkit.git "$BASE_DIR/ai-toolkit" || true
cd "$BASE_DIR/ai-toolkit"
git submodule update --init --recursive
pip install -r requirements.txt

# 3. StabilityMatrix / Video
make_env stability
pip install "$SAGE_WHEEL"
if [ ! -d "$BASE_DIR/StabilityMatrix" ]; then
    git clone https://github.com/StabilityMatrix/StabilityMatrix.git "$BASE_DIR/StabilityMatrix"
fi
pip install -r "$BASE_DIR/StabilityMatrix/requirements.txt"

# 4. SillyTavern
make_env silly
if [ ! -d "$BASE_DIR/SillyTavern" ]; then
    git clone https://github.com/SillyTavern/SillyTavern.git "$BASE_DIR/SillyTavern"
fi

# 5. LLM Runtime
make_env llm
pip install vllm transformers accelerate sentencepiece

# Final verification
echo ""
echo "=============================================="
echo "✅ ALL ENVIRONMENTS INSTALLED SUCCESSFULLY"
echo "=============================================="
echo "Environments created: comfy, aitools, stability, silly, llm"
echo ""
echo "SageAttention wheel used: $SAGE_WHEEL"
echo ""
echo "Next steps:"
echo "  mamba activate comfy && cd ~/ComfyUI && python main.py"
echo "  Run symlinks.sh for shared model paths"
echo "  Use KJNodes 'Patch Sage Attention' node in ComfyUI (recommended)"