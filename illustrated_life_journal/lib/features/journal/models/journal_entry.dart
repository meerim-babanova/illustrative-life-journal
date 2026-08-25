/// Status of a journal entry's illustration generation.
///
/// - [none]: no generation has been attempted yet.
/// - [generating]: a request is currently in flight.
/// - [generated]: [JournalEntry.illustrationUrl] holds a successful result.
/// - [failed]: the most recent attempt failed. If a previous successful
///   [JournalEntry.illustrationUrl] exists, it is deliberately preserved
///   (see [JournalProvider.regenerateIllustration]) rather than cleared, so
///   a failed regeneration never destroys a working illustration.
enum GenerationStatus { none, generating, generated, failed }

extension GenerationStatusJson on GenerationStatus {
  String get asJson => name;

  static GenerationStatus fromJson(String? value) {
    return GenerationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => GenerationStatus.none,
    );
  }
}

/// A single free-form journal entry: the user's written memory, plus
/// whatever illustration-generation progress/result exists for it.
///
/// This is the single source of truth for a memory — there is no separate
/// "journal page" model. The Journal Page screen renders directly from a
/// [JournalEntry].
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.storyId,
    this.generationStatus = GenerationStatus.none,
    this.illustrationUrl,
    this.generationError,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final String text;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? storyId;
  final GenerationStatus generationStatus;

  /// Reference to the generated illustration (a URL served by the backend/
  /// image host), not the raw image bytes — journal entries stay small and
  /// cheap to persist locally (see Section 20 of the Phase 2 spec).
  final String? illustrationUrl;

  /// A short, user-safe message describing the most recent failure, if
  /// any. Never the raw provider/server error (Section 30: don't expose
  /// raw backend responses to the user).
  final String? generationError;

  final Map<String, dynamic> metadata;

  /// A short, readable preview of [text] for list/card display.
  String get preview {
    final singleLine = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (singleLine.length <= 90) return singleLine;
    return '${singleLine.substring(0, 90).trim()}…';
  }

  JournalEntry copyWith({
    String? title,
    String? text,
    String? storyId,
    GenerationStatus? generationStatus,
    Object? illustrationUrl = _sentinel,
    Object? generationError = _sentinel,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      storyId: storyId ?? this.storyId,
      generationStatus: generationStatus ?? this.generationStatus,
      illustrationUrl: identical(illustrationUrl, _sentinel)
          ? this.illustrationUrl
          : illustrationUrl as String?,
      generationError: identical(generationError, _sentinel)
          ? this.generationError
          : generationError as String?,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'storyId': storyId,
        'generationStatus': generationStatus.asJson,
        'illustrationUrl': illustrationUrl,
        'generationError': generationError,
        'metadata': metadata,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      storyId: json['storyId'] as String?,
      generationStatus:
          GenerationStatusJson.fromJson(json['generationStatus'] as String?),
      illustrationUrl: json['illustrationUrl'] as String?,
      generationError: json['generationError'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

/// Sentinel used to distinguish "not passed" from "explicitly passed null"
/// in [JournalEntry.copyWith], since `illustrationUrl`/`generationError`
/// legitimately need to be clearable back to null (e.g. starting a fresh
/// generation clears a prior error).
const Object _sentinel = Object();
