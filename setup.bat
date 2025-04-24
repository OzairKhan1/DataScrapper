@echo off
setlocal
set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper

:: STEP 1: Ensure Git is available
echo Checking if Git is installed...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Installing Git...
    curl -L -o git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo Git installation finished.
    echo.
    echo 🚨 Please CLOSE this command prompt window and run this file again.
    echo This is needed to refresh the system PATH.
    pause
    exit /b
)

:: STEP 2: Clone the repo
if not exist "%REPO_NAME%" (
    echo Cloning the repository...
    git clone %REPO_URL%
) else (
    echo Repo already exists. Skipping clone.
)
cd /d "%~dp0%REPO_NAME%"

:: STEP 3: Install Python if missing
echo Checking if Python is installed...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Downloading and installing Python...
    curl -L -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    echo Python installation complete.
    echo 🚨 Please CLOSE this window and run this file again so Python can be detected.
    pause
    exit /b
)

:: STEP 4: Create virtual environment
echo Creating virtual environment...
python -m venv .venv
call .venv\Scripts\activate

:: STEP 5: Install dependencies (force binaries where possible)
echo Installing Python packages...
pip install --upgrade pip setuptools wheel
pip install --only-binary=:all: -r requirements.txt

:: STEP 6: Check for app file
if not exist "DataScrapper.py" (
    echo ❌ File 'DataScrapper.py' not found in the directory.
    echo Please ensure the file exists or rename your app script.
    pause
    exit /b
)

:: STEP 7: Launch app
echo Launching Streamlit app...
streamlit run DataScrapper.py

pause
