# Olares One RTX 5090 AI Workstation Setup

**High-performance dual-boot AI rig optimized for RTX 5090 Mobile (Blackwell sm_120)**

A complete, production-ready guide for setting up a powerful local AI workstation with **shared models**, **fast scratch storage**, **Olares containers**, and **maximum performance** using SageAttention + PyTorch nightly.

---

## ✨ Features

- Dual-boot **Windows 11** + **Olares OS**
- Shared NTFS model library across both OSes
- Dedicated NVMe scratch partition for temp/cache
- Optimized for **RTX 5090 Mobile** (SageAttention ~30-35% faster diffusion)
- Olares Market-first containerized apps where possible
- Unified launchers + dashboard
- Mambaforge isolated environments
- Full FP8 / NVFP4 readiness

---


# 🛠 Hardware
- System: Olares One
- Storage: Dual 4TB NVMe + 10TB USB NAS
- GPU: NVIDIA RTX 5090 Mobile (Blackwell sm_120)
- RAM: 96GB+ recommended
# 📀 Disk Layout
### NVMe 1 (4TB) — Olares + Shared Models

| Partition | Size | Filesystem | Purpose |
|-----------|------|------------|---------|
|EFI (shared)|512MB|FAT32|Bootloader|
|Root (/)|100GB|ext4|Olares OS|
|Swap|48GB|swap|GPU offloading|
|MODELS|~3.4TB|NTFS|Shared models|
### NVMe 2 (4TB) — Windows + Scratch

| Partition | Size | Filesystem | Purpose |
|-----------|------|------------|---------|
|Windows|250GB|NTFS|Windows 11|
|Apps/Games|~500GB|NTFS|Optional|
|SCRATCH|~3.2TB|NTFS|Temp / Cache|

# 📁 Folder Structure (Shared Models)
``` Bash
D:\AI\Models\          # or /mnt/models/
├── LLM/
├── SD/
├── Video/
└── Tools/
```
# 🔧 Installation Steps
###### Install Olares OS first, then Windows 11 (shared EFI partition).
###### Create and label NTFS partitions (MODELS and SCRATCH).
###### Mount shared drives (see docs/fstab.example).
###### Run setup.bat (Windows) or the master script (Olares).
###### Install applications using the table below.
###### Copy extra_model_paths.yaml to ComfyUI root.
###### Run symlinks.sh in Olares.
## 📥 Downloads & Installation

### Core Applications

| Application              | Official Link                                                                 | Recommended Install Method                          | Notes |
|--------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------|-------|
| **ComfyUI**              | [ComfyUI](https://github.com/comfy-org/ComfyUI)                              | `git clone` or portable desktop app                | Use `extra_model_paths.yaml` + install `comfy-kitchen` |
| **Ostris AI-Toolkit**    | [ai-toolkit](https://github.com/ostris/ai-toolkit)                           | `git clone` + submodules                           | Dedicated `aitools` Mamba env |
| **Ollama**               | [ollama.com/download](https://ollama.com/download)                           | Official installer                                 | Custom model path: `D:\AI\Models\LLM` or `/mnt/models/LLM` |
| **Fooocus**              | [Fooocus](https://github.com/lllyasviel/Fooocus)                             | `git clone` + `run.bat` (portable)                | Portable preferred |
| **InvokeAI**             | [InvokeAI](https://github.com/invoke-ai/InvokeAI)                            | Official launcher / installer                      | Portable recommended |
| **StabilityMatrix**      | [lykos.ai](https://lykos.ai/) • [GitHub](https://github.com/LykosAI/StabilityMatrix) | Official installer (best option)                   | Great central manager for ComfyUI, Fooocus, InvokeAI |
| **SillyTavern**          | [SillyTavern](https://github.com/SillyTavern/SillyTavern)                    | `git clone` (release branch)                       | Standard clone |
| **LM Studio**            | [lmstudio.ai/download](https://lmstudio.ai/download)                         | Official installer                                 | Excellent GUI for GGUF models |

### Quick Clone Commands
```bash
git clone https://github.com/comfy-org/ComfyUI.git
git clone https://github.com/ostris/ai-toolkit.git && cd ai-toolkit && git submodule update --init --recursive
git clone https://github.com/lllyasviel/Fooocus.git
git clone https://github.com/invoke-ai/InvokeAI.git
git clone https://github.com/SillyTavern/SillyTavern.git -b release
```
Tip: Start with StabilityMatrix — it can install and manage ComfyUI, Fooocus, and InvokeAI with one click while still allowing custom model paths.

# 📚 References
## SageAttention Blackwell 
- https://github.com/mobcat40/sageattention-blackwell
## Olares Documentation
- https://docs.olares.com/
