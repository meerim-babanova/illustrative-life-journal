import 'dart:ui';

/// When the remembered moment happened. Drives the whole palette so two
/// memories written about different times of day never look alike.
enum SceneTime { morning, day, goldenHour, night }

/// Weather read out of the user's own words.
enum SceneWeather { clear, cloudy, rain, snow }

/// Where the moment happened.
enum ScenePlace { indoor, city, nature, water }

/// Emotional temperature — nudges warmth and light, never the layout.
enum SceneMood { warm, calm, tender, lively }

/// The colours an illustration is drawn with. Kept muted and paper-like so
/// generated art sits inside the Phase 1 palette rather than shouting over
/// it.
class ScenePalette {
  const ScenePalette({
    required this.skyTop,
    required this.skyBottom,
    required this.land,
    required this.landDeep,
    required this.glow,
    required this.accent,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color land;
  final Color landDeep;
  final Color glow;
  final Color accent;
}

/// A structured description of the moment, produced from free text by
/// SceneInterpreter and consumed by an IllustrationProvider.
///
/// This is the "structured scene" seam from the product spec: the text
/// interpreter fills it in, and any renderer (local painter today, a hosted
/// image model later) can draw from it without the UI changing.
class IllustrationScene {
  const IllustrationScene({
    required this.seed,
    required this.time,
    required this.weather,
    required this.place,
    required this.mood,
    required this.companions,
    required this.palette,
    required this.details,
  });

  /// Changing only the seed is what "Regenerate" does: the same reading of
  /// the memory, a different drawing of it.
  final int seed;
  final SceneTime time;
  final SceneWeather weather;
  final ScenePlace place;
  final SceneMood mood;

  /// How many other figures stand with the character (0-2).
  final int companions;
  final ScenePalette palette;

  /// Short human-readable notes ("golden light", "by the water") shown as
  /// the illustration's caption so the user can see what was understood.
  final List<String> details;

  IllustrationScene copyWith({
    int? seed,
    SceneMood? mood,
    SceneTime? time,
    int? companions,
    ScenePalette? palette,
    List<String>? details,
  }) {
    return IllustrationScene(
      seed: seed ?? this.seed,
      time: time ?? this.time,
      weather: weather,
      place: place,
      mood: mood ?? this.mood,
      companions: companions ?? this.companions,
      palette: palette ?? this.palette,
      details: details ?? this.details,
    );
  }
}
