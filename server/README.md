# Questly OpenAI Whisper & Teach-Back Voice Service

A high-performance Python FastAPI service for Speech-to-Text (STT) and Teach-Back concept evaluation in Questly.

## Supported Languages
- **English (`en`)**
- **Tamil (`ta`)**
- **Hindi (`hi`)**
- **Odia (`or`)**

## Quick Start

### 1. Install & Run (Windows)
Double-click `start_server.bat` or run:
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python whisper_service.py
```

### 2. OpenAI Cloud API (Optional)
To use the OpenAI Whisper API instead of local models:
```bash
set OPENAI_API_KEY=your-api-key-here
python whisper_service.py
```

## API Endpoints
- `GET /health`: Check service status.
- `POST /transcribe`: Upload audio file (`WAV`, `WebM`, `MP3`, `M4A`) + `language`.
- `POST /transcribe-base64`: Transcribe base64 encoded audio.
- `POST /teachback/evaluate`: Evaluate student transcript for mastery score and feedback.
