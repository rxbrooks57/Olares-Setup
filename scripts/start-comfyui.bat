@echo off
setlocal EnableDelayedExpansion

echo.
echo ==============================================
echo   ComfyUI RTX 5090 Blackwell Launcher
echo ==============================================
echo.

:: ====================== CONFIG ======================
set "COMFY=C:\ComfyUI"
set "SCRATCH=D:\AI\Scratch"

set "COMFYUI_TEMP=%SCRATCH%\comfy-temp"
set "TORCH_HOME=%SCRATCH%\torch-cache"
set "HF_HOME=%SCRATCH%\hf-cache"
set "TMP=%SCRATCH%\comfy-temp"
:: ===================================================

:: Check ComfyUI folder exists
if not exist "%COMFY%" (
    echo [ERROR] ComfyUI not found at %COMFY%
    echo        Please clone it first or update the COMFY path.
    pause
    exit /b 1
)

:: Check scratch drive
if not exist "%SCRATCH%" (
    echo [WARNING] Scratch folder D:\AI\Scratch not found. Creating...
    mkdir "%SCRATCH%" 2>nul
)

:: Create cache/temp folders
mkdir "%COMFYUI_TEMP%" 2>nul
mkdir "%TORCH_HOME%" 2>nul
mkdir "%HF_HOME%" 2>nul

echo [OK] Environment paths configured.

:: ====================== OPTIMIZATIONS ======================
echo.
echo === Applying RTX 5090 Blackwell Optimizations ===
set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512
set CUDA_DEVICE_MAX_CONNECTIONS=1
set TORCH_CUDNN_V8_API_ENABLED=1

:: Activate venv (if it exists)
if exist "%COMFY%\venv\Scripts\activate.bat" (
    call "%COMFY%\venv\Scripts\activate.bat"
) else (
    echo [WARNING] Virtual environment not found. Running with system Python...
)

:: Apply Torch settings
echo Applying Torch Blackwell settings...
python -c "
import torch
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True
torch.backends.cudnn.benchmark = True
torch.set_float32_matmul_precision('high')
print('✓ Torch config applied for Blackwell')
print(f'CUDA Available: {torch.cuda.is_available()}')
print(f'Device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"None\"}')
" 2>nul || echo [WARNING] Could not apply Torch settings.

echo.
echo Launching ComfyUI on http://127.0.0.1:8188
echo (Press Ctrl+C to stop)
echo.

python "%COMFY%\main.py" --listen 0.0.0.0 --port 8188 --extra-model-paths-config "%COMFY%\extra_model_paths.yaml"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] ComfyUI exited with error code %errorlevel%
    echo Check the logs above for details.
    pause
)

endlocal
