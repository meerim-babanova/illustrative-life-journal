import '../models/character_config.dart';

/// Turns a saved [CharacterConfig] into descriptions used for illustration
/// generation.
///
/// Deliberately reads only fields that exist on [CharacterConfig] — no
/// invented attributes — so the generated character always matches what
/// the user actually configured in the Character Studio.
class CharacterPromptBuilder {
  CharacterPromptBuilder._();

  /// A structured, JSON-safe description of the character. This is what
  /// gets sent to the backend as the `character` field of the
  /// `/generate-illustration` request body — the backend (not the Flutter
  /// client) is the authoritative place the full image prompt is built.
  static Map<String, dynamic> describe(CharacterConfig config) => {
        'faceShape': config.headShape,
        'eyeShape': config.eyeShape,
        'eyeColor': config.eyeColor,
        'hairStyle': config.hairStyle,
        'hairColor': config.hairColor,
        'skinTone': config.skinTone,
        'bodyType': config.bodyType,
        'outfitTop': config.outfitTop,
        'accessories': config.accessories,
      };

  /// A single human-readable sentence built from the same fields, used for
  /// local prompt previews/tests and as a fallback description if a
  /// consuming service wants plain text instead of structured data.
  static String describeAsSentence(CharacterConfig config) {
    final readableHair = config.hairStyle.replaceAll('_', ' ');
    final readableOutfit = config.outfitTop.replaceAll('_', ' ');
    final accessoriesClause = config.accessories.isEmpty
        ? ''
        : ', wearing ${config.accessories.map((a) => a.replaceAll('acc_', '').replaceAll('_', ' ')).join(', ')}';

    return 'A simple illustrated character with a ${config.headShape} face, '
        '${config.eyeShape} ${config.eyeColor} eyes, $readableHair '
        '${config.hairColor} hair, a ${config.skinTone} skin tone, and a '
        '${config.bodyType} build, wearing a $readableOutfit'
        '$accessoriesClause.';
  }
}
