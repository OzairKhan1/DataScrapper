@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper
set DEST_PATH=%USERPROFILE%\Documents\%REPO_NAME%

echo ====================================================
echo  🚀 Updating and Launching App
echo ====================================================

:: STEP 1: Check for Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Installing...
    curl -L -o git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo ✅ Git installed. Please re-run this file.
    pause
    exit /b
)

:: STEP 2: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Installing...
    curl -L -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    echo ✅ Python installed. Please re-run this file.
    pause
    exit /b
)

:: STEP 3: Clone or pull repo
if not exist "%DEST_PATH%" (
    echo 📁 Cloning repository...
    git clone %REPO_URL% "%DEST_PATH%"
) else (
    echo 🔄 Updating repository...
    cd /d "%DEST_PATH%"
    git reset --hard
    git clean -fd
    git pull
)

cd /d "%DEST_PATH%"

:: STEP 4: Create and activate venv
if not exist "venv\" (
    echo 🛠️ Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat

:: STEP 5: Install/update requirements (only if needed)
if not exist "venv\Lib\site-packages\streamlit" (
    echo 📦 Installing dependencies...
    python -m pip install --upgrade pip setuptools wheel
    pip install -r requirements.txt
) else (
    echo ✅ Dependencies already installed.
)

:: STEP 6: Kill any running Streamlit (optional)
taskkill /f /im streamlit.exe >nul 2>&1

:: STEP 7: Run the app
echo 🚀 Launching Streamlit app...
streamlit run DataScrapper.py

ENDLOCAL
pause
