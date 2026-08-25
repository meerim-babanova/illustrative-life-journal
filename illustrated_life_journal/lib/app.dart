import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/character/state/character_provider.dart';
import 'features/journal/data/illustration_generation_service.dart';
import 'features/journal/state/journal_provider.dart';

class IllustratedLifeJournalApp extends StatelessWidget {
  const IllustratedLifeJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => JournalProvider(
            illustrationService: BackendIllustrationGenerationService(
              baseUrl: AppConfig.backendBaseUrl,
            ),
          )..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Illustrated Life Journal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.startup,
      ),
    );
  }
}
