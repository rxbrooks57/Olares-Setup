# master_install_fp8.ps1 - Enhanced with checks & error handling
param([switch]$SkipChecks)

Write-Host "=== Olares One RTX 5090 Master Installer (Windows) ===" -ForegroundColor Green

# ========================= CONFIGURATION =========================
$SAGE_WHEEL = "https://github.com/mobcat40/sageattention-blackwell/releases/latest/download/sageattention-2.2.0+cu128.torch2.11-cp311-cp311-win_amd64.whl"
$TORCH_INDEX = "https://download.pytorch.org/whl/nightly/cu128"
$PYTHON_VER = "3.11"
# ================================================================

$MAMBA_ROOT = "$env:USERPROFILE\mambaforge"
$MAMBA_EXE = "$MAMBA_ROOT\Scripts\mamba.exe"

# ====================== PRE-FLIGHT CHECKS ======================
if (-not $SkipChecks) {
    # Admin check
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[ERROR] Script must be run as Administrator!" -ForegroundColor Red
        exit 1
    }

    # Internet check
    try {
        $test = Invoke-WebRequest -Uri "https://www.google.com" -Method Head -TimeoutSec 5
    } catch {
        Write-Host "[ERROR] No internet connection. Please connect and retry." -ForegroundColor Red
        exit 1
    }

    # NVIDIA check
    $nvidia = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" }
    if (-not $nvidia) {
        Write-Host "[WARNING] No NVIDIA GPU detected!" -ForegroundColor Yellow
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -notlike "y*") { exit 1 }
    } else {
        Write-Host "✓ NVIDIA GPU detected: $($nvidia.Name)" -ForegroundColor Green
    }

    # Disk space check (rough)
    $drive = Get-PSDrive D -ErrorAction SilentlyContinue
    if ($drive -and $drive.Free/1GB -lt 50) {
        Write-Host "[WARNING] Low disk space on D: (<50GB free)" -ForegroundColor Yellow
    }
}

# ====================== INSTALL MAMBAFORGE ======================
if (-not (Test-Path $MAMBA_ROOT)) {
    Write-Host "Installing Mambaforge..." -ForegroundColor Cyan
    try {
        $installer = "$env:TEMP\Mambaforge.exe"
        Invoke-WebRequest -Uri "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Windows-x86_64.exe" `
                         -OutFile $installer -ErrorAction Stop
        Start-Process -FilePath $installer -ArgumentList "/S /AddToPath=1" -Wait -ErrorAction Stop
        Write-Host "✓ Mambaforge installed" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Mambaforge install failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ====================== HELPER FUNCTION ======================
function Make-Env {
    param($Name)
    Write-Host "`n=== Creating environment: $Name ===" -ForegroundColor Cyan
    try {
        & $MAMBA_EXE create -n $Name "python=$PYTHON_VER" -y --quiet
        & $MAMBA_EXE run -n $Name pip install --pre torch torchvision torchaudio --index-url $TORCH_INDEX
        Write-Host "✓ Environment $Name ready" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to create $Name environment: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# ====================== MAIN INSTALLATION ======================
try {
    # SageAttention
    $SAGE_DIR = "$env:USERPROFILE\sageattention-blackwell"
    if (-not (Test-Path $SAGE_DIR)) {
        git clone https://github.com/mobcat40/sageattention-blackwell $SAGE_DIR
    }

    # 1. ComfyUI
    Make-Env "comfy"
    & $MAMBA_EXE run -n comfy pip install $SAGE_WHEEL comfy-kitchen

    # ... (rest of your envs with similar try/catch)

} catch {
    Write-Host "`n[CRITICAL ERROR] Installation failed. See above." -ForegroundColor Red
    Write-Host "You can resume with: .\master_install_fp8.ps1 -SkipChecks" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n==============================================" -ForegroundColor Green
Write-Host "✅ ALL ENVIRONMENTS INSTALLED SUCCESSFULLY" -ForegroundColor Green
Write-Host "=============================================="
