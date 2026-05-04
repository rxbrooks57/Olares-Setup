from flask import Flask, render_template_string
import subprocess
import webbrowser

app = Flask(__name__)

TEMPLATE = """
<!doctype html>
<html><head><title>Olares AI Dashboard</title>
<style>body{font-family:Arial;background:#111;color:#0f0;}</style>
</head><body>
<h1>🚀 Olares One AI Dashboard</h1>
<h2>Quick Launch</h2>
<ul>
  <li><a href="/start/comfy">Start ComfyUI</a></li>
  <li><a href="/start/lmstudio">Start LM Studio</a></li>
  <li><a href="/start/fooocus">Start Fooocus</a></li>
  <li><a href="/open/ollama">Open Ollama WebUI</a></li>
</ul>
<h2>GPU Status (RTX 5090)</h2>
<pre>{{ gpu_status }}</pre>
<p><a href="/update">Refresh Status</a></p>
</body></html>
"""

def get_gpu_status():
    try:
        out = subprocess.check_output(["nvidia-smi", "--query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu", "--format=table"], 
                                      stderr=subprocess.STDOUT, text=True)
        return out
    except Exception as e:
        return f"nvidia-smi error: {e}"

@app.route("/")
def index():
    return render_template_string(TEMPLATE, gpu_status=get_gpu_status())

@app.route("/start/comfy")
def start_comfy():
    subprocess.Popen(r"C:\ComfyUI\start-comfyui.bat", shell=True)
    return "ComfyUI starting..."

@app.route("/start/lmstudio")
def start_lmstudio():
    subprocess.Popen(r"C:\Users\%USERNAME%\AppData\Local\Programs\LM Studio\LM Studio.exe", shell=True)
    return "LM Studio starting..."

@app.route("/start/fooocus")
def start_fooocus():
    subprocess.Popen(r"C:\Fooocus\run.bat", shell=True)
    return "Fooocus starting..."

@app.route("/open/ollama")
def open_ollama():
    webbrowser.open("http://localhost:11434")
    return "Ollama opened"

if __name__ == "__main__":
    print("AI Dashboard running at http://localhost:5050")
    app.run(host="0.0.0.0", port=5050)