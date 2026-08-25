import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../character/models/character_config.dart';
import '../data/illustration_generation_service.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';

/// Single source of truth for the user's journal entries: loading them
/// from persistence, creating new ones, and driving illustration
/// generation/regeneration for a given entry.
///
/// Every entry lives in [entries] (newest first) for the whole app
/// session; there is no separate transient "current entry" — screens look
/// entries up by id from route arguments, which is what lets a page
/// refresh or a direct navigation to Journal Page always show the right
/// persisted state.
class JournalProvider extends ChangeNotifier {
  JournalProvider({
    JournalRepository? repository,
    IllustrationGenerationService? illustrationService,
  })  : _repository = repository ?? LocalJournalRepository(),
        _illustrationService = illustrationService;

  final JournalRepository _repository;

  /// Nullable because the illustration service needs a backend base URL
  /// that's only known at app wiring time (see `app.dart`). Generation
  /// methods fail gracefully with a clear message if this was never set.
  final IllustrationGenerationService? _illustrationService;

  static const _uuid = Uuid();

  bool _isLoading = true;
  List<JournalEntry> _entries = [];

  /// Ids currently generating, so the UI can disable duplicate requests
  /// per entry without a single global "isGenerating" flag blocking
  /// unrelated entries.
  final Set<String> _generatingIds = {};

  bool get isLoading => _isLoading;

  /// Newest first.
  List<JournalEntry> get entries => List.unmodifiable(_entries);

  JournalEntry? entryById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  bool isGenerating(String entryId) => _generatingIds.contains(entryId);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _repository.loadAll();
    _sort();

    _isLoading = false;
    notifyListeners();
  }

  void _sort() {
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist() => _repository.saveAll(_entries);

  void _replace(JournalEntry updated) {
    final index = _entries.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _entries[index] = updated;
  }

  /// Creates and persists a new journal entry. Does not start generation —
  /// call [generateIllustration] separately so the UI can show the entry
  /// immediately and generation as a distinct, cancellable/retryable step.
  Future<JournalEntry> createEntry({
    required String text,
    String? title,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: _uuid.v4(),
      title: (title?.trim().isNotEmpty ?? false) ? title!.trim() : _titleFromText(text),
      text: text.trim(),
      date: now,
      createdAt: now,
      updatedAt: now,
    );

    _entries.insert(0, entry);
    _sort();
    notifyListeners();
    await _persist();
    return entry;
  }

  String _titleFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'A quiet moment';
    final firstSentence = trimmed.split(RegExp(r'[.!?]')).first.trim();
    if (firstSentence.length <= 40) return firstSentence;
    return '${firstSentence.substring(0, 40).trim()}…';
  }

  /// Starts illustration generation for [entryId]. Safe to call even if a
  /// generation is already running for a different entry; guards against
  /// starting a second concurrent generation for the *same* entry.
  Future<void> generateIllustration(String entryId, CharacterConfig character) async {
    final entry = entryById(entryId);
    if (entry == null) return;
    if (_generatingIds.contains(entryId)) return; // no duplicate requests

    final service = _illustrationService;
    if (service == null) {
      _replace(entry.copyWith(
        generationStatus: GenerationStatus.failed,
        generationError: 'Illustration generation is not configured yet.',
      ));
      notifyListeners();
      await _persist();
      return;
    }

    _generatingIds.add(entryId);
    _replace(entry.copyWith(
      generationStatus: GenerationStatus.generating,
      generationError: null,
    ));
    notifyListeners();

    try {
      final result = await service.generate(entry: entry, character: character);
      final current = entryById(entryId) ?? entry;
      _replace(current.copyWith(
        generationStatus: GenerationStatus.generated,
        illustrationUrl: result.imageUrl,
        generationError: null,
      ));
    } on IllustrationGenerationFailure catch (e) {
      // Deliberately keep the *previous* illustrationUrl untouched here —
      // copyWith without passing illustrationUrl leaves it as-is, so a
      // failed regeneration never destroys a prior successful image.
      debugPrint('Illustration generation failed: ${e.technicalDetail}');
      final current = entryById(entryId) ?? entry;
      _replace(current.copyWith(
        generationStatus: GenerationStatus.failed,
        generationError: e.userMessage,
      ));
    } catch (e) {
      debugPrint('Illustration generation failed with an unexpected error: $e');
      final current = entryById(entryId) ?? entry;
      _replace(current.copyWith(
        generationStatus: GenerationStatus.failed,
        generationError: "We couldn't create the illustration this time.",
      ));
    } finally {
      _generatingIds.remove(entryId);
      notifyListeners();
      await _persist();
    }
  }

  /// Regenerates the illustration for an entry that already has one.
  /// Identical to [generateIllustration] — the "keep the old image on
  /// failure" behavior is already built into how failures are handled
  /// above (the old `illustrationUrl` is never cleared until a *new*
  /// successful result replaces it).
  Future<void> regenerateIllustration(String entryId, CharacterConfig character) =>
      generateIllustration(entryId, character);

  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    await _persist();
  }
}
