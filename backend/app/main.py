import os
from typing import List

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.models import GenerationRequest, GenerationResponse
from app.services.reply_provider import ProviderError, create_provider

load_dotenv()

app = FastAPI(
    title="Mingle API",
    description="Privacy-first AI reply suggestions for Mingle.",
    version="1.0.0",
)

configured_origins = os.getenv(
    "MINGLE_CORS_ORIGINS",
    "http://localhost:*,http://127.0.0.1:*,http://10.0.2.2:*",
)
origins: List[str] = [
    origin.strip() for origin in configured_origins.split(",") if origin.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?",
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

provider = create_provider()


@app.get("/health")
async def health():
    return {"status": "ok", "provider": provider.name}


@app.post(
    "/api/v1/replies/generate",
    response_model=GenerationResponse,
)
async def generate_replies(request: GenerationRequest) -> GenerationResponse:
    try:
        replies = await provider.generate(request)
    except ProviderError as error:
        raise HTTPException(status_code=502, detail=str(error)) from error
    return GenerationResponse(replies=replies, provider=provider.name)
