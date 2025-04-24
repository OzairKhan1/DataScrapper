@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set REPO_NAME=DataScrapper
set GIT_URL=https://github.com/OzairKhan1/DataScrapper.git
set DEST_PATH=%USERPROFILE%\Documents\%REPO_NAME%

echo ====================================================
echo  🚀 Updating and Launching App
echo ====================================================

if not exist "%DEST_PATH%" (
    echo 📁 Cloning new repository...
    git clone %GIT_URL% "%DEST_PATH%"
) else (
    echo 🔄 Updating existing repo...
    cd /d "%DEST_PATH%"
    git pull
)

cd /d "%DEST_PATH%"

:: If venv does not exist, create it
if not exist "venv\" (
    echo 🛠️ Creating virtual environment...
    python -m venv venv
)

:: Activate virtual environment
call venv\Scripts\activate.bat

:: Upgrade pip
python -m pip install --upgrade pip

:: Install/update requirements
pip install -r requirements.txt

:: Launch app
streamlit run DataScrapper.py

ENDLOCAL
pause
