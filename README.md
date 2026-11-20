<p align="center">
  <img src="shuchona_logo.png" alt="SHUCHONA (সূচনা) Official Logo" width="128" />
</p>

# SHUCHONA (সূচনা)

**Offline-First Voice & Vision AI Healthcare, Prescription Safety, Behavioral Wellness, and Community Emergency Companion for Rural Bangladesh**

Built with **Flutter (Material 3)**, **Riverpod**, **GoRouter**, **Hive**, **Firebase (with offline persistence + `DemoFallbackService`)**, and **Gemini Multimodal AI**.

---

## Download & Install on Android (Direct APK)

[![Download SHUCHONA Android APK](https://img.shields.io/badge/Download_APK-SHUCHONA_v1.0.0_(43.3_MB)-0D6E6E?style=for-the-badge&logo=android&logoColor=white)](https://github.com/ftniloy5757/SHUCHONA/raw/main/releases/SHUCHONA-v1.0.0.apk)

- **Direct APK Link:** [releases/SHUCHONA-v1.0.0.apk](https://github.com/ftniloy5757/SHUCHONA/raw/main/releases/SHUCHONA-v1.0.0.apk)
- **Compatibility:** Android 7.0+ (`minSdk 24`, `targetSdk 36` — supports both 64-bit `arm64-v8a` and 32-bit `armeabi-v7a` Android devices)
- **Signing:** Signed Release APK (APK Signature Scheme v2 + v3)
- **SHA-256:** `1edbb7d3aa3ad6060316df30bbb168f78f5de6aa5dafe72c7896a75351d39921`

### Installation Steps on Any Android Phone
1. Tap the **Download APK** button above on your Android device to download `SHUCHONA-v1.0.0.apk`.
2. Open the downloaded file from your browser or **Files** app. If prompted by Android, tap **Settings → Allow from this source** (required once for APKs installed outside Google Play), then tap **Install**.
3. Open **SHUCHONA (সূচনা)** — **Auto-Demo Login** activates immediately after installation so testers can explore every feature right away with zero credentials (you can still inspect Phone OTP, Email login, and Read-Aloud Bangla Consent anytime from the top-right `⋮` menu → *Login & Privacy Consent*).

### Runtime Permissions Requested (On-Demand)
- **Notifications (`POST_NOTIFICATIONS`):** Prompted after onboarding consent for daily Bangla voice dosage alarms and emergency Blood SOS alerts.
- **Microphone (`RECORD_AUDIO`):** Prompted when tapping the voice mic in the Bangla/English AI Chatbot.
- **Camera (`CAMERA`):** Prompted when snapping a handwritten prescription in PrescribeSafe BD (Gallery uses Android's built-in Photo Picker).
- **Location (`ACCESS_COARSE_LOCATION` / `ACCESS_FINE_LOCATION`):** Prompted only when tapping **GPS** in Find Care to sort nearby Upazila Health Complexes by live distance.

---

## Core Architecture (Feature-First Clean Architecture)

```text
lib/
  main.dart
  app.dart
  core/
    theme/            # WCAG AAA Light Clinical Teal (#0D6E6E) & High-Contrast Dark (#090D16 / #38BDF8)
    localization/     # Instant runtime Bangla (বাংলা - default) <-> English switching
    constants/        # Helplines (16263, 999, 109, Kaan Pete Roi), Upazilas, WHO/DGHS system prompts
    offline_sync/     # Hive local cache, sync queue, DemoFallbackService, Gemini AI, local notifications
    tts_stt/          # flutter_tts + speech_to_text (bn_BD / en_US) + animated waveform & Listen buttons
    seed_data/        # 42+ DGDA/DIMS drugs, deterministic DDI matrix, 2 handwritten Rx presets, red flags, clinics, SHG leaderboard, blood donors
    widgets/          # Accessible cards, severity badges, progress rings, mandatory disclaimers, voice FAB shell
    router/           # GoRouter StatefulShellRoute + mandatory onboarding/consent guard
  features/
    onboarding_consent/    # Module 1: Phone OTP / Email / Instant Demo + Audio-Visual Informed Consent
    home_dashboard/        # Hub: Offline Sync Pill, SHG Zero-Trace Guest Mode, Craving SOS, Personalized Guidance
    voice_chatbot/         # Modules 2, 3 & 4: Multilingual Voice STT/TTS WHO-DGHS Chatbot
    womens_symptom_guide/  # Modules 5 & 6: Guided Symptom Triage + Tier 1 Deterministic Red-Flag Gatekeeper
    prescribe_safe/        # Module 7: Vision OCR + DGDA/DIMS RAG + <85% Confidence Gate + DDI + Generic BDT Savings + Bangla Voice Alarms
    habit_tracker/         # Module 8: Build Healthy & Quit Harmful Habits (Jarda/Betel Nut, Smoking, Sugar)
    leaderboard/           # Module 9: Privacy-Safe Floral/Nature Pseudonyms & SHG Village Circles (Weekly Improvement XP)
    blood_alert/           # Module 10: Geofenced Upazila Blood SOS + 90-Day Medical Cooldown Enforcement
    craving_sos/           # Module 11: Full-Screen Calming Modal with 4-4-6 Voice Breathing & Grounding Steps
    mental_wellness/       # Modules 12 & 13: Daily Voice Tips, 5-Emoji Mood Check-in, 7-Day fl_chart Analytics
    find_care/             # Modules 14–17: Offline Upazila Clinics, GPS Proximity, 1-Tap Dialer & Smart Voice Reminders
    admin_dashboard/       # Module 18: Zero-PII NGO / Public Health Impact Dashboard (fl_chart)
```

---

## Running Locally

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run in Live Local/Offline Mode (Zero Config Required)
SHUCHONA includes `DemoFallbackService` and bundled DGDA/DIMS + WHO/DGHS offline clinical RAG datasets, so it boots cleanly without Firebase or API keys:
```bash
flutter run
```

### 3. Enable Live Gemini Multimodal Vision OCR & Conversational AI (Optional)
```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

### 4. Connect Firebase (Optional)
Add your `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) and run `flutterfire configure`. Firestore offline persistence (`persistenceEnabled: true`) activates automatically.

---

## 60-Second Live Demo Walkthrough
1. **Onboarding & Audio Consent:** Tap **"অফলাইন ডেমো মোডে সরাসরি শুরু করুন / Continue in Offline Demo Mode"** → hear the read-aloud Bangla informed data consent → accept & enter.
2. **PrescribeSafe BD (PredictRx):** Open the **PrescribeSafe** tab → tap **Sample 1 (Rahima Begum)** or **Sample 2 (Abdul Karim)** → inspect the red **Duplicate Paracetamol / Aspirin+Naproxen DDI alerts**, **<85% Amber Pharmacist Verification Gate**, **42–47% DGDA Generic Savings in BDT (৳)**, and tap **Set Bangla Voice Dosage Alarms**.
3. **Blood Demand SOS + SHG Leaderboard:** Open **Blood SOS** → tap **Live Demo: Trigger O+ SOS at Savar Health Complex** to simulate geofenced out-of-cooldown donor alerts with Bangla voice playback, then view **SHG Leaderboard** and **NGO / Admin Impact Dashboard (Zero PII)** from the top menu.
