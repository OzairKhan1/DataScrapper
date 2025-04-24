@echo off
set REPO_URL=https://github.com/OzairKhan1/DataScrapper.git
set REPO_NAME=DataScrapper


echo Cloning the repository...
git clone %REPO_URL%
cd %REPO_NAME%

:: Download and install Python silently
echo Installing Python...
curl -o python-installer.exe https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe
start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

:: Make sure python works
python --version

:: Create virtual environment
echo Creating virtual environment...
python -m venv .venv

:: Activate virtual environment
call .venv\Scripts\activate

:: Install requirements
echo Installing required Python packages...
pip install --upgrade pip
pip install -r requirements.txt

:: Run the Streamlit app
echo Running the Streamlit app...
streamlit run wap10.py

pause
