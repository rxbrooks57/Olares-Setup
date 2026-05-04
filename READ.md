# Olares One RTX 5090 AI Workstation Setup

**High-performance dual-boot AI rig optimized for RTX 5090 Mobile (Blackwell)**

A complete, production-ready guide + scripts for setting up a powerful local AI workstation with **shared models across Windows & Olares**, fast scratch storage, robust error handling, and maximum performance using SageAttention + PyTorch nightly.

---

## ✨ Key Features

- Dual-boot **Windows 11** + **Olares OS** with shared EFI
- Shared NTFS model library (no duplication)
- Dedicated high-speed scratch partition for temp/cache
- **Strong pre-flight checks & error handling** in every script
- Optimized for **RTX 5090 Mobile** (SageAttention + FP8/NVFP4 ready)
- Isolated Mambaforge environments on both OSes
- Unified AI Dashboard + System Tray Launcher
- Safe, idempotent symlinks between OSes
- Resume-friendly installation

---

## 🛠 Hardware Target

- **System**: Olares One
- **GPU**: NVIDIA RTX 5090 Mobile (Blackwell)
- **Storage**: Multiple NVMe drives (shared MODELS + SCRATCH)
- **RAM**: 96GB+ recommended

---

## 📀 Recommended Disk Layout

### NVMe 1 (Olares + Shared Models)
| Partition     | Size     | Filesystem | Purpose                  |
|---------------|----------|------------|--------------------------|
| EFI (shared)  | 512MB    | FAT32      | Bootloader               |
| Root (/)      | 100GB    | ext4       | Olares OS                |
| Swap          | 48GB     | swap       | GPU offloading           |
| MODELS        | ~3.4TB   | NTFS       | **Shared AI Models**     |

### NVMe 2 (Windows + Scratch)
| Partition     | Size     | Filesystem | Purpose                  |
|---------------|----------|------------|--------------------------|
| Windows       | 250GB    | NTFS       | Windows 11               |
| SCRATCH       | ~3.2TB   | NTFS       | **Temp / Cache / Scratch** |

---

## 📁 Shared Folder Structure
D:\AI\Models\          # Mounted as /mnt/models/ in Olares
├── LLM/
├── SD/
│   ├── checkpoints
│   ├── vae
│   ├── lora
│   ├── controlnet
│   ├── embeddings
│   └── upscale
├── Video/
└── Tools/
D:\AI\Scratch\         # High-speed temp space
text---

## 🚀 Installation Steps (Updated May 2026)

1. Install **Olares OS** first, then install **Windows 11** (shared EFI).
2. Create and label the NTFS partitions (`MODELS` and `SCRATCH`).
3. Mount the MODELS partition in Olares (see `docs/fstab.example`).
4. **On Windows** → Run `setup.bat` as Administrator.
5. Install your preferred apps (StabilityMatrix recommended).
6. **On Olares** → Run `master_install_fp8.sh`.
7. Run `symlinks.sh` in Olares.
8. Copy `extra_model_paths.yaml` into ComfyUI.
9. Launch everything via `ai_dashboard.py` or the tray launcher.

---

## 📥 Core Scripts (All Enhanced)

| Script                     | OS       | Purpose                              | Key Features |
|---------------------------|----------|--------------------------------------|--------------|
| `setup.bat`               | Windows  | Main launcher                        | Admin, internet, NVIDIA checks |
| `master_install_fp8.ps1`  | Windows  | Mamba + environments                 | Pre-flight, resume (`-SkipChecks`) |
| `master_install_fp8.sh`   | Olares   | Linux Mamba + environments           | Idempotent, safe re-run |
| `create-model-folders.ps1`| Windows  | Folder structure                     | Drive validation |
| `mount-models.ps1`        | Windows  | Assign D: to MODELS                  | Auto drive letter |
| `symlinks.sh`             | Olares   | Shared model symlinks                | Safe backup, idempotent |
| `ai_dashboard.py`         | Windows  | Web dashboard + quick launch         | Live GPU status |
| `tray_launcher.py`        | Windows  | System tray menu                     | One-click tools |

---

## 🛠 Quick Start Commands

**Windows (as Administrator):**
```batch
setup.bat
Olares:
Bashchmod +x master_install_fp8.sh symlinks.sh
./master_install_fp8.sh
./symlinks.sh

📚 Recommended Tools

StabilityMatrix — Best central manager
ComfyUI + comfy-kitchen
Ostris AI-Toolkit
LM Studio / Ollama / Fooocus


⚠️ Important Warnings

Backup your data before repartitioning drives.
Always run Windows scripts as Administrator.
Use ntfs-3g with proper options when mounting in Olares.
Update SageAttention wheel URLs if newer versions are released.


📄 Documentation

docs/fstab.example — How to mount NTFS in Olares
extra_model_paths.yaml — ComfyUI shared models config
scripts/ — All installation scripts


Made for the Olares + RTX 5090 community.
⭐ Star this repo if it helped you!
Issues, PRs, and suggestions are welcome.
