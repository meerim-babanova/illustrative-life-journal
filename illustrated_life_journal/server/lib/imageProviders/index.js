'use strict';

/**
 * @typedef {{ generateImage: (prompt: string) => Promise<{ imageUrl: string }> }} ImageProvider
 */

/**
 * Returns the configured image provider. This is the one place that knows
 * which vendor is in use — the request handler in index.js only ever calls
 * `provider.generateImage(prompt)`, so swapping providers later (Section 12
 * of the spec: "isolated behind a service abstraction so it can be
 * replaced later") never touches route/request-handling code.
 *
 * @returns {ImageProvider}
 */
function getImageProvider() {
  const name = (process.env.IMAGE_PROVIDER || 'openai').toLowerCase();

  switch (name) {
    case 'openai':
      // Lazy require so an unconfigured/unused provider's module can't
      // fail to load and take down the whole server.
      return require('./openaiProvider');
    case 'mock':
      return require('./mockProvider');
    default:
      throw new Error(`Unknown IMAGE_PROVIDER "${name}"`);
  }
}

module.exports = { getImageProvider };
