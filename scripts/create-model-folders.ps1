# create-model-folders.ps1
Write-Host "=== Creating AI Model Folder Structure ===" -ForegroundColor Green

$base = "D:\AI\Models"

$folders = @(
    "$base\LLM\llama3", "$base\LLM\mistral", "$base\LLM\qwen", "$base\LLM\deepseek", "$base\LLM\embeddings",
    "$base\SD\checkpoints", "$base\SD\vae", "$base\SD\lora", "$base\SD\controlnet", "$base\SD\upscale", "$base\SD\embeddings",
    "$base\Video\svd", "$base\Video\animatediff", "$base\Video\runway", "$base\Video\audio",
    "$base\Tools\ComfyUI", "$base\Tools\Fooocus", "$base\Tools\InvokeAI", "$base\Tools\Whisper", "$base\Tools\TTS"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}

New-Item -ItemType Directory -Force -Path "D:\AI\Scratch\comfy-temp" | Out-Null
New-Item -ItemType Directory -Force -Path "D:\AI\Scratch\torch-cache" | Out-Null
New-Item -ItemType Directory -Force -Path "D:\AI\Scratch\hf-cache" | Out-Null

Write-Host "✅ Folder structure created successfully!" -ForegroundColor Green