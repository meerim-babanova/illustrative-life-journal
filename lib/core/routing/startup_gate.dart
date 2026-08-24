import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/character/state/character_provider.dart';
import 'app_routes.dart';

/// Decides whether the user should land on Welcome (first time) or Home
/// (character already set up), based on the persisted character state.
///
/// Registered at [AppRoutes.startup] ("/") by [AppRouter] — kept distinct
/// from [AppRoutes.welcome] so a redirect back to "/" can never loop into
/// this gate again (that mistake previously caused the app to get stuck
/// on a permanently blank screen).
class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, character, _) {
        if (character.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return character.hasCompletedSetup
            ? const RedirectTo(routeName: AppRoutes.home)
            : const RedirectTo(routeName: AppRoutes.welcome);
      },
    );
  }
}

/// Pushes a replacement route to [routeName] on the next frame, rendering
/// nothing itself in the meantime.
class RedirectTo extends StatelessWidget {
  const RedirectTo({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed(routeName);
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
