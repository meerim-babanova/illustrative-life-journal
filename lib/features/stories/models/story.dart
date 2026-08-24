/// A collection of journal entries grouped under a shared theme or trip
/// (e.g. "Japan Trip", "Summer 2026").
///
/// Phase 1 only needs enough of this model to render a basic Stories list
/// with mock data; the full data model (Supabase-backed, with real cover
/// images) arrives in Phase 3.
class Story {
  const Story({
    required this.id,
    required this.title,
    this.description,
    this.coverColorSeed,
    this.entryCount = 0,
  });

  final String id;
  final String title;
  final String? description;

  /// Used only to pick a placeholder cover color deterministically for a
  /// given story until real cover images exist.
  final int? coverColorSeed;
  final int entryCount;
}
