import 'dart:math';
import 'dart:ui';

import '../models/illustration_scene.dart';

/// Turns the words a person actually wrote into an [IllustrationScene].
///
/// Deliberately local and rule-based: it runs instantly, offline, costs
/// nothing, and is deterministic, so the same memory always reads the same
/// way. When a hosted text model is wired up later it replaces this class
/// only — [IllustrationScene] and everything above it stay put.
class SceneInterpreter {
  const SceneInterpreter();

  static const _morning = ['morning', 'dawn', 'sunrise', 'breakfast', 'early'];
  static const _golden = ['evening', 'sunset', 'golden', 'dusk', 'sundown'];
  static const _night = ['night', 'midnight', 'stars', 'moon', 'dark'];

  static const _rain = ['rain', 'raining', 'rainy', 'drizzle', 'storm', 'wet'];
  static const _snow = ['snow', 'snowing', 'frost', 'blizzard'];
  static const _cloudy = ['cloud', 'cloudy', 'grey', 'gray', 'overcast', 'fog'];

  static const _indoor = [
    'cafe', 'kitchen', 'room', 'home', 'apartment', 'library', 'class',
    'office', 'shop', 'restaurant', 'inside', 'indoors', 'bed'
  ];
  static const _water = [
    'canal', 'river', 'sea', 'ocean', 'lake', 'beach', 'harbour', 'harbor',
    'pier', 'boat', 'swim'
  ];
  static const _nature = [
    'park', 'forest', 'mountain', 'garden', 'tree', 'trees', 'field',
    'hill', 'trail', 'flowers'
  ];
  static const _city = [
    'city', 'street', 'bus', 'train', 'market', 'square', 'traffic',
    'downtown', 'metro', 'tram'
  ];

  static const _lively = ['laugh', 'party', 'danced', 'music', 'loud', 'fun'];
  static const _tender = ['missed', 'cried', 'tired', 'quietly', 'alone', 'goodbye'];
  static const _calm = ['calm', 'quiet', 'slow', 'still', 'read', 'rest'];

  static const _company = [
    ' we ', ' us ', ' our ', 'together', 'friend', 'mom', 'mum', 'dad',
    'sister', 'brother', 'with '
  ];

  IllustrationScene interpret(String text, {int? seed}) {
    final t = ' ' + text.toLowerCase() + ' ';
    final resolvedSeed = seed ?? text.hashCode.abs();

    final time = _has(t, _night)
        ? SceneTime.night
        : _has(t, _golden)
            ? SceneTime.goldenHour
            : _has(t, _morning)
                ? SceneTime.morning
                : SceneTime.day;

    final weather = _has(t, _snow)
        ? SceneWeather.snow
        : _has(t, _rain)
            ? SceneWeather.rain
            : _has(t, _cloudy)
                ? SceneWeather.cloudy
                : SceneWeather.clear;

    final place = _has(t, _water)
        ? ScenePlace.water
        : _has(t, _indoor)
            ? ScenePlace.indoor
            : _has(t, _city)
                ? ScenePlace.city
                : _has(t, _nature)
                    ? ScenePlace.nature
                    : ScenePlace.city;

    final mood = _has(t, _lively)
        ? SceneMood.lively
        : _has(t, _tender)
            ? SceneMood.tender
            : _has(t, _calm)
                ? SceneMood.calm
                : SceneMood.warm;

    final companions =
        _has(t, _company) ? (Random(resolvedSeed).nextBool() ? 2 : 1) : 0;

    return IllustrationScene(
      seed: resolvedSeed,
      time: time,
      weather: weather,
      place: place,
      mood: mood,
      companions: companions,
      palette: paletteFor(time, mood),
      details: _details(time, weather, place, companions),
    );
  }

  /// Re-reads the same memory with an optional nudge from the Regenerate
  /// sheet. The writing is never touched.
  IllustrationScene nudge(IllustrationScene scene, {String? nudge, int? seed}) {
    var next = scene.copyWith(seed: seed ?? scene.seed + 1);
    switch (nudge) {
      case 'Golden hour':
        next = next.copyWith(
          time: SceneTime.goldenHour,
          palette: paletteFor(SceneTime.goldenHour, next.mood),
        );
        break;
      case 'Quieter':
        next = next.copyWith(
          mood: SceneMood.calm,
          companions: 0,
          palette: paletteFor(next.time, SceneMood.calm),
        );
        break;
      case 'More people':
        next = next.copyWith(companions: 2);
        break;
      default:
        break;
    }
    return next;
  }

  static ScenePalette paletteFor(SceneTime time, SceneMood mood) {
    final warmer = mood == SceneMood.warm || mood == SceneMood.lively;
    switch (time) {
      case SceneTime.morning:
        return ScenePalette(
          skyTop: const Color(0xFFE9E2D2),
          skyBottom: const Color(0xFFF7EEDF),
          land: const Color(0xFFCFD3BC),
          landDeep: const Color(0xFF8A9A7E),
          glow: const Color(0xFFF3DCC4),
          accent: warmer ? const Color(0xFFE88C7D) : const Color(0xFFA98F72),
        );
      case SceneTime.day:
        return ScenePalette(
          skyTop: const Color(0xFFDCE3DE),
          skyBottom: const Color(0xFFF4EEE1),
          land: const Color(0xFFC5CDB4),
          landDeep: const Color(0xFF7C8C70),
          glow: const Color(0xFFF6EBD6),
          accent: warmer ? const Color(0xFFC98F6C) : const Color(0xFF8A9A7E),
        );
      case SceneTime.goldenHour:
        return ScenePalette(
          skyTop: const Color(0xFFE7C6AE),
          skyBottom: const Color(0xFFF8E6CE),
          land: const Color(0xFFC29A79),
          landDeep: const Color(0xFF8A6A50),
          glow: const Color(0xFFF6D9AE),
          accent: const Color(0xFFE88C7D),
        );
      case SceneTime.night:
        return ScenePalette(
          skyTop: const Color(0xFF3B3F4C),
          skyBottom: const Color(0xFF6E6A6B),
          land: const Color(0xFF4A4A4B),
          landDeep: const Color(0xFF2E2A26),
          glow: const Color(0xFFE9D9B6),
          accent: warmer ? const Color(0xFFE88C7D) : const Color(0xFFA98F72),
        );
    }
  }

  List<String> _details(
    SceneTime time,
    SceneWeather weather,
    ScenePlace place,
    int companions,
  ) {
    final out = <String>[];
    switch (time) {
      case SceneTime.morning:
        out.add('early light');
        break;
      case SceneTime.day:
        out.add('daylight');
        break;
      case SceneTime.goldenHour:
        out.add('golden light');
        break;
      case SceneTime.night:
        out.add('after dark');
        break;
    }
    switch (place) {
      case ScenePlace.water:
        out.add('by the water');
        break;
      case ScenePlace.indoor:
        out.add('indoors');
        break;
      case ScenePlace.nature:
        out.add('outdoors');
        break;
      case ScenePlace.city:
        out.add('in the city');
        break;
    }
    if (weather == SceneWeather.rain) out.add('rain');
    if (weather == SceneWeather.snow) out.add('snow');
    if (weather == SceneWeather.cloudy) out.add('soft clouds');
    if (companions > 0) out.add('not alone');
    return out;
  }

  bool _has(String haystack, List<String> needles) =>
      needles.any(haystack.contains);
}
