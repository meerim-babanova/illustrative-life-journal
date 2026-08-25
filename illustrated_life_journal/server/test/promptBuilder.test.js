'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const { buildIllustrationPrompt, describeCharacter, STYLE_DESCRIPTION } = require('../lib/promptBuilder');

test('describeCharacter falls back to "unspecified" for missing fields', () => {
  const description = describeCharacter({});
  assert.match(description, /unspecified face/);
  assert.match(description, /unspecified unspecified eyes/);
});

test('describeCharacter reads real character fields and humanizes underscores', () => {
  const description = describeCharacter({
    faceShape: 'heart',
    eyeShape: 'almond',
    eyeColor: 'green',
    hairStyle: 'long_wavy',
    hairColor: 'chestnut',
    skinTone: 'deep',
    bodyType: 'curvy',
    outfitTop: 'green_cardigan',
    accessories: ['acc_glasses', 'acc_cap'],
  });

  assert.match(description, /heart face/);
  assert.match(description, /almond green eyes/);
  assert.match(description, /long wavy chestnut hair/);
  assert.match(description, /deep skin tone/);
  assert.match(description, /curvy build/);
  assert.match(description, /green cardigan/);
  assert.match(description, /wearing .*glasses, cap/);
});

test('describeCharacter ignores non-string accessory entries defensively', () => {
  const description = describeCharacter({ accessories: ['acc_cap', 42, null, {}] });
  assert.match(description, /wearing cap/);
});

test('buildIllustrationPrompt includes every required structured section', () => {
  const prompt = buildIllustrationPrompt({
    journalText: 'Today I went to the park with my sister.',
    character: { faceShape: 'round' },
  });

  for (const section of [
    'SYSTEM STYLE:',
    'CHARACTER:',
    'MEMORY:',
    'SCENE:',
    'COMPOSITION:',
    'CONSTRAINTS:',
  ]) {
    assert.ok(prompt.includes(section), `missing section: ${section}`);
  }
});

test('buildIllustrationPrompt includes the exact journal text verbatim', () => {
  const text = 'A very specific memory about a rainy afternoon.';
  const prompt = buildIllustrationPrompt({ journalText: text, character: {} });
  assert.ok(prompt.includes(text));
});

test('buildIllustrationPrompt uses the centralized style description', () => {
  const prompt = buildIllustrationPrompt({ journalText: 'x', character: {} });
  assert.ok(prompt.includes(STYLE_DESCRIPTION));
});

test('buildIllustrationPrompt never omits the no-text/no-watermark constraint', () => {
  const prompt = buildIllustrationPrompt({ journalText: 'x', character: {} });
  assert.match(prompt, /no text, captions, watermarks/);
  assert.match(prompt, /avoid photorealism/);
});
