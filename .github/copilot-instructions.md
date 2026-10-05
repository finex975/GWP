# Copilot instructions

## Build, test, and analyze

Run commands from the repository root:

```sh
flutter pub get
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

Run one test file with `flutter test test/widget_test.dart`. To select a test by
its declared name, add `--name "test name"` (for example,
`flutter test test/widget_test.dart --name "Counter increments smoke test"`).
Build an Android APK with `flutter build apk`; build the Windows app with
`flutter build windows` on a configured Windows desktop toolchain.

The package requires Dart `>=3.2.0 <4.0.0`. `analysis_options.yaml` includes
Flutter's recommended lints.

## Architecture

- `lib/main.dart` initializes Flutter and Hive, sets system UI styling, and
  mounts `GhostWireApp` inside Riverpod's `ProviderScope`.
- `lib/app.dart` configures the `MaterialApp`, global theme, and initial
  `WelcomeScreen`. Screens currently navigate with `MaterialPageRoute`; there
  is no separate routing layer.
- `lib/features/` groups UI by feature. `features/auth/` contains the welcome
  and identity create/login flows; `features/chats/chats_list_screen.dart`
  currently renders an in-memory list of demo chats.
- `lib/core/` contains shared functionality. `core/crypto/identity_service.dart`
  creates and restores identities and stores identity values with
  `flutter_secure_storage`; `core/theme/` defines shared color tokens and the
  app's dark Material theme.
- The project declares Riverpod, Hive, persistence, and cryptography
  dependencies, but declarations do not imply that a feature is wired up:
  there is no chat transport/backend or persistent chat model in the current
  chat-list implementation. Check actual call sites before extending a flow.
- `android/`, `web/`, and `windows/` hold platform-specific Flutter runners and
  configuration. Device APIs and secure-storage behavior can vary by target.

## Repository conventions

- Keep feature UI in `lib/features/<feature>/` and shared services/theme in
  `lib/core/`; feature screens import shared code via relative paths.
- Use `AppColors` for the shared palette and `AppTheme.dark` for app-wide
  Material styling. The UI currently uses Russian user-facing text inline.
- The identity create/login flow is coordinated by `IdentityScreen` and
  delegates identity/storage work to `IdentityService`; keep UI concerns out of
  that service when extending the flow.
- Riverpod is initialized at the app root, but current screens/services do not
  yet use providers. Follow existing use where present rather than adding
  provider layers solely because the dependency is available.
- Widget tests live in `test/`. The existing `widget_test.dart` is the
  generated counter smoke-test scaffold and does not reflect the current app;
  update it to pump `GhostWireApp` and assert current behavior when adding
  meaningful widget coverage.
