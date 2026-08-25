import '../../character/data/character_prompt_builder.dart';
import '../../character/models/character_config.dart';
import 'illustration_style.dart';

/// Builds the structured illustration prompt described in Section 15 of
/// the product spec, from real inputs only (the user's own journal text
/// and their saved character configuration).
///
/// This is intentionally a pure function with no I/O, so it can be unit
/// tested without a network connection or a running backend (Section 25,
/// "prompt construction" is one of the explicitly required test targets).
/// The backend independently builds its own version of this prompt from
/// the same structured inputs — the client's copy exists for testability
/// and local previewing, not as the authoritative prompt sent to the AI
/// provider.
class IllustrationPromptBuilder {
  IllustrationPromptBuilder._();

  static String build({
    required String journalText,
    required CharacterConfig character,
  }) {
    final characterDescription = CharacterPromptBuilder.describeAsSentence(character);
    final memory = journalText.trim();

    return '''
SYSTEM STYLE:
${IllustrationStyle.description}

CHARACTER:
$characterDescription

MEMORY:
$memory

SCENE:
Infer the single most important visual moment from the memory above and depict the character living it.

COMPOSITION:
One coherent illustration suitable for a personal journal page.

CONSTRAINTS:
- preserve the character's described identity
- no text, captions, watermarks, or UI elements inside the image
- no borders unless they are deliberately part of the illustrated scene
- avoid photorealism
- keep the composition simple and readable
- focus on the emotional/story moment''';
  }
}
