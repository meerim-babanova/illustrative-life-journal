import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../character/data/character_prompt_builder.dart';
import '../../character/models/character_config.dart';
import '../models/journal_entry.dart';
import 'illustration_style.dart';

/// A successful illustration generation result.
class IllustrationGenerationResult {
  const IllustrationGenerationResult({required this.imageUrl});

  final String imageUrl;
}

/// A user-safe failure. [userMessage] is always fit to show directly in
/// the UI; [technicalDetail] (never shown to the user) is only for
/// developer-facing logs.
class IllustrationGenerationFailure implements Exception {
  const IllustrationGenerationFailure(this.userMessage, [this.technicalDetail]);

  final String userMessage;
  final Object? technicalDetail;

  @override
  String toString() => 'IllustrationGenerationFailure: $userMessage'
      '${technicalDetail != null ? ' ($technicalDetail)' : ''}';
}

/// Turns a [JournalEntry] + the user's [CharacterConfig] into a generated
/// illustration.
///
/// This is the single seam the UI depends on (Section 12/31 of the Phase 2
/// spec) — screens and [JournalProvider] only ever call [generate]; they
/// never know which AI provider is behind it, or that a backend call is
/// even involved. That detail lives entirely in the implementation below.
abstract class IllustrationGenerationService {
  Future<IllustrationGenerationResult> generate({
    required JournalEntry entry,
    required CharacterConfig character,
  });
}

/// Calls this app's own backend (see `server/`), which is the only thing
/// that ever holds the real AI provider API key. The Flutter client never
/// talks to the image-generation provider directly (Section 11).
class BackendIllustrationGenerationService implements IllustrationGenerationService {
  BackendIllustrationGenerationService({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<IllustrationGenerationResult> generate({
    required JournalEntry entry,
    required CharacterConfig character,
  }) async {
    final uri = Uri.parse('$baseUrl/generate-illustration');
    final body = jsonEncode({
      'journalText': entry.text,
      'character': CharacterPromptBuilder.describe(character),
      'style': IllustrationStyle.id,
    });

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);
    } catch (e) {
      // Network failure, timeout, backend not running, DNS failure, etc.
      // Never surface the raw exception to the user (Section 30).
      throw IllustrationGenerationFailure(
        "We couldn't reach the illustration service. Please check your "
        'connection and try again.',
        e,
      );
    }

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      json = null;
    }

    if (response.statusCode == 200 && json != null && json['imageUrl'] is String) {
      return IllustrationGenerationResult(imageUrl: json['imageUrl'] as String);
    }

    final serverMessage = json?['error'] as String?;
    throw IllustrationGenerationFailure(
      "We couldn't create the illustration this time. Please try again.",
      'HTTP ${response.statusCode}${serverMessage != null ? ': $serverMessage' : ''}',
    );
  }
}
