import subprocess
import webbrowser
import sys
from pystray import Icon, Menu, MenuItem
from PIL import Image

# === CONFIGURE PATHS HERE ===
COMFY_BAT = r"C:\ComfyUI\start-comfyui.bat"
LMSTUDIO = r"C:\Users\%USERNAME%\AppData\Local\Programs\LM Studio\LM Studio.exe"
FOOOCUS = r"C:\Fooocus\run.bat"
OLLAMA_URL = "http://localhost:11434"
MODELS_DIR = r"D:\AI\Models"

def start_comfy(): subprocess.Popen(COMFY_BAT, shell=True)
def start_lmstudio(): subprocess.Popen(LMSTUDIO, shell=True)
def start_fooocus(): subprocess.Popen(FOOOCUS, shell=True)
def open_ollama(): webbrowser.open(OLLAMA_URL)
def open_models(): subprocess.Popen(f'explorer "{MODELS_DIR}"')
def quit_app(icon, item): icon.stop()

img = Image.new('RGB', (64, 64), color='black')
menu = Menu(
    MenuItem("🚀 Start ComfyUI", start_comfy),
    MenuItem("📱 Start LM Studio", start_lmstudio),
    MenuItem("🎨 Start Fooocus", start_fooocus),
    MenuItem("🌐 Open Ollama", open_ollama),
    MenuItem("📁 Open Models Folder", open_models),
    MenuItem("❌ Exit", quit_app)
)

icon = Icon("AI Launcher", img, "Olares AI Tools", menu)
icon.run()