import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

/// Persistence boundary for the list of [JournalEntry] objects.
///
/// Mirrors `CharacterRepository`'s shape so the rest of the app follows one
/// consistent persistence pattern. A future Phase 3 backend can implement
/// this same interface without touching [JournalProvider] or any screen.
abstract class JournalRepository {
  Future<List<JournalEntry>> loadAll();
  Future<void> saveAll(List<JournalEntry> entries);
  Future<void> clear();
}

class LocalJournalRepository implements JournalRepository {
  static const _storageKey = 'journal_entries_v1';

  @override
  Future<List<JournalEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => JournalEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      // Corrupt/outdated local data shouldn't crash the app on startup —
      // treat it as "no entries yet" rather than throwing.
      return [];
    }
  }

  @override
  Future<void> saveAll(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
