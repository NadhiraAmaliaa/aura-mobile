# AURA — Deployment Checklist

Purpose: make deployment on another/company PC easy, reproducible, low-risk, and
ensure the production app builds, installs, and runs smoothly. Work top to bottom.
`[x]` = already confirmed by the readiness audit. `[ ]` = you must do/verify it.

> Scope: Android release deployment for the `aura_mobile` Flutter app.
> Nothing in this checklist changes app behavior — it is preparation + verification.

---

## 1. Fresh / company PC setup requirements

- [ ] Install **Flutter SDK** (provides Dart; project requires Dart `^3.12.2` per `pubspec.yaml`).
- [ ] Install **Android SDK** (via Android Studio or command-line tools).
- [ ] Install a **JDK 17+** and make it the JDK Gradle uses.
      - The project compiles at Java 17 (`app/build.gradle.kts` → `sourceCompatibility`/`targetCompatibility` = 17, Kotlin `jvmTarget = 17`).
      - The current laptop happens to run JDK 23; the repo does **not** pin a JDK, so verify the build machine's JDK explicitly to avoid "works on my machine" surprises.
- [ ] Ensure the **Gradle wrapper** resolves. `gradle-wrapper.properties` (tracked) pins **Gradle 9.1.0**; Flutter regenerates `gradlew`/`gradlew.bat`/`gradle-wrapper.jar` on first build (these are git-ignored by design).
- [ ] Run `flutter doctor` and resolve any Android toolchain / licenses issues.
- [x] **Dependency versions are reproducible** — `pubspec.lock` is committed.
- [x] **Toolchain versions are pinned in-repo** — AGP `9.0.1`, Kotlin `2.3.20`, google-services `4.4.4` (`android/settings.gradle.kts`), Gradle `9.1.0` (`gradle-wrapper.properties`).

## 2. Machine-local config to recreate (NOT in git)

`android/local.properties` is git-ignored, so it must be recreated on every machine.
Flutter auto-generates `sdk.dir`, `flutter.sdk`, and the version fields, but **one value is manual**:

- [ ] Recreate `android/local.properties` with `sdk.dir` and `flutter.sdk` (Flutter fills these on first run).
- [ ] **Add `MAPS_API_KEY=<key>`** to `android/local.properties` — see §4. This is the only value Flutter does **not** regenerate.

## 3. Production environment & HTTPS BASE_URL

Config is injected at build time via `--dart-define` (`lib/core/config/env.dart`). No code change needed per environment.

- [ ] Build/run production with an **HTTPS** base URL:
      `--dart-define=ENV=prod --dart-define=BASE_URL=https://<prod-host>/api/v1 --dart-define=SENTRY_DSN=<dsn>`
- [ ] Confirm `BASE_URL` is **HTTPS**. Cleartext HTTP is blocked on Android 9+ (no `usesCleartextTraffic` / network-security-config is set), so an HTTP prod URL would fail at runtime.
- [ ] Do **not** rely on the default `BASE_URL` — it points at the dev Herd domain (`http://ptpn-intern-attendance.test/api/v1`). A release build that forgets `--dart-define=BASE_URL` will build fine but fail all network calls.
- [ ] Confirm the `/api/v1` version prefix is present and endpoint paths keep their leading slash.

## 4. Google Maps API key (MAPS_API_KEY)

- [ ] Provision a Maps key valid for the release app (package `id.aura.app` + the release signing SHA-1).
- [ ] Put it in `android/local.properties` as `MAPS_API_KEY=...` (injected into the manifest placeholder `${MAPS_API_KEY}` via `app/build.gradle.kts`).
- [ ] **Verify on-device that the map actually renders.** If the key is missing the build still succeeds and the map is silently blank (fallback is an empty string).

## 5. Firebase

- [x] **Firebase config is portable and committed** — `android/app/google-services.json` and `lib/firebase_options.dart` are both git-tracked. No extra Firebase setup needed on a new machine to build.
- [ ] Confirm the committed Firebase project (`aura-df6b1`) is the intended **production** project; switch it if a separate prod project is required.
- [ ] Verify Firebase Cloud Messaging works on a release build (see §8).

## 6. Release signing / keystore  ⚠️ BLOCKER

Current state (audit): `app/build.gradle.kts` signs `release` with the **debug** key (`signingConfigs.getByName("debug")`, marked `// TODO`). No keystore or `key.properties` exists (both git-ignored). A debug-signed build is **not publishable**.

- [ ] Generate a **release keystore** (`.jks`) and store it securely (never commit it).
- [ ] Create `android/key.properties` with `storeFile`, `storePassword`, `keyAlias`, `keyPassword` (git-ignored — keep secret).
- [ ] Add a real `release` `signingConfig` in `app/build.gradle.kts` that reads `key.properties` and replace the debug fallback.
- [ ] Define a **secret-management plan** for the keystore + passwords on the build machine / CI.
- [ ] Record the release **SHA-1/SHA-256** and register them with Google Maps + Firebase.

## 7. Release build verification

- [ ] `flutter pub get` succeeds on a clean checkout.
- [ ] Build the release artifact:
      `flutter build appbundle --dart-define=ENV=prod --dart-define=BASE_URL=https://<prod-host>/api/v1 --dart-define=SENTRY_DSN=<dsn>`
- [ ] Confirm the artifact is signed with the **release** key (not debug): `keytool`/`apksigner verify`.
- [ ] Confirm `versionName`/`versionCode` are correct (derived from `pubspec.yaml` `version:`).

## 8. Physical-device smoke tests (release build)

- [ ] App installs and launches on a real Android device.
- [ ] Login/auth works against the production API over HTTPS.
- [ ] Attendance check-in/out works; **GPS/location** permission prompts and real coordinates work.
- [ ] **Map renders** with real tiles (validates `MAPS_API_KEY`).
- [ ] Camera capture (profile photo) works; runtime permission prompt appears.
- [ ] Push notification received (validates FCM + `POST_NOTIFICATIONS` on Android 13+).
- [ ] Offline attendance queue flushes when connectivity returns.
- [ ] Sentry receives an event when `SENTRY_DSN` is set (or confirm it's intentionally disabled).

## 9. Fresh-clone reproducibility test

- [ ] On a clean machine (or clean folder), `git clone` the repo.
- [ ] Recreate `android/local.properties` incl. `MAPS_API_KEY` (§2, §4).
- [ ] `flutter pub get` → release build → install, following ONLY this checklist.
- [ ] Confirm no undocumented local file, path, or tool was needed.

## 10. Non-blocking warnings / technical debt (safe to defer)

- [ ] (Awareness) `sentry_flutter` applies the Kotlin Gradle Plugin; combined with `android.builtInKotlin=false` / `android.newDsl=false` (`android/gradle.properties`) this emits **deprecation** warnings only — no action required before deployment.
- [ ] (Awareness) CMake "SDK XML version" warning — harmless plugin/NDK noise.
- [ ] (Awareness) Bleeding-edge stack (Gradle 9.1 / AGP 9.0.1 / Kotlin 2.3.20 / JDK 23) builds today; revisit versions deliberately, not under deadline.
- [ ] (Awareness) **Gradle JVM memory is machine-specific.** `org.gradle.jvmargs` in `android/gradle.properties` is currently tuned for this ~8 GB laptop context and **must be reviewed on the new build machine** (raise/lower heap to fit its RAM). Do not treat any single value as a permanent CI/production setting.

---

## ⛔ Do NOT deploy until ALL of these are checked

- [ ] Release **signing config + keystore** in place (NOT the debug key). — §6
- [ ] `key.properties` / keystore passwords provided securely on the build machine. — §6
- [ ] Production **`BASE_URL` is HTTPS** and passed via `--dart-define`. — §3
- [ ] **`MAPS_API_KEY`** provisioned and map verified on a real device. — §4
- [ ] Firebase project confirmed as the intended production project. — §5
- [ ] Release artifact verified as **release-signed**. — §7
- [ ] Physical-device smoke tests pass on a **release** build. — §8
- [ ] Fresh-clone reproducibility test passed using only this checklist. — §9
- [ ] Gradle JVM memory reviewed for the actual build machine. — §10
