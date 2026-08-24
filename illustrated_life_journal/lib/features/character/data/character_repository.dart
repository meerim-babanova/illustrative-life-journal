import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/character_config.dart';

/// Persistence boundary for [CharacterConfig].
///
/// Screens and state classes talk to this interface, not to
/// SharedPreferences directly, so swapping in Supabase-backed persistence
/// in Phase 2 only requires a new implementation of this class.
abstract class CharacterRepository {
  Future<CharacterConfig?> load();
  Future<void> save(CharacterConfig config);
  Future<void> clear();
}

class LocalCharacterRepository implements CharacterRepository {
  static const _storageKey = 'character_config_v1';

  @override
  Future<CharacterConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CharacterConfig.fromJson(json);
    } catch (_) {
      // Corrupt or outdated local data shouldn't crash the app — fall back
      // to no saved character, and the caller will use the default.
      return null;
    }
  }

  @override
  Future<void> save(CharacterConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(config.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
