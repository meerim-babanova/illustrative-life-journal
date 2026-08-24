'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

// Force the mock provider so this test never needs a real API key or
// network access to an external AI provider.
process.env.IMAGE_PROVIDER = 'mock';
// Fixed (not OS-assigned) port: mockProvider.js builds its returned
// imageUrl from process.env.PORT directly, so the test server must listen
// on that same literal port or the two would disagree.
const TEST_PORT = 8799;
process.env.PORT = String(TEST_PORT);

const app = require('../index');

function withServer(fn) {
  return new Promise((resolve, reject) => {
    const server = app.listen(TEST_PORT, async () => {
      const baseUrl = `http://localhost:${TEST_PORT}`;
      try {
        await fn(baseUrl);
        resolve();
      } catch (err) {
        reject(err);
      } finally {
        server.close();
      }
    });
  });
}

test('GET / returns a health check', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'ok');
  });
});

test('POST /generate-illustration rejects missing journalText', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/generate-illustration`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    });
    assert.equal(res.status, 400);
    const body = await res.json();
    assert.match(body.error, /journalText is required/);
  });
});

test('POST /generate-illustration rejects overly long journalText', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/generate-illustration`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ journalText: 'a'.repeat(5000) }),
    });
    assert.equal(res.status, 400);
  });
});

test('POST /generate-illustration succeeds with the mock provider and '
  + 'never leaks server internals to the client', async () => {
  await withServer(async (baseUrl) => {
    const res = await fetch(`${baseUrl}/generate-illustration`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        journalText: 'Today I went to the park with my sister.',
        character: { faceShape: 'round', hairStyle: 'bob' },
        style: 'illustrated-life-journal-v1',
      }),
    });
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.ok(body.imageUrl.startsWith(baseUrl));
    assert.ok(!('error' in body));
  });
});
