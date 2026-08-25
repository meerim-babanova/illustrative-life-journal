import 'package:illustrated_life_journal/features/character/data/character_repository.dart';
import 'package:illustrated_life_journal/features/character/models/character_config.dart';

/// In-memory [CharacterRepository] used by tests instead of the real
/// SharedPreferences-backed implementation, so persistence behavior can be
/// asserted directly (what was saved, how many times) without touching a
/// platform channel.
class FakeCharacterRepository implements CharacterRepository {
  CharacterConfig? stored;
  int saveCount = 0;

  @override
  Future<CharacterConfig?> load() async => stored;

  @override
  Future<void> save(CharacterConfig config) async {
    stored = config;
    saveCount++;
  }

  @override
  Future<void> clear() async {
    stored = null;
  }
}
