import subprocess
import webbrowser
import sys
import os
from pystray import Icon, Menu, MenuItem
from PIL import Image, ImageDraw

# === CONFIGURE PATHS HERE (or use environment variables) ===
COMFY_BAT = r"C:\ComfyUI\start-comfyui.bat"
LMSTUDIO = os.path.expandvars(r"%LOCALAPPDATA%\Programs\LM Studio\LM Studio.exe")
FOOOCUS = r"C:\Fooocus\run.bat"
OLLAMA_URL = "http://localhost:11434"
MODELS_DIR = r"D:\AI\Models"

def safe_start(path, name):
    def action():
        try:
            if os.path.exists(path):
                subprocess.Popen(path, shell=True)
                print(f"Started {name}")
            else:
                print(f"{name} not found at {path}")
        except Exception as e:
            print(f"Error starting {name}: {e}")
    return action

def open_ollama():
    webbrowser.open(OLLAMA_URL)

def open_models():
    try:
        subprocess.Popen(f'explorer "{MODELS_DIR}"')
    except Exception as e:
        print(f"Error opening models: {e}")

def quit_app(icon, item):
    icon.stop()

# Create a simple icon
def create_image():
    image = Image.new('RGB', (64, 64), color='black')
    dc = ImageDraw.Draw(image)
    dc.text((20, 20), "AI", fill='lime')
    return image

menu = Menu(
    MenuItem("🚀 Start ComfyUI", safe_start(COMFY_BAT, "ComfyUI")),
    MenuItem("📱 Start LM Studio", safe_start(LMSTUDIO, "LM Studio")),
    MenuItem("🎨 Start Fooocus", safe_start(FOOOCUS, "Fooocus")),
    MenuItem("🌐 Open Ollama", open_ollama),
    MenuItem("📁 Open Models Folder", open_models),
    MenuItem("❌ Exit", quit_app)
)

icon = Icon("Olares AI", create_image(), "Olares AI Tools", menu)
print("System tray launcher started. Right-click icon for menu.")
icon.run()
