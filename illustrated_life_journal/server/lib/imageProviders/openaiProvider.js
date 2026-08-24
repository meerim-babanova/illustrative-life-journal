'use strict';

const OPENAI_IMAGES_URL = 'https://api.openai.com/v1/images/generations';

/**
 * Calls OpenAI's image generation API. The API key is read from the
 * environment at call time (never hardcoded, never sent to or readable by
 * the Flutter client — see Section 11 of the spec).
 *
 * @param {string} prompt
 * @returns {Promise<{ imageUrl: string }>}
 */
async function generateImage(prompt) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    // Thrown as a distinct, recognizable error so index.js can log a
    // specific "not configured" message server-side without ever
    // leaking this detail to the client response.
    const error = new Error('OPENAI_API_KEY is not configured on the server.');
    error.code = 'PROVIDER_NOT_CONFIGURED';
    throw error;
  }

  const response = await fetch(OPENAI_IMAGES_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'dall-e-3',
      prompt,
      n: 1,
      size: '1024x1024',
      response_format: 'url',
    }),
  });

  if (!response.ok) {
    let detail;
    try {
      const errorBody = await response.json();
      detail = errorBody?.error?.message;
    } catch (_) {
      detail = await response.text().catch(() => undefined);
    }
    const error = new Error(
      `OpenAI image generation failed (HTTP ${response.status})${detail ? `: ${detail}` : ''}`,
    );
    error.code = 'PROVIDER_REQUEST_FAILED';
    throw error;
  }

  const data = await response.json();
  const imageUrl = data?.data?.[0]?.url;
  if (!imageUrl) {
    const error = new Error('OpenAI response did not include an image URL.');
    error.code = 'PROVIDER_BAD_RESPONSE';
    throw error;
  }

  return { imageUrl };
}

module.exports = { generateImage };
