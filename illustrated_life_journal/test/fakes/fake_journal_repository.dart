import 'package:illustrated_life_journal/features/journal/data/journal_repository.dart';
import 'package:illustrated_life_journal/features/journal/models/journal_entry.dart';

/// In-memory [JournalRepository] used by tests instead of the real
/// SharedPreferences-backed implementation.
class FakeJournalRepository implements JournalRepository {
  List<JournalEntry> stored = [];
  int saveAllCount = 0;

  @override
  Future<List<JournalEntry>> loadAll() async => List.of(stored);

  @override
  Future<void> saveAll(List<JournalEntry> entries) async {
    stored = List.of(entries);
    saveAllCount++;
  }

  @override
  Future<void> clear() async {
    stored = [];
  }
}
