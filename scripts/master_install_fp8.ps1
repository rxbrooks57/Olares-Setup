# master_install_fp8.ps1 - Enhanced RTX 5090 Blackwell Installer
param([switch]$SkipChecks)

Write-Host "=== Olares One RTX 5090 Master Installer (FP8 + SageAttention) ===" -ForegroundColor Green

# ========================= CONFIGURATION =========================
$SAGE_WHEEL = "https://github.com/mobcat40/sageattention-blackwell/releases/latest/download/sageattention-2.2.0+cu128.torch2.11-cp311-cp311-win_amd64.whl"
$TORCH_INDEX = "https://download.pytorch.org/whl/nightly/cu128"
$PYTHON_VER = "3.11"

$MAMBA_ROOT = "$env:USERPROFILE\mambaforge"
$MAMBA_EXE = "$MAMBA_ROOT\Scripts\mamba.exe"
# ================================================================

# ====================== PRE-FLIGHT CHECKS ======================
if (-not $SkipChecks) {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[ERROR] This script must be run as Administrator!" -ForegroundColor Red
        exit 1
    }

    try {
        Invoke-WebRequest -Uri "https://www.google.com" -Method Head -TimeoutSec 5 | Out-Null
    } catch {
        Write-Host "[ERROR] No internet connection detected." -ForegroundColor Red
        exit 1
    }

    $nvidia = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" }
    if ($nvidia) {
        Write-Host "✓ NVIDIA GPU detected: $($nvidia.Name)" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] No NVIDIA GPU detected!" -ForegroundColor Yellow
        $cont = Read-Host "Continue anyway? (y/N)"
        if ($cont -notlike "y*") { exit 1 }
    }
}

# ====================== MAMBAFORGE ======================
if (-not (Test-Path $MAMBA_ROOT)) {
    Write-Host "Installing Mambaforge..." -ForegroundColor Cyan
    try {
        $installer = "$env:TEMP\Mambaforge.exe"
        Invoke-WebRequest -Uri "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Windows-x86_64.exe" -OutFile $installer -ErrorAction Stop
        Start-Process -FilePath $installer -ArgumentList "/S /AddToPath=1" -Wait -ErrorAction Stop
        Write-Host "✓ Mambaforge installed" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Mambaforge installation failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ====================== HELPER FUNCTIONS ======================
function Make-Env {
    param($Name)
    Write-Host "`n=== Creating environment: $Name ===" -ForegroundColor Cyan
    try {
        & $MAMBA_EXE create -n $Name "python=$PYTHON_VER" -y --quiet
        & $MAMBA_EXE run -n $Name pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX
        Write-Host "✓ Environment $Name created" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[ERROR] Failed to create $Name : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ====================== MAIN INSTALLATION ======================
try {
    # SageAttention
    $SAGE_DIR = "$env:USERPROFILE\sageattention-blackwell"
    if (-not (Test-Path $SAGE_DIR)) {
        Write-Host "Cloning SageAttention repo..." -ForegroundColor Cyan
        git clone https://github.com/mobcat40/sageattention-blackwell $SAGE_DIR
    }

    # 1. ComfyUI
    if (Make-Env "comfy") {
        & $MAMBA_EXE run -n comfy pip install $SAGE_WHEEL comfy-kitchen
        $COMFY_DIR = "$env:USERPROFILE\ComfyUI"
        if (-not (Test-Path $COMFY_DIR)) {
            git clone https://github.com/comfyanonymous/ComfyUI.git $COMFY_DIR
        }
        & $MAMBA_EXE run -n comfy pip install -r "$COMFY_DIR\requirements.txt"
    }

    # 2. Ostris AI-Toolkit
    if (Make-Env "aitools") {
        $AIKIT_DIR = "$env:USERPROFILE\ai-toolkit"
        if (-not (Test-Path $AIKIT_DIR)) {
            git clone https://github.com/ostris/ai-toolkit.git $AIKIT_DIR
            cd $AIKIT_DIR; git submodule update --init --recursive
        }
        & $MAMBA_EXE run -n aitools pip install -r "$AIKIT_DIR\requirements.txt"
    }

    # 3. StabilityMatrix
    if (Make-Env "stability") {
        & $MAMBA_EXE run -n stability pip install $SAGE_WHEEL
    }

    # 4. SillyTavern + LLM
    if (Make-Env "llm") {
        & $MAMBA_EXE run -n llm pip install vllm transformers accelerate sentencepiece
    }

} catch {
    Write-Host "`n[CRITICAL] Installation failed at some point." -ForegroundColor Red
    Write-Host "You can resume with: .\master_install_fp8.ps1 -SkipChecks" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n==============================================" -ForegroundColor Green
Write-Host "✅ ALL ENVIRONMENTS INSTALLED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=============================================="
Write-Host "Environments: comfy, aitools, stability, llm"
Write-Host "Next: Update paths in start-comfyui.bat and launch via dashboard."
