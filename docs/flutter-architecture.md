# AURA Mobile — Architecture Document

> **Status:** Finalized (pre-implementation)
> **Last updated:** 2026-07-02
> **Scope:** This document is the **single source of truth** for the AURA Mobile
> Flutter application. Any deviation from the decisions here must be discussed
> and this document updated first.

---

## 1. Context & Purpose

AURA Mobile is the **intern-facing** mobile client for the PTPN Intern
Attendance system.

- The **backend already exists**: Laravel + Inertia web application.
- **Admins keep using the Laravel web app.** Flutter is **only for interns**.
- The mobile app consumes the Laravel **REST API** (to be exposed for mobile).
- The product is **production-oriented and expected to grow**, not a demo.

### Core features (v1 scope)

| Feature                         | Notes                                                   |
| ------------------------------- | ------------------------------------------------------- |
| Authentication                  | Token-based login (Sanctum).                            |
| Attendance Check-In / Check-Out | Records timestamp + GPS coordinates.                    |
| GPS location                    | Captured on check-in/out; a **fraud surface**, see §12. |
| Work Mode                       | `wfo` \| `wfh` \| `dinas` (WFO / WFH / Business Trip).  |
| Leave Requests                  | `izin` \| `sakit`, with approval status.                |
| Attendance History              | Read-only list of past records.                         |
| Profile                         | Intern profile view.                                    |

### Backend domain reference (from Laravel schema)

Field vocabulary the app must mirror exactly:

- Attendance `status`: `present`, `late`, `sick`, `permission`, `absent`.
- Attendance `work_mode`: `wfo`, `wfh`, `dinas`.
- Leave `type`: `izin`, `sakit`; leave `status`: `pending`, `approved`, `rejected`.
- User `role`: `admin`, `intern` (mobile handles `intern` only).
- Non-working days exist server-side and affect late/present rules.

---

## 2. Architecture Philosophy

### 2.1 Guiding principles

1. **Feature-first, not layer-first.** Code is organized by business feature so
   the app scales by adding folders, not by growing shared god-layers.
2. **Server is the source of truth.** The device _reports_; the backend
   _decides_ (attendance status, late/present, timestamps, future geofence).
   The client never owns business rules that have integrity/fraud implications.
3. **Pragmatic layering.** We use a light presentation/data separation with a
   thin domain layer only where it earns its keep (auth, attendance). We do
   **not** apply full textbook Clean Architecture everywhere.
4. **Explicit over implicit.** Immutable state, sealed result types, exhaustive
   handling. No hidden mutable singletons.
5. **Codegen is a first-class workflow**, not an afterthought.

### 2.2 What this architecture is _called_

Feature-first + **Riverpod presentation layer (Notifier / AsyncNotifier)** over
repositories.

> We deliberately **do not call this "MVVM."** Riverpod's `AsyncNotifier` _is_
> the ViewModel. Using the MVVM label historically invites someone to add a
> second state framework (`ChangeNotifier`, `provider`-style bindings) that
> fights Riverpod. Precise naming prevents architectural drift.

**Alternatives considered:** BLoC (more ceremony/boilerplate for this app size),
GetX (rejected — opaque global state, poor testability), plain
`setState`/`provider` (does not scale). **Trade-off:** Riverpod has a learning
curve and leans heavily on codegen, accepted for its testability and compile-time
safety.

---

## 3. Folder Structure

```
lib/
├── main.dart                     # Entry point (flavor-aware bootstrap)
├── app/
│   ├── app.dart                  # MaterialApp.router root widget
│   ├── router/
│   │   ├── app_router.dart       # go_router config + auth redirect
│   │   └── routes.dart           # Route name/path constants
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
├── core/
│   ├── config/
│   │   └── env.dart              # Flavor + base URL (via --dart-define)
│   ├── network/
│   │   ├── dio_client.dart       # Dio instance + interceptors
│   │   ├── auth_interceptor.dart # Attaches bearer token
│   │   └── api_result.dart       # Sealed success/failure wrapper (freezed)
│   ├── error/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   ├── storage/
│   │   └── secure_storage.dart   # flutter_secure_storage wrapper
│   ├── providers/
│   │   └── core_providers.dart   # dio, storage, env providers
│   ├── observability/
│   │   └── sentry_init.dart      # Crash/error reporting bootstrap
│   └── utils/
│       ├── formatters.dart       # Date/time formatting (intl)
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/           # login_request/response, user model
│   │   │   ├── datasources/      # auth_api.dart (Retrofit)
│   │   │   └── repositories/     # auth_repository_impl.dart
│   │   ├── domain/               # Only where it earns its keep
│   │   │   ├── entities/
│   │   │   └── repositories/     # auth_repository.dart (abstract)
│   │   └── presentation/
│   │       ├── providers/        # auth_notifier.dart, auth_state.dart
│   │       ├── screens/          # login_screen.dart
│   │       └── widgets/
│   ├── attendance/               # check-in/out, work mode, GPS
│   ├── leave/                    # leave requests
│   ├── history/                  # attendance history
│   └── profile/
└── shared/
    └── widgets/                  # buttons, loaders, empty/error states
```

### 3.1 Layer rules per feature

- **data/** — DTO models, Retrofit API, repository implementation. Talks to the
  network. Knows about JSON.
- **domain/** — abstract repository + pure entities. **Added only for `auth` and
  `attendance`** (the features with real business logic worth mocking).
  `leave`, `history`, `profile` may use a repository + DTO directly.
- **presentation/** — Riverpod notifiers (VMs), state classes, screens, widgets.
  Never imports another feature's `data/` directly.

**Why:** feature-first keeps blast radius small — a change to attendance rarely
touches leave. **Alternative considered:** strict Clean everywhere (rejected as
over-engineering for a ~5-feature app; ceremony without payoff for CRUD screens).
**Trade-off:** inconsistency between "full 3-layer" features and "2-layer"
features. Mitigated by documenting _which_ features get a domain layer (above).

---

## 4. Package Decisions

### 4.1 Installed now (v1 foundation)

**Runtime dependencies**

| Package                  | Role                      | Why                                      |
| ------------------------ | ------------------------- | ---------------------------------------- |
| `flutter_riverpod`       | State / DI                | Chosen state solution.                   |
| `riverpod_annotation`    | Codegen annotations       | Enables `@riverpod`.                     |
| `dio`                    | HTTP client               | Interceptors required for auth.          |
| `retrofit`               | Typed API layer           | Less boilerplate as API grows.           |
| `go_router`              | Routing                   | Declarative + auth redirect.             |
| `flutter_secure_storage` | Token storage             | Encrypted at rest.                       |
| `freezed_annotation`     | Model/union annotations   | Immutable models + sealed unions.        |
| `json_annotation`        | Serialization annotations | Works alongside freezed.                 |
| `geolocator`             | GPS                       | Core to attendance; also mock detection. |
| `intl`                   | Date/time/format          | Dates, times, locale formatting.         |
| `sentry_flutter`         | Crash/error reporting     | Non-negotiable for production.           |

**Dev dependencies**

| Package              | Role                           |
| -------------------- | ------------------------------ |
| `build_runner`       | Codegen runner.                |
| `riverpod_generator` | `@riverpod` codegen.           |
| `freezed`            | Model/union codegen.           |
| `retrofit_generator` | Retrofit codegen.              |
| `json_serializable`  | `fromJson`/`toJson`.           |
| `mocktail`           | Mocking for tests, no codegen. |

> **Note (2026-07-03):** `custom_lint` and `riverpod_lint` were **deferred at
> install time**, not by choice but due to an ecosystem version conflict:
> `flutter_riverpod 3.3.2` pins `riverpod 3.3.2`, while the current
> `riverpod_lint`/`custom_lint` only resolve against `riverpod ≤ 3.1.0`. We
> chose **not** to downgrade the core state library to satisfy a linter. Re-add
> both once `riverpod_lint` supports `riverpod 3.3.x` (see §4.2).

**Optional (may add in v1 if UX needs it)**

| Package             | Role              | Condition                                        |
| ------------------- | ----------------- | ------------------------------------------------ |
| `connectivity_plus` | Offline awareness | Add if we need explicit offline UX for check-in. |

### 4.2 Deferred (do NOT install yet)

| Package                                              | Why deferred                                                                                                                                              | Install trigger                                                              |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `permission_handler`                                 | `geolocator` handles location permissions itself. Redundant for a location-only v1. Adding later is cheap/non-invasive.                                   | A second permission domain: camera (selfie check-in), notifications, photos. |
| `custom_lint` / `riverpod_lint`                      | Foundational by intent, but currently **unresolvable** against `riverpod 3.3.2` (they cap at `riverpod ≤ 3.1.0`). Not worth downgrading the core library. | `riverpod_lint` publishes support for `riverpod 3.3.x`.                      |
| `freezed` (as "later")                               | **Reversed — now installed day one.** Kept here for history: it touches models + state, so retrofitting is expensive; hence it is foundational.           | N/A (installed).                                                             |
| `hive` / `isar` / `drift`                            | No offline persistence requirement in v1. Local DB collides with anti-fraud (stale queued check-ins).                                                     | A decision to support offline **read** caching or offline history.           |
| `google_maps_flutter` / geofence libs                | Work-modes doc marks geofencing as **future, server-side**. `geolocator` already gives coordinates.                                                       | Client-side map display or client geofence UX.                               |
| `firebase_messaging` / `flutter_local_notifications` | Push (e.g., leave approval alerts) is a feature, not foundation.                                                                                          | Notification feature is scheduled.                                           |
| `google_maps_flutter`                                | See above.                                                                                                                                                | See above.                                                                   |
| Analytics SDKs                                       | Not foundational; adds privacy surface.                                                                                                                   | A product analytics requirement.                                             |

### 4.3 Explicitly rejected

- **GetX** — opaque global state, weak testability.
- **A separate MVVM package** — Riverpod already provides the VM layer.
- **Mixing multiple state libs** (bloc + provider + riverpod) — one solution only.

---

## 5. Naming Conventions

| Element                    | Convention                                    | Example                               |
| -------------------------- | --------------------------------------------- | ------------------------------------- |
| Files & directories        | `snake_case`                                  | `auth_repository.dart`                |
| Classes / enums / typedefs | `PascalCase`                                  | `AttendanceRepository`, `WorkMode`    |
| Members / variables        | `lowerCamelCase`                              | `checkInTime`                         |
| Constants                  | `lowerCamelCase` (modern Dart)                | `defaultTimeout`                      |
| Riverpod providers         | function name + `Provider` suffix (generated) | `authNotifierProvider`, `dioProvider` |

**File role suffixes (be consistent):**

- `*_screen.dart` — full pages.
- `*_api.dart` — Retrofit interfaces.
- `*_repository.dart` (abstract) / `*_repository_impl.dart` (impl).
- `*_notifier.dart` — Riverpod ViewModels.
- `*_state.dart` — state classes/unions.
- `*_model.dart` — data-layer DTOs. _(We use `_model`, not `_dto`.)_
- `*_entity.dart` — domain entities.

**JSON mapping rule:** Dart stays `camelCase`; JSON keys stay `snake_case` via
`@JsonKey`. Vocabulary must match the backend exactly: `work_mode`
(`wfo|wfh|dinas`), `status` (`present|late|sick|permission|absent`), leave
`type` (`izin|sakit`) and `status` (`pending|approved|rejected`).

**Routing:** path + name constants centralized in `routes.dart`
(`RoutePaths.login = '/login'`, `RouteNames.login = 'login'`).

---

## 6. Riverpod Architecture

### 6.1 Provider strategy

- Use **`riverpod_generator`** (`@riverpod`) for all providers — consistent,
  less boilerplate, compile-time safety.
- **ViewModels** are `Notifier` (sync UI state) or `AsyncNotifier`
  (async-loading state). One notifier per screen/feature concern.
- **Dependencies (Dio, storage, repositories, env)** are exposed as providers in
  `core/providers/` and per-feature `data/`, injected via `ref.watch` /
  `ref.read`.

### 6.2 Layering through Riverpod

```
Screen (ConsumerWidget)
  └─ watches → FeatureNotifier (AsyncNotifier)   ← ViewModel
                 └─ calls → Repository (abstract) ← domain boundary
                              └─ impl → Retrofit API + SecureStorage
```

- Screens never call repositories directly; they go through the notifier.
- Notifiers never touch Dio directly; they go through repositories.

### 6.3 Testing hook

`riverpod_lint` + `custom_lint` enforce correct usage. Tests use
`ProviderContainer` with **provider overrides** to inject `mocktail` fakes of
repositories.

**Why:** clean seams for testing, no service locator, compile-time DI.
**Alternative considered:** `get_it` + manual DI (rejected — duplicates what
Riverpod already does). **Trade-off:** codegen adds a build step (accepted).

---

## 7. Networking (Dio + Retrofit)

### 7.1 Design

- A **single Dio instance** (`dio_client.dart`) configured with base URL (from
  `env.dart`), timeouts, and interceptors.
- The **base URL includes the API version** (`.../api/v1`). Because Dio joins
  the base URL and path by string concatenation, Retrofit endpoint paths must
  start with a **leading slash** (e.g. `@POST('/auth/login')`) so the `v1`
  segment is preserved.
- **`auth_interceptor.dart`** attaches the bearer token from secure storage to
  every request and handles `401` by clearing the session and redirecting to
  login.
- **Retrofit** defines typed endpoints per feature in `*_api.dart`.
- **Escape hatch:** for non-standard requests (future multipart selfie upload,
  streaming), repositories may call Dio directly instead of Retrofit. We are
  **not dogmatic** about routing every call through annotations.

### 7.2 Result & error handling

- All repository methods return a **sealed `ApiResult<T>`** (`Success` /
  `Failure`) — no throwing across the repository boundary for expected errors.
  **Implementation note:** this is a plain Dart 3 `sealed class`, **not** a
  Freezed union. For a two-variant generic result, hand-written sealed classes
  give the same exhaustive `switch` with cleaner generics and no codegen.
  Freezed remains reserved for data models and UI state.
- `Failure` carries a typed `AppException` (network, unauthorized, validation,
  server, unknown). Unexpected exceptions are reported to Sentry.

**Why Retrofit:** typed endpoints and less boilerplate pay off across ~5 feature
areas. **Alternative considered:** hand-written Dio calls (more boilerplate as
the surface grows). **Trade-off:** another generator in the build chain, and
Retrofit can be awkward for non-CRUD — mitigated by the escape hatch above.

---

## 8. Routing

- **`go_router`** with centralized route constants.
- **Auth-driven redirect:** a top-level `redirect` reads auth state and sends
  unauthenticated users to `/login`; `refreshListenable` is tied to the auth
  notifier so navigation reacts to login/logout automatically.
- Deep-link-ready structure (paths are stable constants).

**Caveat / rule:** redirect logic must be **pure and cheap** (no async work
inside `redirect`); it reads already-resolved auth state. Async auth resolution
(reading the token on cold start) happens **before** the router evaluates,
during app bootstrap, so the first redirect decision is correct.

**Alternative considered:** `Navigator 2.0` by hand (rejected — verbose,
error-prone), `auto_route` (viable, but `go_router` is first-party and
sufficient). **Trade-off:** `go_router`'s redirect model requires disciplined
auth-state bootstrapping (documented above).

---

## 9. State Management

- **Immutable state** everywhere via freezed.
- Async screens use **`AsyncValue`** (`AsyncNotifier`) so loading/error/data are
  modeled explicitly and handled exhaustively in the UI.
- **No mutable globals.** Shared state is a provider.
- **UI states are unions** where it clarifies handling (e.g., auth:
  `initial | loading | authenticated | error`).

**Why:** exhaustive handling eliminates whole classes of "forgot the loading/error
state" bugs. **Trade-off:** more upfront typing/boilerplate — offset by freezed
codegen and by `AsyncValue` covering the common case for free.

---

## 10. Model Strategy

- **Freezed** for all data models and state classes (immutability, `copyWith`,
  equality, sealed unions).
- **`json_serializable`** composes with freezed for `fromJson`/`toJson`.
- Enums (`WorkMode`, attendance `status`, leave `type`/`status`) modeled as Dart
  enums with explicit JSON value mapping.
- Keep DTOs (`*_model.dart`) in `data/`; map to domain `*_entity.dart` only in
  the features that have a domain layer (`auth`, `attendance`).

**Why freezed day one:** it touches models _and_ state — the exact layers we
build first. Retrofitting freezed later means rewriting every model/state class
and all call sites (`copyWith`, pattern matches). Installing it now avoids a
costly migration. This was a deliberate reversal of an earlier "add later"
stance, on the correct consistency argument.
**Alternative considered:** hand-written immutable classes or `equatable`
(rejected — manual `copyWith`/equality is error-prone and verbose).
**Trade-off:** longer `build_runner` runs and codegen ceremony (accepted).

---

## 11. Authentication Strategy

- **Laravel Sanctum** personal-access **token** auth (first-party mobile client).
- Token stored in **`flutter_secure_storage`** (encrypted at rest).
- `auth_interceptor` attaches `Authorization: Bearer <token>`; `401` clears the
  session and routes to login.
- **No refresh-token flow.** Sanctum personal-access tokens do not expire by
  default, so a token-rotation/refresh interceptor is **intentionally omitted** —
  it would add complexity with no benefit.

**Decision to confirm with backend:** if the backend team chooses short-lived +
refresh tokens instead, that is a deliberate change — this document and the
interceptor design must be updated first.

**Alternative considered:** Laravel Passport / OAuth2 (rejected — heavier than
needed for a single first-party client). **Trade-off:** Sanctum tokens are
long-lived, so token revocation on the server (logout / compromise) matters —
logout must call the backend to revoke, not just clear local storage.

### Android storage caveats

- **`encryptedSharedPreferences` is no longer set.** It is deprecated in
  `flutter_secure_storage 10.x` (the Jetpack Security library is deprecated by
  Google; data auto-migrates to custom ciphers on first access). We use the
  default `AndroidOptions`. Revisit if the plugin changes its default backend
  again.
- Configure Android auto-backup rules so stale keystore entries aren't restored.

---

## 12. GPS & Server-Authoritative Design

> **This is the most important integrity decision in the app.**

Because attendance records store `check_in_latitude/longitude`, **GPS is a fraud
surface**, not just a feature. Interns could spoof WFO check-ins.

### Rules

1. **The device reports; the server decides.** The client sends coordinates,
   `work_mode`, and a **mock-location flag**; the **backend** determines
   `late/present`, applies non-working-day rules, and (future) validates the
   geofence. The client never computes the business outcome.
2. **Mock-location detection.** Use `geolocator`'s `Position.isMocked` (Android)
   and send that flag to the backend so spoofed fixes can be flagged/rejected
   server-side.
3. **Do not trust the device clock.** The backend assigns the authoritative
   check-in timestamp; the client timestamp is advisory only. This blocks clock
   manipulation.
4. **Foreground location only.** Request foreground location permission only (no
   background location) to avoid Play Store review friction and respect privacy.
5. **Permission edge cases handled:** permanently-denied → deep link to system
   settings; denied → clear, non-blocking messaging.

### v1 non-goals

- **No client-side geofence** (server-side, future work per the backend
  work-modes doc).
- **No offline check-in** (see §13) — a queued check-in has a stale
  location/timestamp and directly conflicts with anti-fraud.

**Trade-off:** server-authoritative design means the app cannot fully validate a
check-in offline — accepted, because integrity outweighs offline convenience for
attendance.

---

## 13. Environment / Flavors

- **Two flavors from day one: `dev` and `prod`.**
- Base URL and environment come from **`--dart-define`** consumed by `env.dart`
  (e.g., dev → local Herd host `ptpn-intern-attendance.test`, prod → real host).
- Flavor-specific app id/name where useful so both builds can coexist on a
  device.

**Why now:** retrofitting flavors after screens and native config exist is
painful (Android/iOS entrypoints, build config). Cheap now, expensive later —
same logic that justified freezed early.
**Alternative considered:** hardcoded base URL + manual edits (rejected — error
prone, leaks prod config into dev). **Trade-off:** slightly more build/run
ceremony (documented run commands in §15).

### Connectivity & offline posture

- **v1: live connectivity required for check-in.** Optionally add
  `connectivity_plus` for clear offline UX.
- **No offline check-in queue in v1** (conflicts with anti-fraud). Read-only data
  (history/profile) caching may be revisited later as a deliberate decision.

---

## 14. Code Generation Workflow

Generators in use: `freezed`, `json_serializable`, `riverpod_generator`,
`retrofit_generator` — all driven by `build_runner`.

- **During development:** `dart run build_runner watch --delete-conflicting-outputs`
- **One-off / CI:** `dart run build_runner build --delete-conflicting-outputs`
- **Rule:** generated files (`*.g.dart`, `*.freezed.dart`) are **committed** to
  the repo (see §16) so CI and fresh clones build without a mandatory codegen
  step, and code review can see generated diffs.

**Trade-off:** committing generated files creates larger diffs; accepted for
reproducibility and reviewability. If diffs become noisy we revisit
`.gitattributes` to mark them as generated.

### 14.1 Note on `freezed` prerelease & reproducibility (2026-07-03)

- **`freezed` is currently pinned to a prerelease (`3.2.6-dev.1`).** This is
  forced by analyzer compatibility: `riverpod_generator 4.0.4` requires
  `analyzer ^12`, and the first `freezed` supporting analyzer 12 is
  `3.2.6-dev.1`. We deliberately **do not** downgrade the Riverpod runtime to
  obtain stable `freezed 3.2.5`, because `riverpod_generator` pulls the
  transitive prerelease `riverpod_analyzer_utils` (no stable release exists yet)
  regardless — so a downgrade would trade a newer shipped library for no real
  gain. (Full analysis in the decision log / discussion.)
- **`freezed` is a `dev_dependency` and does NOT ship in the runtime app.** It is
  a build-time code generator only. The app binary depends on the _generated_
  `*.freezed.dart` / `*.g.dart` files and on `freezed_annotation` (stable), not
  on the `freezed` generator itself.
- **Reproducible builds are guaranteed by committing two things:** the
  **generated files** (`*.freezed.dart`, `*.g.dart`) and **`pubspec.lock`**.
  With both committed, a fresh clone (or a future rebuild years later) resolves
  to the exact same versions and can build without re-running codegen. This is
  the primary safeguard for a hand-over-and-abandon project, and it holds
  regardless of the prerelease label on the codegen tooling.

---

## 15. Development Workflow

### 15.1 Setup

1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs`

### 15.2 Running (flavor-aware)

- Dev: `flutter run --dart-define=ENV=dev --dart-define=BASE_URL=http://ptpn-intern-attendance.test/api/v1`
- Prod: `flutter run --dart-define=ENV=prod --dart-define=BASE_URL=https://<prod-host>/api/v1`

_(Exact flavor invocation finalized when flavors are implemented; the
`--dart-define` contract is fixed.)_

### 15.3 Quality gates (run before pushing)

- `dart format .`
- `flutter analyze` (with `custom_lint` / `riverpod_lint` active)
- `flutter test`

### 15.4 Testing baseline

- **`mocktail`** for repository/Dio mocks.
- **Riverpod `ProviderContainer` overrides** for notifier/VM tests.
- **`integration_test`** for the critical **auth** and **check-in** happy paths.
- Target: not maximal coverage — **the auth and check-in flows must be tested**,
  since those are the costly regressions.

---

## 16. Git Workflow

- **Branching:** trunk-based-friendly. `main` is always releasable. Work on
  short-lived `feature/<name>`, `fix/<name>`, `chore/<name>` branches; open PRs
  into `main`.
- **Commits:** **Conventional Commits** (`feat:`, `fix:`, `chore:`, `refactor:`,
  `test:`, `docs:`). Enables readable history and future changelog automation.
- **PR rules:** must pass format + analyze + test locally; PR description links
  the feature; small, reviewable PRs preferred.
- **Generated files:** committed (see §14). Reviewers focus on hand-written code;
  generated diffs are expected.
- **Secrets:** never commit real base URLs/keys for prod; environment comes via
  `--dart-define` / CI secrets, not source.

**Trade-off:** trunk-based requires discipline (small PRs, green main); accepted
for faster integration over long-lived divergent branches.

---

## 17. Best Practices

- **Server is source of truth** for anything with integrity implications (§12).
- **One state solution** (Riverpod). Do not introduce a second.
- **No business logic in widgets.** Widgets render state and dispatch intents to
  notifiers.
- **No cross-feature imports of `data/`.** Features integrate through the
  presentation layer or shared abstractions.
- **Immutable state + exhaustive handling** (freezed + `AsyncValue`).
- **Every network call is cancellable/timeout-bound** via the shared Dio config.
- **All unexpected errors reported to Sentry**; expected errors are typed
  `Failure`s surfaced in the UI.
- **Handle permission and connectivity edge cases explicitly** — never assume the
  happy path in the field.
- **Keep the domain vocabulary identical to the backend** to avoid mapping bugs.

---

## 18. Future Considerations (deliberately deferred)

| Item                                   | When to reconsider                                                            |
| -------------------------------------- | ----------------------------------------------------------------------------- |
| `permission_handler`                   | Camera (selfie check-in), notifications, or photos added.                     |
| Push notifications                     | Leave-approval / attendance-reminder feature scheduled.                       |
| Offline read caching (Hive/Isar/Drift) | Requirement to view history/profile offline.                                  |
| Client-side geofence + maps            | Server geofence lands and needs a client UX.                                  |
| Refresh-token auth                     | Backend adopts short-lived tokens.                                            |
| Product analytics                      | Explicit analytics requirement (mind privacy).                                |
| Localization (multi-language)          | Beyond `intl` formatting — full `.arb` l10n if a second language is required. |
| CI/CD (build, test, distribute)        | Team wants automated builds / store delivery.                                 |
| App icons / splash tooling             | Branding pass (`flutter_launcher_icons`, `flutter_native_splash`).            |

---

## 19. Decision Log (open items to confirm before coding)

1. **Auth = Sanctum tokens, no refresh flow** — confirm with backend team.
2. **API contract** for check-in must accept: coordinates, `work_mode`, and a
   **mock-location flag**; server returns authoritative status + timestamp.
3. **No offline check-in in v1** — confirmed design constraint.
4. **Flavors (dev/prod) via `--dart-define`** — fixed contract.
5. **Base URLs** (dev Herd host + prod host) — provide values.
6. Architecture is **feature-first + Riverpod presentation over repositories** —
   not "MVVM" in naming.

---

_End of document. Update this file first whenever an architectural decision
changes._
