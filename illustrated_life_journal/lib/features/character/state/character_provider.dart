import 'package:flutter/foundation.dart';

import '../data/character_repository.dart';
import '../models/character_config.dart';

/// Holds the single source of truth for the user's character during the
/// app session, and keeps it in sync with local persistence.
///
/// This is intentionally the *only* place that mutates [CharacterConfig].
/// Screens read [config] and call the update methods; they never construct
/// a new config and write to storage themselves.
class CharacterProvider extends ChangeNotifier {
  CharacterProvider({CharacterRepository? repository})
      : _repository = repository ?? LocalCharacterRepository();

  final CharacterRepository _repository;

  CharacterConfig _config = CharacterConfig.defaultConfig();
  bool _isLoading = true;
  bool _hasCompletedSetup = false;

  CharacterConfig get config => _config;
  bool get isLoading => _isLoading;

  /// Whether the user has already been through Character Introduction /
  /// Studio at least once. Used to decide whether Welcome -> Character
  /// Introduction should be shown again on app start, versus going
  /// straight to Home.
  bool get hasCompletedSetup => _hasCompletedSetup;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final saved = await _repository.load();
    if (saved != null) {
      _config = saved;
      _hasCompletedSetup = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() => _repository.save(_config);

  Future<void> updateField({
    String? skinTone,
    String? headShape,
    String? eyeShape,
    String? eyeColor,
    String? eyebrowStyle,
    String? noseStyle,
    String? mouthStyle,
    String? hairStyle,
    String? hairColor,
    String? bodyType,
    String? outfitTop,
    String? outfitBottom,
    String? outfitShoes,
    List<String>? accessories,
  }) async {
    _config = _config.copyWith(
      skinTone: skinTone,
      headShape: headShape,
      eyeShape: eyeShape,
      eyeColor: eyeColor,
      eyebrowStyle: eyebrowStyle,
      noseStyle: noseStyle,
      mouthStyle: mouthStyle,
      hairStyle: hairStyle,
      hairColor: hairColor,
      bodyType: bodyType,
      outfitTop: outfitTop,
      outfitBottom: outfitBottom,
      outfitShoes: outfitShoes,
      accessories: accessories,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> completeSetup() async {
    _hasCompletedSetup = true;
    await _persist();
    notifyListeners();
  }
}
