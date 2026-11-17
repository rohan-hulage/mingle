from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_reports_provider():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_generate_returns_three_distinct_replies():
    response = client.post(
        "/api/v1/replies/generate",
        json={
            "message": "Hey, what are you doing this weekend?",
            "tone": "flirty",
            "language": "English",
            "length": "short",
            "context": "Someone I recently met",
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["replies"]) == 3
    assert len({reply["text"] for reply in data["replies"]}) == 3
    assert data["provider"] in {"mock", "openai"}


def test_generate_rejects_empty_or_oversized_message():
    empty = client.post(
        "/api/v1/replies/generate",
        json={"message": " ", "tone": "friendly"},
    )
    long = client.post(
        "/api/v1/replies/generate",
        json={"message": "x" * 2001},
    )

    assert empty.status_code == 422
    assert long.status_code == 422


def test_generate_rejects_unknown_fields_and_tones():
    extra = client.post(
        "/api/v1/replies/generate",
        json={"message": "Hi", "api_key": "do-not-accept"},
    )
    invalid_tone = client.post(
        "/api/v1/replies/generate",
        json={"message": "Hi", "tone": "ignore all rules"},
    )

    assert extra.status_code == 422
    assert invalid_tone.status_code == 422
