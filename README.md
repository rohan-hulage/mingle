# Mingle

**Make every conversation flow.**

Mingle is a Flutter messaging assistant with a FastAPI reply API. The mobile app runs independently with sample replies; configure the backend to use OpenAI. Mingle does not read other apps or send messages automatically.

## What is included

- Flutter Material 3 app for Android and iOS, with an animated intro, onboarding, home, reply studio, favorites, history and settings.
- Reply studio with ten tones, three lengths, four languages, optional user context, three suggestion cards, copy/edit/favorite/regenerate actions.
- Local preferences and favorite replies. Reply history is opt-in and off by default; disabling it deletes saved history. Original conversation text is never persisted by the app.
- FastAPI `POST /api/v1/replies/generate`; OpenAI and mock provider implementations behind a provider abstraction.
- Android native IME module that accepts explicitly typed context, requests suggestions from the API and inserts only a tapped reply.
- iOS keyboard-extension source and `Info.plist` manifest template. It inserts only user-entered text and does not request Full Access.

## Project structure

```text
lib/
  app/                 App startup, splash, navigation
  models/              Reply request/result and saved reply models
  services/            HTTP reply API client and offline sample provider
  state/               Local preferences, favorites, history and UI state
  ui/
    screens/           Onboarding, home, reply studio, saved replies, settings
    widgets/           Brand and reusable UI pieces
    theme.dart         Light/dark Material 3 design system
backend/
  app/main.py          FastAPI routes and CORS
  app/models.py        Validated API schemas
  app/services/        Mock and OpenAI reply providers
  tests/               API validation and response tests
android/               Flutter host and registered Kotlin IME service
ios/MingleKeyboard/    Swift keyboard extension source and Info.plist template
```

## Run the API

Python 3.9+ is required.

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

With `OPENAI_API_KEY` unset, the API returns clearly marked mock suggestions. Set the key in `backend/.env` to enable OpenAI; `OPENAI_MODEL` defaults to `gpt-4o-mini`. The key stays on the server and is never included in the mobile app. The API does not log or persist submitted messages.

Run backend tests from the `backend/` directory:

```bash
pytest
```

`DATABASE_URL` is reserved for a future account-scoped PostgreSQL repository. This MVP deliberately has no server-side user data or message persistence; app preferences and favorites stay on-device.

## Run the Flutter app

```bash
flutter pub get
# Android emulator:
flutter run --dart-define=MINGLE_API_URL=http://10.0.2.2:8000
# iOS simulator:
flutter run --dart-define=MINGLE_API_URL=http://localhost:8000
```

If the API is unreachable, the app uses local sample replies. To point a physical device at a development server, use its LAN address in `MINGLE_API_URL` and allow that device through the host firewall.

The Android manifest permits cleartext HTTP for local development. Use an HTTPS API and disable cleartext traffic before a production release.

## Keyboard modules

### Android

The native keyboard service is registered in the app manifest. Install the app, then enable **Mingle keyboard** in Android Settings → System → Keyboard → On-screen keyboard. Start with the emulator API URL shown above; for a physical device, change `MingleInputMethodService.kt`'s development endpoint to a reachable HTTPS API. The keyboard never reads text around the cursor; users type or paste context into its own field, then tap a suggestion to insert it.

### iOS

The extension source is under `ios/MingleKeyboard/`, but the extension target is not embedded in the generated Runner Xcode project. In Xcode, add a **Custom Keyboard Extension** target, replace its generated controller with `KeyboardViewController.swift`, and use the provided `Info.plist` settings. Sign both Runner and the extension with the same team, then enable Mingle under Settings → General → Keyboard → Keyboards. The starter extension does not request Full Access; consequently it only inserts text typed into its own field and does not call the network API. Apple requires Full Access for keyboard network access, which should be a separate, explicit privacy decision before connecting it to AI generation.

## Verify

```bash
flutter analyze
flutter test
cd backend && pytest
```
