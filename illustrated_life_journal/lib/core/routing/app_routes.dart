/// Central list of route names, so screens never hardcode route strings
/// inline. Keeping this as plain constants (rather than adding a routing
/// package) matches Section 24's "do not introduce unnecessary
/// dependencies" for a Phase 1 app with a small, mostly-linear flow.
class AppRoutes {
  AppRoutes._();

  /// The very first route the app opens on. Resolves to a tiny gate widget
  /// that decides whether to redirect to [welcome] or [home] based on
  /// whether a character has already been set up. Kept distinct from
  /// [welcome] so a redirect to "/" can never loop back into this gate.
  static const startup = '/';
  static const welcome = '/welcome';
  static const characterIntro = '/character-intro';
  static const characterStudio = '/character-studio';
  static const home = '/home';
  static const stories = '/stories';
  static const journalEntry = '/journal-entry';
  static const generation = '/generation';
  static const journalPage = '/journal-page';
}
