/// Non-secret, build-time-overridable configuration.
///
/// IMPORTANT: this file must never hold an AI provider API key. Flutter
/// Web ships all Dart code to the browser as readable JavaScript, so
/// anything here is effectively public. The actual image-generation
/// provider key lives only in the backend server's environment (see
/// `server/.env`), never in this app.
class AppConfig {
  AppConfig._();

  /// Base URL of the app's own backend (see `server/`), which is the only
  /// thing the Flutter client ever talks to for illustration generation.
  /// Override at build/run time with:
  ///   flutter run -d chrome --dart-define=BACKEND_BASE_URL=https://your-backend.example.com
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );
}
