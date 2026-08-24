'use strict';

/**
 * Centralized illustration style description (mirrors
 * lib/features/journal/data/illustration_style.dart on the Flutter side —
 * keep the two in sync if the style is ever tuned).
 */
const STYLE_DESCRIPTION =
  'A warm, soft, friendly editorial illustration in a storybook and ' +
  'personal-journal aesthetic. Clean, simple shapes, tasteful muted warm ' +
  'colors, gentle lighting, emotionally expressive character poses. Not ' +
  'photorealistic, not hyper-detailed, not chaotic, not horror or ' +
  'unsettling in any way.';

/**
 * Turns the structured character description sent by the client into one
 * human-readable sentence. Reads only known, expected fields — nothing
 * free-form from the client is interpolated directly into the prompt
 * (defense in depth: the client's `character` object is untrusted input,
 * even though it's also authored by our own app).
 *
 * @param {Record<string, unknown>} character
 */
function describeCharacter(character = {}) {
  const str = (v, fallback) => (typeof v === 'string' && v.trim() ? v.trim() : fallback);
  const readable = (v) => str(v, 'unspecified').replace(/_/g, ' ');

  const faceShape = readable(character.faceShape);
  const eyeShape = readable(character.eyeShape);
  const eyeColor = readable(character.eyeColor);
  const hairStyle = readable(character.hairStyle);
  const hairColor = readable(character.hairColor);
  const skinTone = readable(character.skinTone);
  const bodyType = readable(character.bodyType);
  const outfitTop = readable(character.outfitTop);

  const accessories = Array.isArray(character.accessories)
    ? character.accessories
        .filter((a) => typeof a === 'string')
        .map((a) => a.replace(/^acc_/, '').replace(/_/g, ' '))
    : [];
  const accessoriesClause = accessories.length ? `, wearing ${accessories.join(', ')}` : '';

  return (
    `A simple illustrated character with a ${faceShape} face, ${eyeShape} ` +
    `${eyeColor} eyes, ${hairStyle} ${hairColor} hair, a ${skinTone} skin ` +
    `tone, and a ${bodyType} build, wearing a ${outfitTop}${accessoriesClause}.`
  );
}

/**
 * Builds the full structured prompt (Section 15 of the spec) from
 * request-provided journal text and character data.
 *
 * @param {{ journalText: string, character: Record<string, unknown> }} params
 * @returns {string}
 */
function buildIllustrationPrompt({ journalText, character }) {
  const characterDescription = describeCharacter(character);
  const memory = String(journalText || '').trim();

  return [
    'SYSTEM STYLE:',
    STYLE_DESCRIPTION,
    '',
    'CHARACTER:',
    characterDescription,
    '',
    'MEMORY:',
    memory,
    '',
    'SCENE:',
    'Infer the single most important visual moment from the memory above and depict the character living it.',
    '',
    'COMPOSITION:',
    'One coherent illustration suitable for a personal journal page.',
    '',
    'CONSTRAINTS:',
    "- preserve the character's described identity",
    '- no text, captions, watermarks, or UI elements inside the image',
    '- no borders unless they are deliberately part of the illustrated scene',
    '- avoid photorealism',
    '- keep the composition simple and readable',
    '- focus on the emotional/story moment',
  ].join('\n');
}

module.exports = { buildIllustrationPrompt, describeCharacter, STYLE_DESCRIPTION };
