import 'package:flutter_test/flutter_test.dart';
import 'package:illustrated_life_journal/features/character/models/character_config.dart';
import 'package:illustrated_life_journal/features/journal/models/journal_entry.dart';
import 'package:illustrated_life_journal/features/journal/state/journal_provider.dart';

import 'fakes/fake_illustration_generation_service.dart';
import 'fakes/fake_journal_repository.dart';

void main() {
  late FakeJournalRepository repository;
  late FakeIllustrationGenerationService illustrationService;
  late JournalProvider provider;
  final character = CharacterConfig.defaultConfig();

  setUp(() {
    repository = FakeJournalRepository();
    illustrationService = FakeIllustrationGenerationService();
    provider = JournalProvider(
      repository: repository,
      illustrationService: illustrationService,
    );
  });

  group('creating entries', () {
    test('createEntry adds the entry, persists it, and derives a title '
        'when none is given', () async {
      final entry = await provider.createEntry(text: 'A quiet afternoon by the window.');

      expect(provider.entries, hasLength(1));
      expect(provider.entries.first.id, entry.id);
      expect(entry.title, isNotEmpty);
      expect(entry.generationStatus, GenerationStatus.none);
      expect(repository.saveAllCount, 1);
      expect(repository.stored, hasLength(1));
    });

    test('newest entry appears first', () async {
      final first = await provider.createEntry(text: 'First memory.');
      await Future.delayed(const Duration(milliseconds: 2));
      final second = await provider.createEntry(text: 'Second memory.');

      expect(provider.entries.first.id, second.id);
      expect(provider.entries.last.id, first.id);
    });
  });

  group('loading persisted entries', () {
    test('load() reads from the repository and exposes newest first', () async {
      final now = DateTime.now();
      repository.stored = [
        JournalEntry(
          id: 'older',
          title: 'Older',
          text: 'text',
          date: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        JournalEntry(
          id: 'newer',
          title: 'Newer',
          text: 'text',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      expect(provider.isLoading, isTrue);
      await provider.load();

      expect(provider.isLoading, isFalse);
      expect(provider.entries.map((e) => e.id), ['newer', 'older']);
    });
  });

  group('generation status transitions', () {
    test('a successful first generation goes none -> generating -> generated',
        () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');
      expect(provider.entryById(entry.id)!.generationStatus, GenerationStatus.none);

      final future = provider.generateIllustration(entry.id, character);
      // Immediately after calling (before the fake's Future resolves) the
      // provider should already have flipped to "generating".
      expect(provider.isGenerating(entry.id), isTrue);

      await future;

      final updated = provider.entryById(entry.id)!;
      expect(updated.generationStatus, GenerationStatus.generated);
      expect(updated.illustrationUrl, illustrationService.nextImageUrl);
      expect(updated.generationError, isNull);
      expect(provider.isGenerating(entry.id), isFalse);
      expect(illustrationService.calls, hasLength(1));
      expect(illustrationService.calls.first.id, entry.id);
    });

    test('a failed first generation goes none -> generating -> failed with '
        'no illustration url', () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');
      illustrationService.nextResultIsFailure = true;
      illustrationService.nextFailureMessage = "We couldn't create it.";

      await provider.generateIllustration(entry.id, character);

      final updated = provider.entryById(entry.id)!;
      expect(updated.generationStatus, GenerationStatus.failed);
      expect(updated.illustrationUrl, isNull);
      expect(updated.generationError, "We couldn't create it.");
    });

    test('does not start a second concurrent generation for the same entry',
        () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');

      final first = provider.generateIllustration(entry.id, character);
      final second = provider.generateIllustration(entry.id, character);
      await Future.wait([first, second]);

      expect(illustrationService.calls, hasLength(1));
    });
  });

  group('regeneration', () {
    test('a failed regeneration keeps the previous successful image', () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');
      await provider.generateIllustration(entry.id, character);
      final afterSuccess = provider.entryById(entry.id)!;
      expect(afterSuccess.generationStatus, GenerationStatus.generated);
      final originalUrl = afterSuccess.illustrationUrl;
      expect(originalUrl, isNotNull);

      illustrationService.nextResultIsFailure = true;
      illustrationService.nextFailureMessage = 'Regeneration failed.';
      await provider.regenerateIllustration(entry.id, character);

      final afterFailedRegen = provider.entryById(entry.id)!;
      // The failure is reflected...
      expect(afterFailedRegen.generationStatus, GenerationStatus.failed);
      expect(afterFailedRegen.generationError, 'Regeneration failed.');
      // ...but the previously successful image must NOT be destroyed.
      expect(afterFailedRegen.illustrationUrl, originalUrl);
    });

    test('a successful regeneration replaces the previous image', () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');
      illustrationService.nextImageUrl = 'https://example.com/first.png';
      await provider.generateIllustration(entry.id, character);

      illustrationService.nextImageUrl = 'https://example.com/second.png';
      await provider.regenerateIllustration(entry.id, character);

      final updated = provider.entryById(entry.id)!;
      expect(updated.generationStatus, GenerationStatus.generated);
      expect(updated.illustrationUrl, 'https://example.com/second.png');
    });
  });

  group('persistence side effects', () {
    test('every state change is persisted via the repository', () async {
      final entry = await provider.createEntry(text: 'A trip to the coast.');
      final countAfterCreate = repository.saveAllCount;
      expect(countAfterCreate, greaterThanOrEqualTo(1));

      await provider.generateIllustration(entry.id, character);
      expect(repository.saveAllCount, greaterThan(countAfterCreate));
      expect(repository.stored.first.illustrationUrl, isNotNull);
    });
  });
}
