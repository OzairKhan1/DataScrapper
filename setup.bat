@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===
set "REPO_URL=https://github.com/OzairKhan1/DataScrapper.git"
set "REPO_NAME=DataScrapper"
set "PYTHON_INSTALLER=https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
set "GIT_INSTALLER=https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
cd /d "%~dp0"

:: === STEP 1: Ensure Git is installed ===
echo [1/5] Checking if Git is installed...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Installing...
    curl -L -o git-installer.exe %GIT_INSTALLER%
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo Git installation complete.
    echo 🔄 Please CLOSE this window and run this file again to update system PATH.
    pause
    exit /b
)

:: === STEP 2: Clone the repo if not present ===
if not exist "%REPO_NAME%" (
    echo [2/5] Cloning repository...
    git clone %REPO_URL%
) else (
    echo Repo already exists. Skipping clone.
)
cd "%REPO_NAME%"

:: === STEP 3: Check Python ===
echo [3/5] Checking if Python is installed...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Installing...
    curl -L -o python-installer.exe %PYTHON_INSTALLER%
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    echo Python installation complete.
    echo 🔄 Please CLOSE this window and run this file again to detect Python.
    pause
    exit /b
)

:: === STEP 4: Setup virtual environment ===
echo [4/5] Setting up virtual environment...
if not exist ".venv" (
    python -m venv .venv
)
call .venv\Scripts\activate

:: === STEP 5: Install dependencies and run app ===
echo [5/5] Installing required packages...
pip install --upgrade pip
pip install -r requirements.txt

echo ✅ Setup complete. Launching app...
streamlit run wap10.py

pause
