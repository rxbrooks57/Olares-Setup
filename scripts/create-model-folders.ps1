# create-model-folders.ps1 - Enhanced with checks
Write-Host "=== Creating AI Model Folder Structure ===" -ForegroundColor Green

# Admin check
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

$base = "D:\AI\Models"
$scratch = "D:\AI\Scratch"

# Check D: drive exists
if (-not (Test-Path "D:\")) {
    Write-Host "[ERROR] D: drive (MODELS) not found. Mount it first." -ForegroundColor Red
    exit 1
}

try {
    $folders = @(
        "$base\LLM\llama3", "$base\LLM\mistral", "$base\LLM\qwen", "$base\LLM\deepseek", "$base\LLM\embeddings",
        "$base\SD\checkpoints", "$base\SD\vae", "$base\SD\lora", "$base\SD\controlnet", "$base\SD\upscale", "$base\SD\embeddings",
        "$base\Video\svd", "$base\Video\animatediff", "$base\Video\runway", "$base\Video\audio",
        "$base\Tools\ComfyUI", "$base\Tools\Fooocus", "$base\Tools\InvokeAI", "$base\Tools\Whisper", "$base\Tools\TTS"
    )

    foreach ($folder in $folders) {
        New-Item -ItemType Directory -Force -Path $folder -ErrorAction Stop | Out-Null
    }

    # Scratch folders
    New-Item -ItemType Directory -Force -Path "$scratch\comfy-temp" | Out-Null
    New-Item -ItemType Directory -Force -Path "$scratch\torch-cache" | Out-Null
    New-Item -ItemType Directory -Force -Path "$scratch\hf-cache" | Out-Null

    Write-Host "✅ Folder structure created successfully at $base" -ForegroundColor Green
    Write-Host "   Scratch space ready at $scratch" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to create folders: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
