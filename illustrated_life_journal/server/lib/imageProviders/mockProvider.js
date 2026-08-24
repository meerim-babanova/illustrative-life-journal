'use strict';

/**
 * A mock image provider for local development and manual UI testing
 * without a real OpenAI API key configured. Returns a static placeholder
 * illustration (served from server/public/mock) after a short simulated
 * delay, so the full write -> generate -> view flow can be exercised
 * end-to-end in Chrome without any external credential.
 *
 * This is opt-in only (IMAGE_PROVIDER=mock) — the default provider is
 * "openai", so a normal deployment never silently falls back to fake
 * images (Section 35: "do not leave the illustration feature as a
 * fake/mock feature if the required external API configuration is
 * available").
 *
 * @param {string} prompt
 * @returns {Promise<{ imageUrl: string }>}
 */
async function generateImage(prompt) {
  await new Promise((resolve) => setTimeout(resolve, 900));

  const baseUrl = process.env.PUBLIC_BASE_URL || `http://localhost:${process.env.PORT || 8787}`;
  return { imageUrl: `${baseUrl}/mock/placeholder-1.svg` };
}

module.exports = { generateImage };
