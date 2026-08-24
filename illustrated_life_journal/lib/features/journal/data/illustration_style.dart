/// Centralized illustration style configuration.
///
/// Every generation request references [id], and the full description text
/// lives in exactly one place so the visual style can be tuned later
/// without hunting through UI or service code (Section 14 of the product
/// spec).
class IllustrationStyle {
  IllustrationStyle._();

  static const String id = 'illustrated-life-journal-v1';

  static const String description =
      'A warm, soft, friendly editorial illustration in a storybook and '
      'personal-journal aesthetic. Clean, simple shapes, tasteful muted '
      'warm colors, gentle lighting, emotionally expressive character '
      'poses. Not photorealistic, not hyper-detailed, not chaotic, not '
      'horror or unsettling in any way.';
}
