# 🦖 Questly — Gamified STEM Learning Adventure

Questly is an interactive, gamified K-12 STEM learning platform built with Flutter. It blends curriculum-aligned science and math concepts with hands-on HTML5 simulations, intelligent AI tutoring (Dendy the Dinosaur), voice-enabled multilingual speech synthesis (English, Tamil, Hindi), and an RPG-style progression system (XP, gold coins, badges, and avatars).

---

## 🌟 Key Features

* **Interactive HTML5 Virtual Simulations:**
  * 🧪 **Virtual Chemistry Lab:** Interactive titration and solution experimentation with a real-time 5-stage reaction engine.
  * ⚖️ **PhET Density Simulation:** Buoyancy, mass, and volume discovery lab with step-by-step mission checklists.
  * 🍕 **Fraction Forge Journey:** Visual fraction mechanics, interactive pizza/bar slice visualizers, and mastery progression.
* **Dendy the Dinosaur (AI Companion & Tutor):**
  * Rule-based and pattern-matched NLP responses to student questions.
  * Adaptive facial expressions and reaction states (idle, thinking, happy, surprised, celebrating).
  * Interactive teach-back mode where students explain concepts to Dendy to test conceptual mastery.
* **Multilingual Read-Aloud (Text-To-Speech):**
  * Instant voice narration for all instructions, dialogues, and mission hints.
  * Cross-platform support for **English (`en-US`)**, **Hindi (`hi-IN`)**, and **Tamil (`ta-IN`)**.
* **Gamification & Rewards:**
  * Daily login streaks, reward wheels, and level-up dialogs.
  * Avatar and item collection system with a persistent local repository.
  * Live-updated leaderboard and curriculum roadmap.

---

## 🏗️ Architecture & Orchestration

Questly is engineered for seamless cross-platform execution on both **Flutter Web** and **Android / Mobile** using clean abstraction layers and conditional compilation:

```
Questly
├── android/                   # Native Android wrapper, manifest permissions & Gradle configs
├── assets/                    # Bundled offline assets
│   ├── audio/                 # Sound effects (star pop, clicks, level up, fanfares)
│   ├── fonts/                 # Typography (Fredoka, Google Fonts)
│   ├── images/                # Badges, avatars, illustrations
│   ├── simulations/           # Offline HTML5/JS simulations (PhET Density, Virtual Lab, Fraction Forge)
│   └── vector_ui/             # Modular SVG game UI components
├── lib/
│   ├── core/                  # Service Locator, Themes & Color System
│   ├── models/                # Student, Progress, Activity, Inventory Models
│   ├── repositories/          # SharedPreferences-backed data persistence
│   ├── screens/               # Screen widgets (Roadmap, Lab, Density, Fractions, Auth)
│   ├── services/              # Auth, Localization, NLP, Audio & TTS services
│   └── widgets/               # Reusable UI widgets, Dendy Mascot & Simulation Views
└── web/                       # Web entrypoints and assets
```

### 🔄 Cross-Platform Bridge Architecture

To guarantee identical behavior whether running in a browser or inside an Android APK without web servers, Questly uses **conditional imports**:

1. **Interactive Simulations (`lib/widgets/interactive_sim_view.dart`)**:
   * **Web (`interactive_sim_web.dart`):** Embeds simulations using browser `HtmlElementView` (`<iframe>`) and listens to `window.onMessage`.
   * **Mobile (`interactive_sim_stub.dart`):** Runs offline simulations inside `webview_flutter` using `loadFlutterAsset()`. It injects a two-way JavaScript bridge (`QuestlyBridge`) so simulation events (`QUESTLY_LAB_EVENT`, `QUESTLY_GAME_COMPLETE`) bridge directly into Flutter state.

2. **Read-Aloud TTS (`lib/services/read_aloud_service.dart`)**:
   * **Web (`read_aloud_web.dart`):** Dispatches speech using the Web Speech Synthesis API (`window.speechSynthesis`).
   * **Mobile (`read_aloud_stub.dart`):** Synthesizes speech using the native Android Text-To-Speech engine via `flutter_tts` mapped to regional BCP-47 locale tags.

3. **Speech Recognition (`lib/services/speech_recognition_helper.dart`)**:
   * **Web (`speech_recognition_web.dart`):** Uses Webkit Speech Recognition.
   * **Mobile (`speech_recognition_stub.dart`):** Gracefully falls back to real-time manual keyboard input if native STT is not configured.

---

## 🚀 Getting Started

### Prerequisites
* **Flutter SDK:** `^3.47.0` (or stable 3.24+)
* **Dart SDK:** `^3.13.0`
* **Android SDK:** Platform API 34+, Build-Tools 36.0.0
* **CMake:** `3.22.1` (installed via Android SDK Manager)
* **NDK:** `28.2.13676358` (installed via Android SDK Manager)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/25cseb50robindanie/Questly.git
   cd Questly
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android (Device / Emulator):**
   ```bash
   flutter run -d android
   ```

---

## 📦 Building the Android APK

To compile an optimized, self-contained release APK:

```powershell
flutter build apk --release
```

* **Output Location:** `build/app/outputs/flutter-apk/app-release.apk`
* **Installation via ADB:**
  ```powershell
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```

---

## 🤖 Guide for Antigravity AI Agents

If you are an Antigravity agent or autonomous coding assistant collaborating on this codebase:

1. **State & Dependency Injection:**
   * Questly uses a centralized service locator in [`lib/core/locator.dart`](file:///c:/Danie's/Projects/Questly/lib/core/locator.dart). Always access singleton services and repositories through `Locator.*` (e.g., `Locator.studentRepository`, `Locator.authService`, `Locator.soundService`).

2. **Cross-Platform Compatibility Rule:**
   * **Never** import `dart:html` or `dart:io` unconditionally in shared UI/widget files.
   * Always use the `.stub.dart` / `.web.dart` pattern with `if (dart.library.html)` conditional exports to maintain Web and Mobile compatibility.

3. **Simulation Assets:**
   * Any new HTML5 simulation or game module must be placed in `assets/simulations/<module_name>/` and declared in [`pubspec.yaml`](file:///c:/Danie's/Projects/Questly/pubspec.yaml) under `flutter.assets`.
   * Ensure simulation scripts use `window.parent.postMessage({ type: '...', ... }, '*')` to broadcast events to the Flutter host.

4. **Testing & Code Quality:**
   * Run `dart analyze` before pushing changes.
   * Execute unit tests using `flutter test`.
   * When connected to a live session, use `dtd` and `hot_reload` to push UI updates seamlessly.

---

## 📜 License
Distributed under the MIT License. PhET Interactive Simulations are copyright of the University of Colorado Boulder under CC-BY 4.0.
