import 'illustration_scene.dart';

/// The illustrated result of a journal entry.
///
/// Phase 2 replaces the old placeholder colour seed with a real
/// [IllustrationScene] plus every earlier take, so regenerating is never
/// destructive.
class JournalPage {
  const JournalPage({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.scene,
    this.storyId,
    this.storyTitle,
    this.previousTakes = const [],
  });

  final String id;
  final String title;
  final String text;
  final DateTime date;
  final IllustrationScene scene;
  final String? storyId;
  final String? storyTitle;

  /// Every illustration this page has had, oldest first.
  final List<IllustrationScene> previousTakes;

  int get wordCount => text.trim().isEmpty
      ? 0
      : text.trim().split(RegExp(r'\s+')).length;

  JournalPage copyWith({
    String? title,
    IllustrationScene? scene,
    String? storyId,
    String? storyTitle,
    List<IllustrationScene>? previousTakes,
  }) {
    return JournalPage(
      id: id,
      title: title ?? this.title,
      text: text,
      date: date,
      scene: scene ?? this.scene,
      storyId: storyId ?? this.storyId,
      storyTitle: storyTitle ?? this.storyTitle,
      previousTakes: previousTakes ?? this.previousTakes,
    );
  }

  /// Adds a new illustration while keeping the current one as a take.
  JournalPage withNewTake(IllustrationScene next) =>
      copyWith(scene: next, previousTakes: [...previousTakes, scene]);
}
