import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/journal_generation_service.dart';
import '../models/journal_entry.dart';
import '../models/journal_page.dart';

/// Coordinates the write -> generate -> view flow for a single journal
/// entry at a time.
///
/// Phase 1 keeps everything in memory; nothing is persisted yet, since the
/// full data model (with Stories, Supabase, etc.) is Phase 3's job. This
/// class exists so the Generation and Journal Page screens don't need to
/// pass large objects through route arguments and so the mock service is
/// swappable in one place.
class JournalProvider extends ChangeNotifier {
  JournalProvider({JournalGenerationService? generationService})
      : _generationService = generationService ?? MockJournalGenerationService();

  final JournalGenerationService _generationService;
  static const _uuid = Uuid();

  JournalEntry? _currentEntry;
  JournalPage? _currentPage;
  bool _isGenerating = false;
  String? _error;

  JournalEntry? get currentEntry => _currentEntry;
  JournalPage? get currentPage => _currentPage;
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  /// Recent, already-generated pages shown on Home as "recent memories".
  /// In-memory only for Phase 1.
  final List<JournalPage> recentPages = [];

  Future<void> generateFromText(String text) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      text: text,
      date: DateTime.now(),
    );
    _currentEntry = entry;
    _currentPage = null;
    _error = null;
    _isGenerating = true;
    notifyListeners();

    try {
      final page = await _generationService.generate(entry);
      _currentPage = page;
      recentPages.insert(0, page);
    } catch (e) {
      _error = 'Something went wrong creating your page. Please try again.';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentEntry = null;
    _currentPage = null;
    _error = null;
    _isGenerating = false;
    notifyListeners();
  }
}
