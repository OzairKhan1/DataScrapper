@echo off
set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper

:: Check if Git is installed
echo Checking if Git is installed...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Installing Git...
    :: Download and install Git (Windows)
    curl -o git-installer.exe https://git-scm.com/download/win
    start /wait git-installer.exe /VERYSILENT /NORESTART
    echo Git installation completed!
) else (
    echo Git is already installed.
)

:: Clone the repository
echo Cloning the repository...
git clone %REPO_URL%
cd %REPO_NAME%

:: Download and install Python silently (v3.11.8 example)
echo Installing Python...
curl -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

:: Verify Python installation
echo Verifying Python installation...
python --version

:: Create virtual environment
echo Creating virtual environment...
python -m venv .venv

:: Activate virtual environment
call .venv\Scripts\activate

:: Upgrade pip and install required packages
echo Installing required Python packages...
pip install --upgrade pip
pip install -r requirements.txt

:: Run the Streamlit app
echo Running the Streamlit app...
streamlit run wap10.py

pause
