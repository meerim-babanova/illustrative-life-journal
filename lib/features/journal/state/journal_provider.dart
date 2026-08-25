import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/journal_generation_service.dart';
import '../models/illustration_scene.dart';
import '../models/journal_entry.dart';
import '../models/journal_page.dart';

/// Coordinates write -> illustrate -> keep for the page being worked on.
///
/// Phase 2 additions: a real failure state that never carries technical
/// detail, non-destructive regeneration with restorable takes, and a kept
/// list of pages for Home and Stories.
class JournalProvider extends ChangeNotifier {
  JournalProvider({JournalGenerationService? generationService})
      : _service = generationService ?? SceneJournalGenerationService();

  final JournalGenerationService _service;
  static const _uuid = Uuid();

  JournalEntry? _entry;
  JournalPage? _page;
  bool _isWorking = false;
  bool _failed = false;

  JournalEntry? get currentEntry => _entry;
  JournalPage? get currentPage => _page;
  bool get isWorking => _isWorking;

  /// True when the last attempt didn't produce an illustration. The words
  /// are always still here — see [draftText].
  bool get hasFailed => _failed;

  /// The user's writing, kept through failure and retry so it can never be
  /// lost by a generation problem.
  String get draftText => _entry?.text ?? '';

  /// Pages the user chose to keep, newest first.
  final List<JournalPage> pages = [];

  List<JournalPage> get recentPages => pages;

  Future<void> generateFromText(
    String text, {
    String? storyId,
    String? storyTitle,
  }) async {
    _entry = JournalEntry(
      id: _uuid.v4(),
      text: text,
      date: DateTime.now(),
      storyId: storyId,
    );
    _page = null;
    await _run(() => _service.generate(_entry!), storyTitle: storyTitle);
  }

  /// Retry after a failure, with the same words.
  Future<void> retry() async {
    final entry = _entry;
    if (entry == null) return;
    await _run(() => _service.generate(entry));
  }

  /// A different drawing of the same memory. The writing is untouched and
  /// the current illustration is kept as a take.
  Future<void> regenerate({String? nudge}) async {
    final page = _page;
    if (page == null) return;
    await _run(() => _service.regenerate(page, nudge: nudge));
  }

  /// Go back to an illustration this page had before.
  void restoreTake(IllustrationScene take) {
    final page = _page;
    if (page == null) return;
    _page = page.withNewTake(take);
    notifyListeners();
  }

  /// Commit the page to the journal.
  void keepPage() {
    final page = _page;
    if (page == null) return;
    pages.removeWhere((p) => p.id == page.id);
    pages.insert(0, page);
    notifyListeners();
  }

  /// Failure escape hatch: keep the writing without an illustration, so a
  /// broken generation never costs the user their memory.
  void keepWritingOnly() {
    final entry = _entry;
    if (entry == null) return;
    _failed = false;
    notifyListeners();
  }

  void reset() {
    _entry = null;
    _page = null;
    _isWorking = false;
    _failed = false;
    notifyListeners();
  }

  Future<void> _run(
    Future<JournalPage> Function() task, {
    String? storyTitle,
  }) async {
    _isWorking = true;
    _failed = false;
    notifyListeners();
    try {
      final result = await task();
      _page = storyTitle == null
          ? result
          : result.copyWith(storyTitle: storyTitle);
    } catch (_) {
      // Nothing technical ever reaches the UI.
      _failed = true;
    } finally {
      _isWorking = false;
      notifyListeners();
    }
  }
}
