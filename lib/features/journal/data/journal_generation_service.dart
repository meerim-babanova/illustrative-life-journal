import '../models/journal_entry.dart';
import '../models/journal_page.dart';
import 'illustration_provider.dart';

/// Turns a [JournalEntry] into an illustrated [JournalPage].
///
/// Phase 1's mock is gone: this really produces an illustration, via an
/// [IllustrationProvider]. Swapping in a hosted image model later is a
/// one-line change where the service is constructed.
abstract class JournalGenerationService {
  Future<JournalPage> generate(JournalEntry entry, {int? seed});

  Future<JournalPage> regenerate(JournalPage page, {String? nudge, int? seed});
}

class SceneJournalGenerationService implements JournalGenerationService {
  SceneJournalGenerationService({IllustrationProvider? illustrations})
      : _illustrations = illustrations ?? LocalSceneIllustrationProvider();

  final IllustrationProvider _illustrations;

  @override
  Future<JournalPage> generate(JournalEntry entry, {int? seed}) async {
    final scene = await _illustrations.illustrate(entry.text, seed: seed);
    final title = entry.title?.trim().isNotEmpty == true
        ? entry.title!.trim()
        : titleFromText(entry.text);

    return JournalPage(
      id: entry.id,
      title: title,
      text: entry.text,
      date: entry.date,
      scene: scene,
      storyId: entry.storyId,
    );
  }

  @override
  Future<JournalPage> regenerate(
    JournalPage page, {
    String? nudge,
    int? seed,
  }) async {
    final next = await _illustrations.reillustrate(
      page.scene,
      nudge: nudge,
      seed: seed ?? DateTime.now().microsecondsSinceEpoch % 100000,
    );
    return page.withNewTake(next);
  }

  /// A title in the user's own words — the first thing they wrote, not a
  /// machine-sounding summary.
  static String titleFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'A quiet moment';
    final firstSentence = trimmed.split(RegExp(r'[.!?\n]')).first.trim();
    if (firstSentence.isEmpty) return 'A quiet moment';
    if (firstSentence.length <= 38) return firstSentence;

    final buffer = <String>[];
    for (final word in firstSentence.split(' ')) {
      if (([...buffer, word].join(' ')).length > 38) break;
      buffer.add(word);
    }
    if (buffer.isEmpty) return firstSentence.substring(0, 38) + '…';
    return buffer.join(' ') + '…';
  }
}
