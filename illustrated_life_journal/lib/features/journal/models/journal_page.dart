/// The illustrated result of a journal entry.
///
/// For Phase 1, [illustrationSeed] only drives a placeholder color/icon —
/// there is no real illustration yet. Once Phases 4-6 build the
/// interpreter + image generation pipeline, this model gains real fields
/// (e.g. an image URL from Supabase Storage) without changing how the
/// Journal Page screen is invoked.
class JournalPage {
  const JournalPage({
    required this.title,
    required this.text,
    required this.date,
    required this.illustrationSeed,
  });

  final String title;
  final String text;
  final DateTime date;
  final int illustrationSeed;
}
