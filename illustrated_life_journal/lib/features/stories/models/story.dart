/// A collection of journal entries grouped under a shared theme or trip
/// (e.g. "Japan Trip", "Summer 2026").
///
/// Still backed by mock data in Phase 2 — full story/entry linkage (so a
/// story's cover is automatically one of its entries' illustrations) is
/// future work; [thumbnailUrl] exists now so [StoryCard] already supports
/// displaying a real illustration the moment that linkage exists.
class Story {
  const Story({
    required this.id,
    required this.title,
    this.description,
    this.coverColorSeed,
    this.entryCount = 0,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String? description;

  /// Used to pick a placeholder cover color deterministically when no
  /// [thumbnailUrl] is available yet.
  final int? coverColorSeed;
  final int entryCount;

  /// A generated illustration to use as this story's cover, if one exists.
  final String? thumbnailUrl;
}
