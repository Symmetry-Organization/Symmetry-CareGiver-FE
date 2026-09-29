# Clinician App (Symmetry CareGiver)

## 1. Project Overview

### Description

Clinician App is a Flutter mobile application built for home-healthcare clinicians. It lets clinicians manage their daily patient visits, view their schedule/calendar, chat with office staff and other clinicians, make video/audio calls, fill out clinical (OASIS) forms, track timesheets, and view earnings. The app is packaged and shipped under the display name **"Symmetry CareGiver"** and talks to the Symmetry Care backend APIs.

### Key Features

- User authentication (login, registration, forgot/reset password, company selection)
- Home dashboard with today's/upcoming visits
- Live map with clinician location and route-to-patient navigation (Google Maps)
- Calendar / appointment scheduling (Syncfusion calendar + custom calendar widgets)
- Visit details, request/reschedule workflow, pending visit notes
- OASIS clinical form builder (dynamic, multi-section healthcare assessment forms)
- Real-time chat (1:1 and group) with voice notes, images, emoji
- Video/audio calling via Agora RTC, with incoming-call overlay driven by FCM push
- Push notifications (Firebase Cloud Messaging) for chat, calls, and general alerts
- Timesheet management (add/edit visit entries)
- Earnings summary
- Profile management, document upload/update, time-off requests
- PDF/document viewing (Syncfusion & pdfx viewers), file picking, printing

Update this list as features are added or removed.

## 2. Technology Stack

| Layer                  | Technology                                                                                                                                                       |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Framework              | Flutter (Dart SDK `^3.7.0`)                                                                                                                                      |
| Language               | Dart                                                                                                                                                             |
| State Management       | GetX (`get: ^4.7.2`) — controllers + `Obx`/reactive widgets                                                                                                      |
| Local Persistence      | `get_storage` (key-value) — **no Room/SQLite; no relational local database**                                                                                     |
| Networking             | `dio` (REST/JSON), custom auth interceptor for token refresh                                                                                                     |
| Local State (forms)    | `provider` (used specifically for the OASIS form builder)                                                                                                        |
| Push Notifications     | `firebase_messaging`, `firebase_core`, `flutter_local_notifications`                                                                                             |
| Video/Audio Calling    | `agora_rtc_engine`                                                                                                                                               |
| Maps                   | `google_maps_flutter`, `flutter_polyline_points`                                                                                                                 |
| Calendars              | `syncfusion_flutter_calendar`, `mobkit_calendar`, `calendar_date_picker2`                                                                                        |
| Documents/PDF          | `syncfusion_flutter_pdfviewer`, `pdfx`, `printing`, `open_file`, `file_picker`                                                                                   |
| Media                  | `media_kit`, `flutter_vlc_player`, `audioplayers`, `record`, `image_picker`                                                                                      |
| Responsive UI          | `flutter_screenutil` (design size 375×812)                                                                                                                       |
| Build Tool (Android)   | Gradle (Kotlin DSL — `build.gradle.kts`)                                                                                                                         |
| Android Language       | Kotlin (thin native shell only — `MainActivity.kt`)                                                                                                              |
| Compile/Min/Target SDK | Managed by Flutter (`flutter.compileSdkVersion` / `flutter.minSdkVersion` / `flutter.targetSdkVersion` — see `android/local.properties` / Flutter tool defaults) |
| App ID / Package       | `com.clinician.app`                                                                                                                                              |
| Java Compatibility     | Java 11 (core library desugaring enabled)                                                                                                                        |
| NDK Version            | `27.0.12077973`                                                                                                                                                  |
| Version Control        | Git                                                                                                                                                              |

There is **no Hilt/Koin, no Room, no Jetpack Compose, and no native XML UI** — all UI and business logic live in the Flutter/Dart codebase under `lib/`. The `android/` and `ios/` folders are thin platform shells generated/maintained by Flutter tooling.

## 3. Project Architecture

```
UI (Pages/Widgets)
    ↓
GetX Controller (business logic, reactive state)
    ↓
Repository (lib/controller/repository/*)
    ↓
API Service (Dio) / get_storage (local key-value)
```

### Main Layers

**Pages (`lib/pages/`)**
Screens and their local widgets, organized by feature (auth, home, calender_section, profile, request, time_sheet, video_calling, oasis_form_builder).

**Controllers (`lib/controller/`)**
GetX `GetxController` classes responsible for:

- Holding reactive UI state (`.obs` fields)
- Calling repositories to fetch/update data
- Polling (see Key Patterns below)
- Business logic for visits, calendar, calls, chat, timesheet, earnings, notifications, auth

**Repositories (`lib/controller/repository/`)**
One repository per feature area (`calling_repo`, `request_repo`, `calender_repo`, `live_repo`, `chat_repo`, `timesheet_repo`, `notification_repo`, `profile_repo`) — wrap Dio calls to the backend and map JSON responses to models.

**Services (`lib/services/`)**

- `auth_api_services/auth_services.dart` — builds the Dio auth interceptor (token attach + refresh-on-401)
- `token_manager/token_manager_service.dart` — reads/writes auth/session data via `get_storage`
- `chat_notification_service.dart` — local notification channel setup and display for chat messages

**Models (`lib/model/`)**
Plain Dart data classes grouped by feature (`calender/`, `chatScreen/`, `liveMap/`, `notification/`, `profile/`, `request/`, `timesheet/`).

**Core (`lib/core/`)**
Shared constants (`app_colors`, `app_string`, `app_asset`, `app_text_style`, `api_app_constant`, `list_content`), reusable UI widgets/buttons, and common helpers (hex color decoding, base64, audio decoding, calling helpers).

**Utils (`lib/utils/`)**
Global overlay/toast helpers, progress indicators, common methods used across features.

## 4. Project Structure

```
Clinician-App-dev/
│
├── lib/
│   ├── main.dart                  # App entrypoint, Firebase init, FCM listeners, GetMaterialApp
│   ├── firebase_options.dart      # Generated Firebase platform config
│   ├── controller/                # GetX controllers + repository/ subfolder
│   ├── pages/                     # Feature screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── calender_section/
│   │   ├── profile/
│   │   ├── request/
│   │   ├── time_sheet/
│   │   ├── video_calling/
│   │   └── oasis_form_builder/    # Dynamic clinical (OASIS) form engine
│   ├── model/                     # Data models, grouped by feature
│   ├── core/                      # Constants, shared UI widgets, common helpers
│   ├── services/                  # Auth, token storage, notification services
│   └── utils/                     # Global overlays, progress indicators, shared helpers
│
├── android/                       # Flutter-generated Android shell (Kotlin, Gradle KTS)
├── ios/                           # Flutter-generated iOS shell
├── assets/                        # image/, png/, svg/, chat/, fonts/, audio/
├── pubspec.yaml                   # Dart/Flutter dependencies & app version
├── analysis_options.yaml          # Dart lint rules (flutter_lints)
└── README.md
```

## 5. Prerequisites

- **Flutter SDK**: stable channel, compatible with Dart `^3.7.0`
- **Android Studio** or VS Code with Flutter/Dart plugins
- **JDK 11** (matches `compileOptions`/`kotlinOptions` in `android/app/build.gradle.kts`)
- **Android SDK/NDK**: NDK `27.0.12077973`; compile/min/target SDK are resolved automatically from the installed Flutter SDK (`flutter.compileSdkVersion`, etc.)
- **Git**
- A configured **Firebase project** (`google-services.json` already present under `android/app/`) for push notifications
- A valid **Google Maps API key** (currently embedded in `AndroidManifest.xml` and `api_app_constant.dart` — see Important Notes)

## 6. Project Setup

Clone the repository:

```
git clone <repository-url>
cd Clinician-App-dev
```

### Branching

This repo uses many long-lived and feature branches. Notable ones observed in the remote:

- `main` — mainline/default branch
- `production` — production release branch
- `dev-final`, `demo-final` — stabilized dev/demo branches
- `OP-code-demo` — current working branch for this environment
- Feature/fix branches such as `EN-oasis-forms-integration`, `BG-13-14-CareGiver`, `bg-9-clinitian-apk-fixes`, `clinicalByComId`, `notify_feature`, `validation_bugs`, `background-calling`, `ios-android-merge`, etc.

Check out the branch relevant to your task, e.g.:

```
git checkout dev-final
```

Confirm the current active branches with your team before assuming `dev`/`demo`/`production` map 1:1 to environments — naming has evolved over time (see branch list above).

Install dependencies:

```
flutter pub get
```

## 7. Environment Setup

Unlike a native Android project with Gradle product flavors, **this project does not currently define Flutter build flavors**. The API base URL is switched by directly editing `lib/core/constant/api_app_constant.dart` (see below) rather than via build variant. There is a commented-out "dev" configuration and an active "demo" configuration in that file — check with the team before building for a specific backend environment.

| Environment         | API Domain (from `ApiAppConstant`)     | Notes                                        |
| ------------------- | -------------------------------------- | -------------------------------------------- |
| Dev (commented out) | `https://prohealth-dev.symmetry.care/` | Currently disabled in code (commented block) |
| Demo (active)       | `https://greenvalley.symmetry.care/`   | Currently the live/uncommented config        |
| Auth (all envs)     | `https://auth.symmetry.care/`          | Separate auth domain, always active          |

### Where configuration lives

- `lib/core/constant/api_app_constant.dart` — `domain`, `authDomain`, `clinicialBaseUrl`, `clinicialAuthBaseUrl`, `googleApiKey`, and `endPointByAlias(appType, aliasString)` which currently resolves every branch (`clinician`, `proHealth`, default) to the same demo domain
- `pubspec.yaml` → `version:` — Flutter's combined `version+buildNumber` (currently `1.0.2+5007`)
- `android/app/src/main/AndroidManifest.xml` — Google Maps API key meta-data, app label (`Symmetry CareGiver`), permissions
- `android/app/google-services.json` — Firebase Android config (already checked into the repo for this project's setup)

### Important

Do not commit:

- New/rotated API keys or tokens
- Production Firebase credentials for a different project
- Signing keystores or passwords

## 8. API Configuration

### Base URLs

See table in section 7. The base URL and auth URL are defined as static fields in `ApiAppConstant` and consumed by Dio-based repositories/services.

### Authentication

Token-based authentication. On login, tokens are persisted via `TokenManagerService` (backed by `get_storage`). `auth_services.dart` builds a Dio auth interceptor that:

1. Attaches the stored access token to outgoing requests.
2. On a `401`, uses a bare Dio instance (no interceptors) to call the refresh endpoint.
3. Retries the original request with the new token on success, or force-logs-out the user on refresh failure.

### API Headers

```
Authorization: Bearer <token>
Content-Type: application/json
```

### API Documentation

No Swagger/Postman collection is currently referenced in the repository. If one exists, add its location here.

## 9. Database Setup

**The application does not use a local relational database (no Room/SQLite/Drift/Isar).** Local persistence is limited to `get_storage`, a lightweight key-value store used for:

- Auth/session tokens (`TokenManagerService`)
- Any other simple locally-cached preferences

There are no schema migrations to manage since there is no structured local database.

## 10. Dependencies

Key packages from `pubspec.yaml` (see the file for the full/current list and versions):

**State & Navigation**

- `get` — GetX controllers, routing, dialogs

**Networking**

- `dio` — HTTP client
- `shared_preferences`, `get_storage` — local key-value storage

**Firebase / Notifications**

- `firebase_core`, `firebase_messaging`, `flutter_local_notifications`

**Calling / Media**

- `agora_rtc_engine`, `media_kit`, `media_kit_libs_audio`, `flutter_vlc_player`, `audioplayers`, `record`, `flutter_ringtone_player`

**Maps**

- `google_maps_flutter`, `flutter_polyline_points`, `url_launcher`

**Calendar/Scheduling**

- `syncfusion_flutter_calendar`, `mobkit_calendar`, `calendar_date_picker2`, `timelines_plus`, `grouped_list`

**Documents/Files**

- `syncfusion_flutter_pdfviewer`, `pdfx`, `printing`, `open_file`, `file_picker`, `image_picker`, `image_gallery_saver_plus`

**Forms/UI**

- `flutter_screenutil`, `flutter_svg`, `cached_network_image`, `dropdown_button2`, `animated_custom_dropdown`, `dotted_border`, `gradient_borders`, `signature`, `emoji_picker_flutter`, `elegant_notification`, `flutter_tts`, `custom_tooltip`, `flutter_html`, `provider` (OASIS form builder state)

**Dev**

- `flutter_lints`, `flutter_test`, `change_app_package_name`

## 11. Installation

1. Install Flutter SDK and confirm with `flutter doctor`.
2. Clone the repo and run `flutter pub get`.
3. Ensure `android/app/google-services.json` is present (already committed for this project).
4. Confirm the desired API environment in `lib/core/constant/api_app_constant.dart`.
5. Connect a device/emulator (`flutter devices`).
6. Run the app (see Build Commands below).

## 12. Build Commands

```
flutter clean
flutter pub get

# Debug run
flutter run

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Run Dart/widget tests
flutter test
```

Android-native equivalents (rarely needed directly, since Flutter tooling wraps Gradle):

```
cd android
./gradlew clean
./gradlew assembleDebug
./gradlew assembleRelease
```

## 13. Running the Application

### From Android Studio / VS Code

1. Open the project root (the folder containing `pubspec.yaml`).
2. Select a connected device or emulator.
3. Run `main.dart`.

### From Command Line

```
flutter run
```

## 14. Build Variants / Flavors

No Flutter product flavors are currently configured (no `flavors` block in `pubspec.yaml`/Gradle, single `applicationId` = `com.clinician.app`). Environment switching is done by editing `ApiAppConstant` directly (see section 7). If per-environment flavors are needed in the future, this section should be updated once they're introduced.

## 15. Signing Configuration

`android/app/build.gradle.kts` currently signs **release builds with the debug signing config** (`signingConfig = signingConfigs.getByName("debug")` under `buildTypes { release { ... } }`), with a `// TODO: Add your own signing config for the release build.` left in place. Before shipping a real release build, this must be replaced with a proper release keystore configuration. Never commit the keystore file or its passwords — obtain them from the project administrator and configure them locally (e.g. via `key.properties`, excluded from version control).

## 16. Deployment / Release Process

1. Complete development on a feature branch.
2. Code review / PR.
3. Merge into the appropriate integration branch (confirm current mapping — see branch list in section 6).
4. Bump `version:` in `pubspec.yaml` (`versionName+versionCode`).
5. Run `flutter test`.
6. Manually verify on device/emulator.
7. Build release artifact: `flutter build appbundle --release` (once proper signing is configured — see section 15).
8. Verify the generated build.
9. Upload to Play Console.
10. QA sign-off.
11. Release to the required track.

## 17. Firebase Configuration

- Firebase is initialized in `lib/main.dart` via `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`, generated into `lib/firebase_options.dart`.
- Services used: **Firebase Cloud Messaging** (foreground/background/incoming-call and chat notifications), **Firebase Analytics** (via BoM in `build.gradle.kts`).
- `android/app/google-services.json` is committed for this project's Firebase project. Treat as environment-specific — do not overwrite with another project's config without confirming with the team.
- The background FCM handler (`firebaseMessagingBackgroundHandler` in `main.dart`) distinguishes `CALL_INCOMING` / `CALL_MISSED` / `CALL_ENDED` / `CALL_DECLINED` from generic chat/other notifications.

## 18. Permissions

From `android/app/src/main/AndroidManifest.xml`:

| Permission                                                     | Reason                                                                       |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `INTERNET`                                                     | API/network access                                                           |
| `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`                       | Picking images/videos (profile photo, documents, visit media) on Android 13+ |
| `RECORD_AUDIO`                                                 | Voice notes in chat, Agora calling                                           |
| `WRITE_EXTERNAL_STORAGE` (maxSdk 28) / `READ_EXTERNAL_STORAGE` | File access on older Android versions                                        |
| `POST_NOTIFICATIONS`                                           | Required on Android 13+ to show any notification (chat, calls)               |
| `VIBRATE`                                                      | Notification vibration                                                       |
| `WAKE_LOCK`                                                    | Keep device awake for heads-up/full-screen call notifications                |
| `USE_FULL_SCREEN_INTENT`                                       | Full-screen incoming call UI on locked screen                                |

The manifest also declares `<queries>` for `PROCESS_TEXT` and `http`/`https` `VIEW` intents (needed by `url_launcher` to open links/PDFs externally).

## 19. Testing

```
flutter test
```

No custom widget/integration test suite was found under `test/` beyond the default Flutter scaffold at the time of writing — expand this section as tests are added.

Manual testing should cover: login, API integration/token refresh, calendar/visit navigation, OASIS form submission, chat (text/voice/image), incoming/outgoing calls (foreground + background/killed app), map/route display, timesheet entry, earnings display, notification permissions (Android 13+), and offline/poor-network behavior.

## 20. Code Quality Guidelines

- Follow Dart/Flutter style (`flutter_lints`, see `analysis_options.yaml`).
- Use meaningful, feature-scoped names for controllers, repositories, and models.
- Avoid unnecessary API calls; the app relies on **polling** in several controllers (`HomeController`, `CalenderListController`, `LiveMapController`) — guard with an in-flight flag (`_isFetching`/`_pollInProgress`) before adding new polling to avoid overlapping requests.
- Don't hardcode new API URLs/keys — route them through `ApiAppConstant`.
- Remove unused imports/dead code.
- Keep controller → repository → API/service layering intact; avoid calling Dio directly from UI/pages.
- Dispose GetX controllers/streams and cancel timers to avoid leaks, especially for polling controllers and the call/notification listeners set up in `main.dart`.

## 21. Git Branching Strategy

Observed branch pattern in this repo mixes ticket-prefixed feature branches with long-lived stabilization branches:

```
production
   ↑
demo-final / dev-final
   ↑
feature / bugfix / enhancement branches
```

### Branch Naming (as observed)

- `FR/EN-<ticket>-<description>` style enhancement branches (e.g. `EN-oasis-forms-integration`)
- `BG-<ticket>-<description>` bug branches (e.g. `BG-13-14-CareGiver`, `bg-9-clinitian-apk-fixes`)
- Feature/topic branches without strict prefixing (e.g. `background-calling`, `notify_feature`, `validation_bugs`, `ios-android-merge`)

Confirm the current convention with the team before naming a new branch — historical branches are not fully consistent.

### PR Process

1. Create a feature/bug branch from the relevant base branch.
2. Implement changes.
3. Run `flutter test` and manually verify on device.
4. Push branch.
5. Create PR.
6. Get code review.
7. Resolve review comments.
8. Merge into the required branch.

## 22. Troubleshooting

**Gradle/Flutter build failure**

```
flutter clean
flutter pub get
```

Then check: Flutter/Dart SDK version, Android NDK version (`27.0.12077973`), JDK version (11).

**Dependency resolution error**

```
flutter pub get
flutter pub outdated
```

**API not working**
Check: internet connection, active domain in `ApiAppConstant` (dev config is currently commented out — demo is active), auth token validity, backend availability.

**App crashes on startup**
Check: Logcat/`flutter run` console, Firebase initialization (`google-services.json` present and matching package `com.clinician.app`), missing runtime permissions (POST_NOTIFICATIONS on Android 13+), Google Maps API key validity.

**Incoming call / notification not appearing**
Check: FCM token registration, `POST_NOTIFICATIONS` permission granted, notification channel created (`ChatNotificationService.init()` in `main.dart`), app not battery-optimized/killed in a way that blocks background FCM delivery.

**Emulator not detected**

```
adb devices
adb kill-server
adb start-server
```

## 23. Logging and Debugging

- Use `flutter run` console / Android Studio Logcat / `debugPrint` statements already present in call and notification flows (`main.dart`).
- Do not log tokens, passwords, or patient/clinical data (HIPAA-sensitive) — the app handles PHI (patient visit and clinical/OASIS form data), so logging discipline matters more than in a typical consumer app.

## 24. Important Notes

- The Google Maps API key and a Firebase project config are currently **committed directly in source** (`AndroidManifest.xml` meta-data, `ApiAppConstant.googleApiKey`, `google-services.json`). Treat these as sensitive even though present in-repo; do not copy them into unrelated/public projects, and coordinate with the project administrator before rotating or replacing them.
- `ApiAppConstant.endPointByAlias()` currently routes every `appType` case (`clinician`, `proHealth`, default) to the **same demo domain** — the dev configuration exists only as a commented-out block. Confirm intended behavior before assuming `appType`-based switching works as designed.
- Release builds are currently signed with the **debug** keystore (see section 15) — this must be fixed before a genuine production release.
- The app is healthcare-focused (patient visits, clinical OASIS forms) — treat all patient/clinical data as PHI when logging, caching, or sharing debug output.

## 25. Known Issues

| Issue                                                                                     | Status | Workaround                                                              |
| ----------------------------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------- |
| `ApiAppConstant.endPointByAlias` ignores `appType` and always resolves to the demo domain | Open   | Manually edit `ApiAppConstant` and rebuild for a different backend      |
| Release APK/AAB signed with debug keystore                                                | Open   | Configure a real release signing config before shipping to Play Console |

Remove entries from this table once permanently resolved.

## 26. Frequently Asked Questions

**How do I run the project?**
`flutter pub get`, then `flutter run` with a device/emulator connected.

**Which Dart/Flutter SDK is required?**
Dart `^3.7.0` (see `pubspec.yaml`); use a matching stable Flutter SDK.

**Which API environment should developers use?**
Currently the "demo" domain (`https://greenvalley.symmetry.care/`) is active in `ApiAppConstant`; the dev domain is commented out. Confirm with the team which is appropriate for your task.

**How do I create a release build?**
`flutter build appbundle --release` (see section 15 regarding signing before a real release).

**Where can I find API documentation?**
Not currently linked in-repo — add the Swagger/Postman location here once available.

## 27. Contact / Ownership

- **Project Owner:** _\<Team/Name>_
- **Development Team:** _\<Team>_
- **QA Team:** _\<Team>_
- **Backend Team:** _\<Team>_

For access-related issues, contact the project administrator/official team channel.

## 28. Change Log

| Date       | Version    | Change                                                                                                               |
| ---------- | ---------- | -------------------------------------------------------------------------------------------------------------------- |
| 2026-08-13 | 1.0.2+5007 | Documented current Flutter/GetX architecture, API config, permissions, and known issues based on codebase inspection |

## Quick Start

```
git clone <repository-url>
cd Clinician-App-dev
flutter pub get
flutter run
```

## Documentation Maintenance

This README should be updated whenever there is a material change to:

- Technology stack / Flutter or key package versions
- API configuration (`ApiAppConstant`, base URLs)
- Firebase configuration
- Build/signing configuration
- Branching strategy
- Permissions
- Known issues

The README should always represent the current working setup of the project.
