import '../models/illustration_scene.dart';
import 'scene_interpreter.dart';

/// Produces the illustration for a memory.
///
/// Two implementations are expected to coexist:
///
/// * [LocalSceneIllustrationProvider] — always available, no network, no
///   API key. It returns a fully-specified [IllustrationScene] which the app
///   paints itself (see SceneIllustration). This is why illustrations appear
///   in Phase 2 at all: nothing external has to be configured.
/// * a hosted image provider — added later behind this same interface; the
///   screens, provider, and models do not change when it lands.
abstract class IllustrationProvider {
  Future<IllustrationScene> illustrate(String text, {int? seed});

  Future<IllustrationScene> reillustrate(
    IllustrationScene scene, {
    String? nudge,
    int? seed,
  });
}

class LocalSceneIllustrationProvider implements IllustrationProvider {
  LocalSceneIllustrationProvider({
    this.interpreter = const SceneInterpreter(),
    this.thinkingTime = const Duration(milliseconds: 2400),
  });

  final SceneInterpreter interpreter;

  /// A short, honest pause so the generation state can be read. It is never
  /// surfaced as a percentage.
  final Duration thinkingTime;

  @override
  Future<IllustrationScene> illustrate(String text, {int? seed}) async {
    await Future<void>.delayed(thinkingTime);
    if (text.trim().isEmpty) throw const IllustrationFailure();
    return interpreter.interpret(text, seed: seed);
  }

  @override
  Future<IllustrationScene> reillustrate(
    IllustrationScene scene, {
    String? nudge,
    int? seed,
  }) async {
    await Future<void>.delayed(thinkingTime);
    return interpreter.nudge(scene, nudge: nudge, seed: seed);
  }
}

/// The only failure type the UI ever sees. Deliberately carries no
/// technical detail — the failure state speaks in the user's language.
class IllustrationFailure implements Exception {
  const IllustrationFailure();
}
