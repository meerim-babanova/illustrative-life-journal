/// Status of a journal entry's illustration generation.
///
/// In Phase 1 only [pending] and [completed] are ever reached, via the mock
/// generation flow. [processing] and [failed] are modeled now so the
/// Generation screen and future real AI/image pipeline (Phases 4-5) don't
/// require a data model change.
enum GenerationStatus { pending, processing, completed, failed }

/// A single free-form journal entry, before or after it has been turned
/// into an illustrated page.
class JournalEntry {
  JournalEntry({
    required this.id,
    required this.text,
    required this.date,
    this.storyId,
    this.title,
    this.mood,
    this.location,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.generationStatus = GenerationStatus.pending,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String? storyId;
  final String text;
  final DateTime date;
  final String? title;
  final String? mood;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GenerationStatus generationStatus;

  JournalEntry copyWith({
    GenerationStatus? generationStatus,
  }) {
    return JournalEntry(
      id: id,
      text: text,
      date: date,
      storyId: storyId,
      title: title,
      mood: mood,
      location: location,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      generationStatus: generationStatus ?? this.generationStatus,
    );
  }
}
