import '../models/journal_entry.dart';
import '../models/journal_page.dart';

/// Turns a [JournalEntry] into a [JournalPage].
///
/// This is the single seam the real pipeline described in the product spec
/// (Section 15, "AI Architecture": text -> interpreter -> structured scene
/// -> image prompt -> image generation -> journal page) will plug into.
/// Nothing outside this service should know whether generation is mocked
/// or real.
abstract class JournalGenerationService {
  Future<JournalPage> generate(JournalEntry entry);
}

/// Phase 1 mock implementation: no network calls, no AI, just a short
/// simulated delay and a deterministic placeholder page so the full user
/// flow (write -> generate -> view page) can be demonstrated end-to-end.
class MockJournalGenerationService implements JournalGenerationService {
  @override
  Future<JournalPage> generate(JournalEntry entry) async {
    await Future.delayed(const Duration(seconds: 2));

    final title = entry.title?.trim().isNotEmpty == true
        ? entry.title!.trim()
        : _titleFromText(entry.text);

    return JournalPage(
      title: title,
      text: entry.text,
      date: entry.date,
      illustrationSeed: entry.text.length,
    );
  }

  String _titleFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'A quiet moment';
    final firstSentence = trimmed.split(RegExp(r'[.!?]')).first.trim();
    if (firstSentence.length <= 32) return firstSentence;
    return '${firstSentence.substring(0, 32).trim()}…';
  }
}
