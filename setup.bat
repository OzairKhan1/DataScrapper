@echo off
setlocal ENABLEDELAYEDEXPANSION

set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper
set REPO_DIR=%~dp0%REPO_NAME%

:: STEP 1: Check if Git is installed
echo 🔍 Checking Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⬇️ Installing Git...
    curl -L -o git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo ✅ Git installed. Please restart the script.
    pause
    exit /b
)

:: STEP 2: Clone or pull repository
if not exist "%REPO_DIR%" (
    echo 📁 Cloning repository...
    git clone %REPO_URL%
) else (
    echo 🔄 Pulling latest changes from repository...
    cd /d "%REPO_DIR%"
    git pull
    cd /d "%~dp0%"
)

:: Move into repo folder
cd /d "%REPO_DIR%"

:: STEP 3: Check if Python is installed
echo 🔍 Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⬇️ Installing Python...
    curl -L -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    echo ✅ Python installed. Please restart the script.
    pause
    exit /b
)

:: STEP 4: Create virtual environment if it doesn't exist
if not exist ".venv\" (
    echo 🛠️ Creating virtual environment...
    python -m venv .venv
)

:: STEP 5: Activate venv and install requirements
call .venv\Scripts\activate

:: Install/update packages if needed
echo 📦 Installing/updating Python packages...
pip install --upgrade pip setuptools wheel
pip install --only-binary=:all: -r requirements.txt

:: STEP 6: Run the app
if not exist "DataScrapper.py" (
    echo ❌ File 'DataScrapper.py' not found!
    pause
    exit /b
)

echo 🚀 Launching Streamlit app...
streamlit run DataScrapper.py

pause
