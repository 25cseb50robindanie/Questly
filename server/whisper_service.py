"""
Questly OpenAI Whisper & Teach-Back Voice Service
------------------------------------------------
Provides fast speech-to-text (STT) transcription and AI Teach-Back evaluation
supporting English (en), Tamil (ta), Hindi (hi), and Odia (or).

Usage:
    python whisper_service.py [--port 8000] [--model base]
"""

import os
import io
import sys
import time
import base64
import tempfile
from typing import Optional, List, Dict, Any

try:
    from fastapi import FastAPI, File, UploadFile, Form, HTTPException
    from fastapi.middleware.cors import CORSMiddleware
    from pydantic import BaseModel
    import uvicorn
except ImportError:
    print("FastAPI / Uvicorn not installed. Please run: pip install fastapi uvicorn python-multipart pydantic")
    sys.exit(1)

# Optional OpenAI client for Whisper API
openai_client = None
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
if OPENAI_API_KEY:
    try:
        from openai import OpenAI
        openai_client = OpenAI(api_key=OPENAI_API_KEY)
        print(">> OpenAI API Key detected. Using OpenAI Whisper Cloud API.")
    except ImportError:
        print(">> 'openai' package not installed. Will use local Whisper if available.")

# Optional Local Whisper model
local_whisper_model = None
LOCAL_MODEL_NAME = os.environ.get("WHISPER_MODEL", "base")

def get_local_whisper():
    global local_whisper_model
    if local_whisper_model is None:
        try:
            import whisper
            print(f">> Loading local Whisper model '{LOCAL_MODEL_NAME}'...")
            local_whisper_model = whisper.load_model(LOCAL_MODEL_NAME)
            print(f">> Local Whisper model '{LOCAL_MODEL_NAME}' ready.")
        except Exception as e:
            print(f">> Could not load local whisper package: {e}")
    return local_whisper_model

# Initialize FastAPI App
app = FastAPI(
    title="Questly Whisper Voice Service",
    description="Speech-to-Text and Teach-Back Evaluator for Questly Gamified Learning",
    version="1.0.0"
)

# Enable CORS for Flutter Web & Mobile Clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request Models
class Base64TranscribeRequest(BaseModel):
    audio_base64: str
    format: str = "wav" # wav, webm, mp3, m4a, ogg
    language: Optional[str] = None # en, ta, hi, or
    prompt: Optional[str] = None

class TeachBackEvaluateRequest(BaseModel):
    student_id: Optional[str] = "student"
    module_id: str # e.g. "mod_density", "mod_fractions"
    topic_title: Optional[str] = "Density & Buoyancy"
    transcript: str
    language: str = "en" # en, ta, hi, or

class EvaluationResult(BaseModel):
    mastery_score: int # 0 to 100
    is_passed: bool
    stars: int # 1, 2, or 3
    feedback_title: str
    feedback_body: str
    concepts_identified: List[str]
    missing_concepts: List[str]
    dendy_mood: str # happy, thinking, success, worried

# Language Mapping (Whisper ISO codes)
WHISPER_LANG_MAP = {
    "en": "en",
    "ta": "ta",
    "hi": "hi",
    "or": "or",  # Odia/Oriya
    "ory": "or",
}

def transcribe_audio_bytes(audio_bytes: bytes, file_ext: str = "wav", language: Optional[str] = None, prompt: Optional[str] = None) -> Dict[str, Any]:
    start_time = time.time()
    whisper_lang = WHISPER_LANG_MAP.get(language.lower() if language else "en", language)
    
    # 1. Try OpenAI Cloud Whisper API if key is available
    if openai_client is not None:
        try:
            with tempfile.NamedTemporaryFile(suffix=f".{file_ext}", delete=False) as tmp:
                tmp.write(audio_bytes)
                tmp_path = tmp.name
            
            with open(tmp_path, "rb") as audio_file:
                kwargs = {
                    "model": "whisper-1",
                    "file": audio_file,
                }
                if whisper_lang and whisper_lang != "auto":
                    kwargs["language"] = whisper_lang
                if prompt:
                    kwargs["prompt"] = prompt
                
                resp = openai_client.audio.transcriptions.create(**kwargs)
                duration = time.time() - start_time
                try:
                    os.remove(tmp_path)
                except Exception:
                    pass
                
                return {
                    "text": resp.text.strip(),
                    "language": whisper_lang,
                    "engine": "openai-cloud-whisper",
                    "duration_seconds": round(duration, 3)
                }
        except Exception as e:
            print(f"[OpenAI Whisper API Warning] {e}. Falling back to local model.")

    # 2. Try Local Whisper Model
    model = get_local_whisper()
    if model is not None:
        with tempfile.NamedTemporaryFile(suffix=f".{file_ext}", delete=False) as tmp:
            tmp.write(audio_bytes)
            tmp_path = tmp.name
        
        try:
            kwargs = {}
            if whisper_lang and whisper_lang != "auto":
                kwargs["language"] = whisper_lang
            if prompt:
                kwargs["initial_prompt"] = prompt
            
            result = model.transcribe(tmp_path, **kwargs)
            duration = time.time() - start_time
            return {
                "text": result.get("text", "").strip(),
                "language": result.get("language", whisper_lang),
                "engine": f"local-whisper-{LOCAL_MODEL_NAME}",
                "duration_seconds": round(duration, 3)
            }
        finally:
            try:
                os.remove(tmp_path)
            except Exception:
                pass

    # 3. Fallback mock / simulation for local development without torch
    duration = time.time() - start_time
    return {
        "text": "Density is mass divided by volume, which explains why wood floats and iron sinks.",
        "language": language or "en",
        "engine": "offline-fallback-stub",
        "duration_seconds": round(duration, 3),
        "note": "Install openai-whisper or provide OPENAI_API_KEY for live models."
    }

@app.get("/health")
def health_check():
    return {
        "status": "online",
        "service": "Questly Whisper Voice Service",
        "openai_api_available": openai_client is not None,
        "local_model_loaded": local_whisper_model is not None,
        "supported_languages": ["en", "ta", "hi", "or"]
    }

@app.post("/transcribe")
async def transcribe_file(
    file: UploadFile = File(...),
    language: Optional[str] = Form(None),
    prompt: Optional[str] = Form(None)
):
    try:
        content = await file.read()
        filename = file.filename or "audio.wav"
        ext = filename.split(".")[-1].lower() if "." in filename else "wav"
        return transcribe_audio_bytes(content, file_ext=ext, language=language, prompt=prompt)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")

@app.post("/transcribe-base64")
async def transcribe_base64(req: Base64TranscribeRequest):
    try:
        raw_b64 = req.audio_base64
        if "," in raw_b64:
            raw_b64 = raw_b64.split(",")[1]
        audio_bytes = base64.b64decode(raw_b64)
        return transcribe_audio_bytes(audio_bytes, file_ext=req.format, language=req.language, prompt=req.prompt)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Base64 transcription failed: {str(e)}")

@app.post("/teachback/evaluate", response_model=EvaluationResult)
def evaluate_teach_back(req: TeachBackEvaluateRequest):
    text = req.transcript.lower().strip()
    lang = req.language.lower()
    
    # Concept matching keywords for Density
    density_keywords = {
        "mass": ["mass", "weight", "heavy", "grams", "kg", "எடை", "திணிவு", "द्रव्यमान", "ଭାର", "ଓଜନ"],
        "volume": ["volume", "space", "size", "liters", "ml", "கனஅளவு", "அளவு", "आयतन", "ସ୍ଥାନ", "ଆୟତନ"],
        "density_formula": ["density", "divide", "ratio", "per", "mass divided by volume", "அடர்த்தி", "घनत्व", "ସାନ୍ଦ୍ରତା"],
        "buoyancy": ["float", "sink", "water", "displace", "buoyant", "heavy", "light", "மிதக்கும்", "மூழ்கும்", "तैरना", "ଭାସିବା", "ବୁଡ଼ିବା"],
    }
    
    found_concepts = []
    missing_concepts = []
    
    for concept, terms in density_keywords.items():
        if any(term in text for term in terms):
            found_concepts.append(concept)
        else:
            missing_concepts.append(concept)
    
    score = 40  # base effort score
    score += len(found_concepts) * 15
    if len(text.split()) >= 15:
        score += 10
    score = min(100, score)
    
    stars = 3 if score >= 85 else (2 if score >= 65 else 1)
    is_passed = score >= 60
    
    if is_passed:
        if lang == "ta":
            title = "அற்புதம்! அருமையான விளக்கம்!"
            body = "நீங்கள் அடர்த்தி, திணிவு மற்றும் கனஅளவு பற்றிய கருத்துக்களை மிகச் சரியாக விளக்கியுள்ளீர்கள்!"
        elif lang == "hi":
            title = "शानदार! बेहतरीन व्याख्या!"
            body = "आपने घनत्व, द्रव्यमान और आयतन के सिद्धांतों को बहुत अच्छी तरह समझाया है!"
        elif lang == "or":
            title = "ଚମତ୍କାର! ଉତ୍ତମ ବ୍ୟାଖ୍ୟା!"
            body = "ଆପଣ ସାନ୍ଦ୍ରତା, ବସ୍ତୁତ୍ୱ ଏବଂ ଆୟତନ ବିଷୟରେ ସଠିକ୍ ଭାବରେ ବୁଝାଇଛନ୍ତି!"
        else:
            title = "Fantastic Teaching!"
            body = "You clearly explained how mass and volume determine whether an object floats or sinks!"
        mood = "success"
    else:
        if lang == "ta":
            title = "நல்ல முயற்சி! மேலும் விவரங்களைச் சேர்க்கவும்."
            body = "அடர்த்தி சூத்திரம் (திணிவு ÷ கனஅளவு) மற்றும் மிதக்கும் விசை பற்றி சேர்த்துப் பேசுங்கள்!"
        elif lang == "hi":
            title = "अच्छा प्रयास! कुछ और बातें जोड़ें।"
            body = "घनत्व के सूत्र (द्रव्यमान ÷ आयतन) और उत्प्लावन बल का उल्लेख करने का प्रयास करें।"
        elif lang == "or":
            title = "ଭଲ ପ୍ରୟାସ! ଆଉ କିଛି ତଥ୍ୟ ଯୋଡ଼ନ୍ତୁ।"
            body = "ସାନ୍ଦ୍ରତା ସୂତ୍ର (ଭାର ÷ ଆୟତନ) ଏବଂ ଭାସିବା ବିଷୟରେ ଆହୁରି କିଛି କୁହନ୍ତୁ!"
        else:
            title = "Good Attempt! Add More Details."
            body = "Try mentioning the density formula (mass ÷ volume) and how water displacement creates buoyant force."
        mood = "thinking"
        
    return EvaluationResult(
        mastery_score=score,
        is_passed=is_passed,
        stars=stars,
        feedback_title=title,
        feedback_body=body,
        concepts_identified=found_concepts,
        missing_concepts=missing_concepts,
        dendy_mood=mood
    )

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    print(f">> Starting Questly Whisper Voice Server on http://localhost:{port}")
    uvicorn.run("whisper_service:app", host="0.0.0.0", port=port, reload=True)
