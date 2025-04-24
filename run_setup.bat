@echo off
setlocal
set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper

echo.
echo 📥 Checking if Git is installed...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git not found. Downloading and installing Git...
    curl -L -o git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo ✅ Git installation completed.
) else (
    echo ✅ Git is already installed.
)

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo ❗ Git still not detected. Please restart the command prompt and re-run this file.
    pause
    exit /b
)

echo.
echo 🔁 Cloning your GitHub repository...
git clone %REPO_URL%
cd %REPO_NAME%

echo.
echo 🐍 Checking if Python is installed...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found. Downloading and installing Python...
    curl -L -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    echo ✅ Python installation completed.
) else (
    echo ✅ Python is already installed.
)

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo ❗ Python still not detected. Please restart the command prompt and re-run this file.
    pause
    exit /b
)

echo.
echo ⚙️ Setting up virtual environment...
python -m venv .venv
call .venv\Scripts\activate

echo.
echo 📦 Installing required Python packages...
pip install --upgrade pip
pip install -r requirements.txt

echo.
echo 🚀 Launching the Streamlit app...
streamlit run wap10.py

pause
