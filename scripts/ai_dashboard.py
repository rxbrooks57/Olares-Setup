from flask import Flask, render_template_string, jsonify
import subprocess
import webbrowser
import os
import sys

app = Flask(__name__)

TEMPLATE = """
<!doctype html>
<html><head><title>Olares AI Dashboard</title>
<style>
    body{font-family:Arial;background:#111;color:#0f0;margin:20px;}
    a{color:#0ff;text-decoration:none;}
    a:hover{color:#fff;}
    pre{background:#222;padding:10px;border-radius:5px;}
</style>
</head><body>
<h1>🚀 Olares One AI Dashboard</h1>
<h2>Quick Launch</h2>
<ul>
  <li><a href="/start/comfy">Start ComfyUI</a></li>
  <li><a href="/start/lmstudio">Start LM Studio</a></li>
  <li><a href="/start/fooocus">Start Fooocus</a></li>
  <li><a href="/open/ollama">Open Ollama WebUI</a></li>
  <li><a href="/open/models">Open Models Folder</a></li>
</ul>
<h2>GPU Status (RTX 5090)</h2>
<pre>{{ gpu_status }}</pre>
<p><a href="/update">🔄 Refresh Status</a></p>
</body></html>
"""

def get_gpu_status():
    try:
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu",
             "--format=table,noheader"],
            stderr=subprocess.STDOUT, text=True, timeout=5
        )
        return out.strip()
    except FileNotFoundError:
        return "nvidia-smi not found. Install NVIDIA drivers."
    except subprocess.TimeoutExpired:
        return "nvidia-smi timeout."
    except Exception as e:
        return f"GPU error: {e}"

@app.route("/")
def index():
    return render_template_string(TEMPLATE, gpu_status=get_gpu_status())

@app.route("/start/comfy")
def start_comfy():
    try:
        path = r"C:\ComfyUI\start-comfyui.bat"  # Update if your path differs
        if os.path.exists(path):
            subprocess.Popen(path, shell=True)
            return "ComfyUI starting..."
        return "ComfyUI start script not found."
    except Exception as e:
        return f"Error: {e}"

@app.route("/start/lmstudio")
def start_lmstudio():
    try:
        path = os.path.expandvars(r"%LOCALAPPDATA%\Programs\LM Studio\LM Studio.exe")
        if os.path.exists(path):
            subprocess.Popen(path, shell=True)
            return "LM Studio starting..."
        return "LM Studio not found."
    except Exception as e:
        return f"Error: {e}"

@app.route("/start/fooocus")
def start_fooocus():
    try:
        path = r"C:\Fooocus\run.bat"
        if os.path.exists(path):
            subprocess.Popen(path, shell=True)
            return "Fooocus starting..."
        return "Fooocus not found."
    except Exception as e:
        return f"Error: {e}"

@app.route("/open/ollama")
def open_ollama():
    webbrowser.open("http://localhost:11434")
    return "Opened Ollama WebUI"

@app.route("/open/models")
def open_models():
    subprocess.Popen('explorer "D:\\AI\\Models"')
    return "Opened Models folder"

@app.route("/update")
def update():
    return index()

if __name__ == "__main__":
    print("🚀 AI Dashboard running at http://localhost:5050")
    print("   (Press Ctrl+C to stop)")
    app.run(host="0.0.0.0", port=5050, debug=False)
