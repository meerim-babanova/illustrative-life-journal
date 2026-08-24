import 'package:illustrated_life_journal/features/character/models/character_config.dart';
import 'package:illustrated_life_journal/features/journal/data/illustration_generation_service.dart';
import 'package:illustrated_life_journal/features/journal/models/journal_entry.dart';

/// A controllable [IllustrationGenerationService] for tests.
///
/// Set [nextResultIsFailure] (and optionally [nextFailureMessage]) before
/// calling a provider method under test to control whether the *next* call
/// succeeds or fails, without any real network/backend involved. Every
/// call is recorded in [calls] so tests can assert what was actually sent
/// (e.g. that the right entry/character reached the service).
class FakeIllustrationGenerationService implements IllustrationGenerationService {
  bool nextResultIsFailure = false;
  String nextFailureMessage = 'Mock failure';
  String nextImageUrl = 'https://example.com/generated.png';
  final List<JournalEntry> calls = [];

  @override
  Future<IllustrationGenerationResult> generate({
    required JournalEntry entry,
    required CharacterConfig character,
  }) async {
    calls.add(entry);
    if (nextResultIsFailure) {
      throw IllustrationGenerationFailure(nextFailureMessage);
    }
    return IllustrationGenerationResult(imageUrl: nextImageUrl);
  }
}
