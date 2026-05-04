@echo off
echo.
echo ==============================================
echo   OLARES ONE RTX 5090 AI SETUP LAUNCHER
echo ==============================================
echo.

echo 1. Creating model folders...
powershell -ExecutionPolicy Bypass -File scripts\create-model-folders.ps1

echo.
echo 2. Mounting models partition...
powershell -ExecutionPolicy Bypass -File scripts\mount-models.ps1

echo.
echo 3. Installing Mambaforge + All AI Environments (this may take 15-40 minutes)...
powershell -ExecutionPolicy Bypass -File scripts\master_install_fp8.ps1

echo.
echo ==============================================
echo Setup complete!
echo.
echo Next steps:
echo   • Run symlinks.sh in Olares OS
echo   • Copy extra_model_paths.yaml to ComfyUI folder
echo   • Start AI Dashboard: python scripts\ai_dashboard.py
echo   • Use tray_launcher.py for system tray
echo.
echo Press any key to open Models folder...
pause >nul
explorer "D:\AI\Models"