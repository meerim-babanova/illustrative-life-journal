import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../character/state/character_provider.dart';
import '../../models/journal_entry.dart';
import '../../state/journal_provider.dart';
import '../widgets/friendly_failure_state.dart';
import '../widgets/generation_pulse.dart';

/// Generation screen for a specific journal entry, identified by the
/// `entryId` passed as this route's arguments.
///
/// Kicks off illustration generation exactly once (from [initState], never
/// from `build()` — Section 24 of the spec), then reacts to the entry's
/// [GenerationStatus] as [JournalProvider] updates it. Once generation
/// succeeds, it hands off to the Journal Page for the same entry.
class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  String? _entryId;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route arguments are only available once dependencies are resolved,
    // so this is the right lifecycle hook to read them — not build() and
    // not initState(). Guarded by _requested so it only fires once per
    // screen instance, even across rebuilds.
    if (_requested) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! String) return;
    _entryId = args;
    _requested = true;

    // Deferred to a post-frame callback rather than called directly here:
    // generateIllustration() calls notifyListeners() synchronously before
    // its first `await`, and didChangeDependencies() runs during the
    // current build phase — notifying listeners elsewhere in the tree
    // (e.g. Home, if it's still mounted below this route) synchronously
    // mid-build risks Flutter's "markNeedsBuild called during build"
    // assertion. Deferring to the next frame avoids that entirely
    // (Section 24: don't perform generation requests in a way that
    // fights the widget lifecycle).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final journal = context.read<JournalProvider>();
      final character = context.read<CharacterProvider>().config;
      final entry = journal.entryById(_entryId!);
      if (entry != null && entry.generationStatus != GenerationStatus.generating) {
        journal.generateIllustration(_entryId!, character);
      }
    });
  }

  void _retry() {
    final entryId = _entryId;
    if (entryId == null) return;
    final journal = context.read<JournalProvider>();
    final character = context.read<CharacterProvider>().config;
    journal.generateIllustration(entryId, character);
  }

  @override
  Widget build(BuildContext context) {
    final entryId = _entryId;

    if (entryId == null) {
      return const Scaffold(
        body: Center(child: Text('No memory to generate an illustration for.')),
      );
    }

    return Consumer2<JournalProvider, CharacterProvider>(
      builder: (context, journal, character, _) {
        final entry = journal.entryById(entryId);

        if (entry == null) {
          return const Scaffold(
            body: Center(child: Text('This memory could not be found.')),
          );
        }

        if (entry.generationStatus == GenerationStatus.generated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.journalPage,
              arguments: entryId,
            );
          });
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: entry.generationStatus == GenerationStatus.failed
                    ? FriendlyFailureState(
                        onRetry: _retry,
                        onBack: () => Navigator.of(context).popUntil(
                          (route) => route.settings.name == AppRoutes.home,
                        ),
                      )
                    : GenerationPulse(character: character.config),
              ),
            ),
          ),
        );
      },
    );
  }
}

