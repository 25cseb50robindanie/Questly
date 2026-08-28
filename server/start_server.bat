@echo off
title Questly Whisper Voice Server
echo ========================================================
echo   Starting Questly OpenAI Whisper Voice & Teach-Back Server
echo ========================================================
echo.

if not exist ".venv" (
    echo Creating Python virtual environment...
    python -m venv .venv
)

call .venv\Scripts\activate
echo Installing dependencies...
pip install -r requirements.txt

echo.
echo Starting FastAPI server on http://localhost:8000 ...
python whisper_service.py
pause
