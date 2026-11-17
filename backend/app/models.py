from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


Tone = Literal[
    "friendly",
    "funny",
    "flirty",
    "romantic",
    "professional",
    "casual",
    "confident",
    "witty",
    "polite",
    "sarcastic",
]
Language = Literal["English", "Hinglish", "Hindi", "Marathi"]
Length = Literal["short", "medium", "detailed"]


class GenerationRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    message: str = Field(min_length=1, max_length=2000)
    tone: Tone = "friendly"
    language: Language = "English"
    length: Length = "medium"
    context: str = Field(default="", max_length=500)

    @field_validator("message", "context")
    @classmethod
    def clean_text(cls, value: str) -> str:
        return "".join(
            character
            for character in value
            if character in "\n\t" or ord(character) >= 32
        ).strip()

    @field_validator("message")
    @classmethod
    def message_is_not_blank(cls, value: str) -> str:
        if not value:
            raise ValueError("Message cannot be empty.")
        return value


class ReplySuggestion(BaseModel):
    text: str = Field(min_length=1, max_length=500)
    approach: str = Field(min_length=1, max_length=40)


class GenerationResponse(BaseModel):
    replies: list[ReplySuggestion] = Field(min_length=3, max_length=3)
    provider: Literal["mock", "openai"]
