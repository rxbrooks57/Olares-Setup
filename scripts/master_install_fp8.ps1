# master_install_fp8.ps1 - Full RTX 5090 Blackwell FP8/SageAttention setup for Windows
# Run as Administrator in PowerShell

Write-Host "=== Olares One RTX 5090 Master Installer (Windows) ===" -ForegroundColor Green

# ========================= CONFIGURATION =========================
$SAGE_WHEEL = "https://github.com/mobcat40/sageattention-blackwell/releases/latest/download/sageattention-2.2.0+cu128.torch2.11-cp311-cp311-win_amd64.whl"
# Update URL if newer wheel available
$TORCH_INDEX = "https://download.pytorch.org/whl/nightly/cu128"
$PYTHON_VER = "3.11"
# ================================================================

$MAMBA_ROOT = "$env:USERPROFILE\mambaforge"
$MAMBA_EXE = "$MAMBA_ROOT\Scripts\mamba.exe"

# Install Mambaforge
if (-not (Test-Path $MAMBA_ROOT)) {
    Write-Host "Installing Mambaforge..." -ForegroundColor Cyan
    $installer = "$env:TEMP\Mambaforge.exe"
    Invoke-WebRequest -Uri "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Windows-x86_64.exe" -OutFile $installer
    Start-Process -FilePath $installer -ArgumentList "/S /AddToPath=1" -Wait
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

function Make-Env {
    param($Name)
    Write-Host "=== Creating environment: $Name ===" -ForegroundColor Cyan
    & $MAMBA_EXE create -n $Name "python=$PYTHON_VER" -y
    & $MAMBA_EXE activate $Name
    pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX
}

# SageAttention repo
$SAGE_DIR = "$env:USERPROFILE\sageattention-blackwell"
if (-not (Test-Path $SAGE_DIR)) {
    git clone https://github.com/mobcat40/sageattention-blackwell $SAGE_DIR
}

# 1. ComfyUI
Make-Env comfy
pip install $SAGE_WHEEL
pip install comfy-kitchen

$COMFY_DIR = "$env:USERPROFILE\ComfyUI"
if (-not (Test-Path $COMFY_DIR)) {
    git clone https://github.com/comfyanonymous/ComfyUI.git $COMFY_DIR
}
pip install -r "$COMFY_DIR\requirements.txt"

# 2. Ostris AI-Toolkit
Make-Env aitools
$AIKIT_DIR = "$env:USERPROFILE\ai-toolkit"
if (-not (Test-Path $AIKIT_DIR)) {
    git clone https://github.com/ostris/ai-toolkit.git $AIKIT_DIR
}
cd $AIKIT_DIR
git submodule update --init --recursive
pip install -r requirements.txt

# 3. StabilityMatrix
Make-Env stability
pip install $SAGE_WHEEL
$STAB_DIR = "$env:USERPROFILE\StabilityMatrix"
if (-not (Test-Path $STAB_DIR)) {
    git clone https://github.com/StabilityMatrix/StabilityMatrix.git $STAB_DIR
}
pip install -r "$STAB_DIR\requirements.txt"

# 4. SillyTavern
Make-Env silly
$SILLY_DIR = "$env:USERPROFILE\SillyTavern"
if (-not (Test-Path $SILLY_DIR)) {
    git clone https://github.com/SillyTavern/SillyTavern.git $SILLY_DIR
}

# 5. LLM
Make-Env llm
pip install vllm transformers accelerate sentencepiece

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "✅ ALL ENVIRONMENTS INSTALLED SUCCESSFULLY" -ForegroundColor Green
Write-Host "=============================================="
Write-Host "Environments: comfy, aitools, stability, silly, llm"
Write-Host ""
Write-Host "Run ComfyUI with:" -ForegroundColor Cyan
Write-Host "  mamba activate comfy" 
Write-Host "  cd $COMFY_DIR" 
Write-Host "  python main.py"
Write-Host ""
Write-Host "Remember: Use KJNodes 'Patch Sage Attention' node instead of global flag."