'use strict';

require('dotenv').config();

const express = require('express');
const cors = require('cors');

const { buildIllustrationPrompt } = require('./lib/promptBuilder');
const { getImageProvider } = require('./lib/imageProviders');

const PORT = process.env.PORT || 8787;
const MAX_JOURNAL_TEXT_LENGTH = 4000;

// In dev, the Flutter web app usually runs on a different localhost port
// (Flutter's dev server), so CORS must be enabled for local development.
// ALLOWED_ORIGIN should be set to your actual deployed frontend origin in
// production — '*' is a dev-only default, not a production-safe one.
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || '*';

const app = express();
app.use(cors({ origin: ALLOWED_ORIGIN }));
app.use(express.json({ limit: '256kb' }));

// Only used by the mock image provider (IMAGE_PROVIDER=mock) for local
// development without a real API key — see lib/imageProviders/mockProvider.js.
app.use('/mock', express.static(require('path').join(__dirname, 'public', 'mock')));

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'illustrated-life-journal-server' });
});

app.post('/generate-illustration', async (req, res) => {
  const { journalText, character, style } = req.body || {};

  if (typeof journalText !== 'string' || !journalText.trim()) {
    return res.status(400).json({ error: 'journalText is required.' });
  }
  if (journalText.length > MAX_JOURNAL_TEXT_LENGTH) {
    return res.status(400).json({
      error: `journalText must be ${MAX_JOURNAL_TEXT_LENGTH} characters or fewer.`,
    });
  }
  if (character !== undefined && (typeof character !== 'object' || character === null)) {
    return res.status(400).json({ error: 'character, if provided, must be an object.' });
  }

  // Section 30: never log full journal text (private personal content).
  // Log only non-sensitive metadata for observability.
  console.log(
    `[generate-illustration] request received: textLength=${journalText.length}, style=${style || 'default'}`,
  );

  try {
    const prompt = buildIllustrationPrompt({ journalText, character: character || {} });
    const provider = getImageProvider();
    const result = await provider.generateImage(prompt);
    return res.status(200).json({ imageUrl: result.imageUrl });
  } catch (error) {
    // Full technical detail goes to server logs only — the client always
    // gets a short, friendly, non-technical message (Section 30).
    console.error('[generate-illustration] generation failed:', error);
    return res.status(502).json({
      error: "We couldn't create the illustration this time. Please try again.",
    });
  }
});

// Centralized fallback error handler for anything unexpected (e.g. a
// malformed JSON body) that escapes the route handler above.
app.use((err, req, res, next) => {
  console.error('[server] unhandled error:', err);
  if (res.headersSent) return next(err);
  res.status(500).json({ error: 'Something went wrong. Please try again.' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Illustrated Life Journal server listening on port ${PORT}`);
  });
}

module.exports = app;
