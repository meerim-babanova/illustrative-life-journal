import 'package:flutter_test/flutter_test.dart';
import 'package:illustrated_life_journal/features/character/data/character_prompt_builder.dart';
import 'package:illustrated_life_journal/features/character/models/character_config.dart';
import 'package:illustrated_life_journal/features/journal/data/illustration_prompt_builder.dart';
import 'package:illustrated_life_journal/features/journal/data/illustration_style.dart';

void main() {
  final character = CharacterConfig.defaultConfig();

  group('IllustrationPromptBuilder', () {
    test('includes every required structured section', () {
      final prompt = IllustrationPromptBuilder.build(
        journalText: 'Today I went to the park with my sister.',
        character: character,
      );

      for (final section in [
        'SYSTEM STYLE:',
        'CHARACTER:',
        'MEMORY:',
        'SCENE:',
        'COMPOSITION:',
        'CONSTRAINTS:',
      ]) {
        expect(prompt, contains(section), reason: 'missing "$section" section');
      }
    });

    test('includes the exact journal text verbatim in the MEMORY section', () {
      const text = 'A very specific memory about a rainy afternoon.';
      final prompt = IllustrationPromptBuilder.build(
        journalText: text,
        character: character,
      );

      expect(prompt, contains(text));
    });

    test('trims surrounding whitespace from journal text', () {
      final prompt = IllustrationPromptBuilder.build(
        journalText: '   spaced out memory   ',
        character: character,
      );

      expect(prompt, contains('MEMORY:\nspaced out memory\n'));
    });

    test('uses the centralized style description', () {
      final prompt = IllustrationPromptBuilder.build(
        journalText: 'text',
        character: character,
      );

      expect(prompt, contains(IllustrationStyle.description));
    });

    test('includes negative constraints (no text, no photorealism)', () {
      final prompt = IllustrationPromptBuilder.build(
        journalText: 'text',
        character: character,
      );

      expect(prompt, contains('no text, captions, watermarks'));
      expect(prompt, contains('avoid photorealism'));
    });

    test('reflects the actual saved character configuration, not invented '
        'attributes', () {
      final customCharacter = character.copyWith(
        headShape: 'heart',
        hairStyle: 'curly',
        skinTone: 'deep',
      );

      final prompt = IllustrationPromptBuilder.build(
        journalText: 'text',
        character: customCharacter,
      );

      expect(prompt, contains('heart face'));
      expect(prompt, contains('curly'));
      expect(prompt, contains('deep skin tone'));
    });
  });

  group('CharacterPromptBuilder.describe (sent to the backend)', () {
    test('only includes fields that exist on CharacterConfig', () {
      final described = CharacterPromptBuilder.describe(character);

      expect(described.keys, containsAll([
        'faceShape',
        'eyeShape',
        'eyeColor',
        'hairStyle',
        'hairColor',
        'skinTone',
        'bodyType',
        'outfitTop',
        'accessories',
      ]));
      expect(described['faceShape'], character.headShape);
      expect(described['skinTone'], character.skinTone);
    });
  });
}
