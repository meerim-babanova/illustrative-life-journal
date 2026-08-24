/// Structured, persistent configuration describing the user's character.
///
/// This is intentionally plain data — it has no knowledge of Flutter
/// widgets, rendering, or any specific AI image provider. Later phases will
/// pass this object into an image generation pipeline (see the product
/// spec's "Character Asset Architecture" and "AI Architecture" sections);
/// for Phase 1 it only drives the local placeholder preview.
class CharacterConfig {
  const CharacterConfig({
    required this.skinTone,
    required this.headShape,
    required this.eyeShape,
    required this.eyeColor,
    required this.eyebrowStyle,
    required this.noseStyle,
    required this.mouthStyle,
    required this.hairStyle,
    required this.hairColor,
    required this.bodyType,
    required this.outfitTop,
    required this.outfitBottom,
    required this.outfitShoes,
    this.accessories = const [],
  });

  final String skinTone;
  final String headShape;
  final String eyeShape;
  final String eyeColor;
  final String eyebrowStyle;
  final String noseStyle;
  final String mouthStyle;
  final String hairStyle;
  final String hairColor;
  final String bodyType;
  final String outfitTop;
  final String outfitBottom;
  final String outfitShoes;
  final List<String> accessories;

  /// A reasonable default so the app always has *some* character to show,
  /// even before the user has customized anything.
  factory CharacterConfig.defaultConfig() => const CharacterConfig(
        skinTone: 'medium',
        headShape: 'round',
        eyeShape: 'round',
        eyeColor: 'brown',
        eyebrowStyle: 'soft',
        noseStyle: 'small',
        mouthStyle: 'gentle-smile',
        hairStyle: 'shoulder_bangs',
        hairColor: 'chestnut',
        bodyType: 'average',
        outfitTop: 'cream_sweater',
        outfitBottom: 'denim',
        outfitShoes: 'white-sneakers',
        accessories: [],
      );

  CharacterConfig copyWith({
    String? skinTone,
    String? headShape,
    String? eyeShape,
    String? eyeColor,
    String? eyebrowStyle,
    String? noseStyle,
    String? mouthStyle,
    String? hairStyle,
    String? hairColor,
    String? bodyType,
    String? outfitTop,
    String? outfitBottom,
    String? outfitShoes,
    List<String>? accessories,
  }) {
    return CharacterConfig(
      skinTone: skinTone ?? this.skinTone,
      headShape: headShape ?? this.headShape,
      eyeShape: eyeShape ?? this.eyeShape,
      eyeColor: eyeColor ?? this.eyeColor,
      eyebrowStyle: eyebrowStyle ?? this.eyebrowStyle,
      noseStyle: noseStyle ?? this.noseStyle,
      mouthStyle: mouthStyle ?? this.mouthStyle,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      bodyType: bodyType ?? this.bodyType,
      outfitTop: outfitTop ?? this.outfitTop,
      outfitBottom: outfitBottom ?? this.outfitBottom,
      outfitShoes: outfitShoes ?? this.outfitShoes,
      accessories: accessories ?? this.accessories,
    );
  }

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone,
        'headShape': headShape,
        'eyeShape': eyeShape,
        'eyeColor': eyeColor,
        'eyebrowStyle': eyebrowStyle,
        'noseStyle': noseStyle,
        'mouthStyle': mouthStyle,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'bodyType': bodyType,
        'outfitTop': outfitTop,
        'outfitBottom': outfitBottom,
        'outfitShoes': outfitShoes,
        'accessories': accessories,
      };

  factory CharacterConfig.fromJson(Map<String, dynamic> json) {
    final fallback = CharacterConfig.defaultConfig();
    return CharacterConfig(
      skinTone: json['skinTone'] as String? ?? fallback.skinTone,
      headShape: json['headShape'] as String? ?? fallback.headShape,
      eyeShape: json['eyeShape'] as String? ?? fallback.eyeShape,
      eyeColor: json['eyeColor'] as String? ?? fallback.eyeColor,
      eyebrowStyle: json['eyebrowStyle'] as String? ?? fallback.eyebrowStyle,
      noseStyle: json['noseStyle'] as String? ?? fallback.noseStyle,
      mouthStyle: json['mouthStyle'] as String? ?? fallback.mouthStyle,
      hairStyle: json['hairStyle'] as String? ?? fallback.hairStyle,
      hairColor: json['hairColor'] as String? ?? fallback.hairColor,
      bodyType: json['bodyType'] as String? ?? fallback.bodyType,
      outfitTop: json['outfitTop'] as String? ?? fallback.outfitTop,
      outfitBottom: json['outfitBottom'] as String? ?? fallback.outfitBottom,
      outfitShoes: json['outfitShoes'] as String? ?? fallback.outfitShoes,
      accessories: (json['accessories'] as List?)?.cast<String>() ??
          fallback.accessories,
    );
  }
}
