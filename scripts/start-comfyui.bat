@echo off
setlocal

set COMFY=C:\ComfyUI
set SCRATCH=D:\AI\Scratch

set COMFYUI_TEMP=%SCRATCH%\comfy-temp
set TORCH_HOME=%SCRATCH%\torch-cache
set HF_HOME=%SCRATCH%\hf-cache
set TMP=%SCRATCH%\comfy-temp

mkdir "%COMFYUI_TEMP%" 2>nul
mkdir "%TORCH_HOME%" 2>nul
mkdir "%HF_HOME%" 2>nul

echo === RTX 5090 Optimizations ===
set PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:512
set CUDA_DEVICE_MAX_CONNECTIONS=1

call %COMFY%\venv\Scripts\activate.bat

python -c "
import torch
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True
torch.backends.cudnn.benchmark = True
torch.set_float32_matmul_precision('high')
print('Torch config applied for Blackwell')
" 

python %COMFY%\main.py --listen 0.0.0.0 --port 8188
endlocaldColor Green