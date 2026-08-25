import 'package:flutter/material.dart';

import '../../features/character/presentation/screens/character_intro_screen.dart';
import '../../features/character/presentation/screens/character_studio_screen.dart';
import '../../features/character/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/journal/presentation/screens/generation_screen.dart';
import '../../features/journal/presentation/screens/journal_entry_screen.dart';
import '../../features/journal/presentation/screens/journal_page_screen.dart';
import '../../features/stories/presentation/screens/stories_screen.dart';
import 'app_routes.dart';
import 'startup_gate.dart';

/// Generates routes by name for [MaterialApp.onGenerateRoute].
///
/// A simple `switch` over named routes is enough for Phase 1's mostly
/// linear flow (Welcome -> Character Introduction -> Character Studio ->
/// Home -> ...). If deep linking or nested navigation becomes a real need
/// in a later phase, this is the single place to swap in a router package.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.startup:
        return _route(const StartupGate(), settings);
      case AppRoutes.welcome:
        return _route(const WelcomeScreen(), settings);
      case AppRoutes.characterIntro:
        return _route(const CharacterIntroScreen(), settings);
      case AppRoutes.characterStudio:
        return _route(const CharacterStudioScreen(), settings);
      case AppRoutes.home:
        return _route(const HomeScreen(), settings);
      case AppRoutes.stories:
        return _route(const StoriesScreen(), settings);
      case AppRoutes.journalEntry:
        return _route(const JournalEntryScreen(), settings);
      case AppRoutes.generation:
        return _route(const GenerationScreen(), settings);
      case AppRoutes.journalPage:
        return _route(const JournalPageScreen(), settings);
      default:
        return _route(
          Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _route(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
