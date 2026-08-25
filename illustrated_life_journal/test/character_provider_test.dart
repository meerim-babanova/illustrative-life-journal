import 'package:flutter_test/flutter_test.dart';
import 'package:illustrated_life_journal/features/character/models/character_config.dart';
import 'package:illustrated_life_journal/features/character/state/character_provider.dart';

import 'fakes/fake_character_repository.dart';

void main() {
  late FakeCharacterRepository repository;
  late CharacterProvider provider;

  setUp(() {
    repository = FakeCharacterRepository();
    provider = CharacterProvider(repository: repository);
  });

  test('load() with nothing saved falls back to the default config and '
      'hasCompletedSetup stays false', () async {
    expect(provider.isLoading, isTrue);
    await provider.load();

    expect(provider.isLoading, isFalse);
    expect(provider.hasCompletedSetup, isFalse);
    expect(provider.config.headShape, CharacterConfig.defaultConfig().headShape);
  });

  test('load() restores a previously saved config and marks setup complete',
      () async {
    repository.stored = CharacterConfig.defaultConfig().copyWith(
      hairStyle: 'curly',
      skinTone: 'deep',
    );

    await provider.load();

    expect(provider.hasCompletedSetup, isTrue);
    expect(provider.config.hairStyle, 'curly');
    expect(provider.config.skinTone, 'deep');
  });

  test('updateField updates in-memory config and persists it', () async {
    await provider.load();

    await provider.updateField(hairStyle: 'pixie', eyeColor: 'green');

    expect(provider.config.hairStyle, 'pixie');
    expect(provider.config.eyeColor, 'green');
    expect(repository.stored?.hairStyle, 'pixie');
    expect(repository.saveCount, 1);
  });

  test('updateField only changes the fields passed, leaving others intact',
      () async {
    await provider.load();
    final before = provider.config;

    await provider.updateField(hairStyle: 'braids');

    expect(provider.config.hairStyle, 'braids');
    expect(provider.config.skinTone, before.skinTone);
    expect(provider.config.headShape, before.headShape);
  });

  test('completeSetup persists and flips hasCompletedSetup', () async {
    await provider.load();
    expect(provider.hasCompletedSetup, isFalse);

    await provider.completeSetup();

    expect(provider.hasCompletedSetup, isTrue);
    expect(repository.saveCount, 1);
  });

  test('survives a simulated app restart (persistence round-trip)', () async {
    await provider.load();
    await provider.updateField(hairStyle: 'ponytail', bodyType: 'curvy');
    await provider.completeSetup();

    // Simulate a fresh app start reading from the same backing store.
    final restarted = CharacterProvider(repository: repository);
    await restarted.load();

    expect(restarted.hasCompletedSetup, isTrue);
    expect(restarted.config.hairStyle, 'ponytail');
    expect(restarted.config.bodyType, 'curvy');
  });
}
