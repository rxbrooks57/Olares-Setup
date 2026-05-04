@echo off
echo.
echo ==============================================
echo   OLARES ONE RTX 5090 AI SETUP LAUNCHER
echo ==============================================
echo.

:: Check for Administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    echo Right-click setup.bat ^& select "Run as administrator"
    pause
    exit /b 1
)

:: Check Internet connectivity
echo [CHECK] Internet connection...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] No internet connection detected. Please connect and try again.
    pause
    exit /b 1
)

:: Check NVIDIA Drivers
echo [CHECK] NVIDIA Drivers...
powershell -NoProfile -Command "Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like '*NVIDIA*' }" >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] No NVIDIA GPU detected or drivers may not be installed.
    echo Please install latest NVIDIA Studio/Game Ready drivers before continuing.
    pause
)

echo.
echo 1. Creating model folders...
powershell -ExecutionPolicy Bypass -File scripts\create-model-folders.ps1
if %errorLevel% neq 0 (
    echo [ERROR] Folder creation failed. Check the PowerShell output above.
    pause
    exit /b 1
)

echo.
echo 2. Mounting models partition...
powershell -ExecutionPolicy Bypass -File scripts\mount-models.ps1
if %errorLevel% neq 0 (
    echo [ERROR] Mount failed. See above for details.
    pause
    exit /b 1
)

echo.
echo 3. Installing Mambaforge + All AI Environments...
powershell -ExecutionPolicy Bypass -File scripts\master_install_fp8.ps1
if %errorLevel% neq 0 (
    echo [ERROR] Master install failed. Check the PowerShell log above.
    pause
    exit /b 1
)

echo.
echo ==============================================
echo ✅ SETUP COMPLETE!
echo ==============================================
echo.
echo Next steps:
echo   • Boot into Olares and run symlinks.sh
echo   • Copy extra_model_paths.yaml
echo   • Launch AI Dashboard: python scripts\ai_dashboard.py
echo.
pause
explorer "D:\AI\Models"
