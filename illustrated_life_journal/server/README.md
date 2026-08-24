# Illustrated Life Journal — Server

A minimal Express backend whose only job is to hold the AI image-generation
provider's API key server-side and expose `POST /generate-illustration` for
the Flutter client. The key is never sent to, stored in, or readable by the
Flutter Web app (see `AppConfig` on the client — it only ever holds this
server's URL, never a provider key).

## Local setup

```bash
cd server
npm install
cp .env.example .env
# edit .env and set OPENAI_API_KEY=sk-...
npm start
```

The server listens on `http://localhost:8787` by default. Health check:
`curl http://localhost:8787/`.

### Testing without an API key

Set `IMAGE_PROVIDER=mock` (in `.env` or inline) to use a static placeholder
illustration instead of calling OpenAI. This lets you exercise the full
Flutter write → generate → view flow without any credential:

```bash
IMAGE_PROVIDER=mock npm start
```

## Running the tests

```bash
npm test
```

Uses Node's built-in test runner (`node --test`) — no extra test
dependencies. Covers prompt construction (pure functions, no network) and a
full HTTP integration test of `/generate-illustration` against a real
listening server using the mock provider.

## API

### `POST /generate-illustration`

Request body:

```json
{
  "journalText": "Today I went to the park with my sister...",
  "character": {
    "faceShape": "round",
    "eyeShape": "round",
    "eyeColor": "brown",
    "hairStyle": "bob",
    "hairColor": "chestnut",
    "skinTone": "medium",
    "bodyType": "average",
    "outfitTop": "cream_sweater",
    "accessories": []
  },
  "style": "illustrated-life-journal-v1"
}
```

Success (200):

```json
{ "imageUrl": "https://..." }
```

Failure (400 for bad input, 502 for a provider/generation failure):

```json
{ "error": "We couldn't create the illustration this time. Please try again." }
```

The client never sees provider-specific error detail — that's logged
server-side only (`console.error`), never the full journal text.

## Environment variables

| Variable | Required | Default | Notes |
|---|---|---|---|
| `OPENAI_API_KEY` | Yes, if `IMAGE_PROVIDER=openai` | — | Get one at https://platform.openai.com/api-keys. **Never commit this or ship it to the client.** |
| `IMAGE_PROVIDER` | No | `openai` | `openai` or `mock` |
| `PORT` | No | `8787` | |
| `ALLOWED_ORIGIN` | No | `*` | Set to your deployed Flutter web app's real origin in production — `*` is dev-only. |
| `PUBLIC_BASE_URL` | No | `http://localhost:$PORT` | Only used by the mock provider to build an absolute URL to the static placeholder asset. |

## Deploying

This is a stock Express app (`server.listen`, exported `app` for testing) —
it runs anywhere Node 18+ runs. A few common options:

- **Render / Railway / Fly.io**: point them at the `server/` directory,
  build command `npm install`, start command `npm start`, set
  `OPENAI_API_KEY` and `ALLOWED_ORIGIN` in their dashboard's environment
  variables (never in a committed file).
- **A VPS**: `npm install --omit=dev && npm start` behind a reverse proxy
  (nginx/Caddy) that terminates TLS.
- **Serverless (e.g. a single Vercel/Cloudflare function)**: the route
  logic in `lib/promptBuilder.js` and `lib/imageProviders/` has no
  Express-specific dependencies, so it can be lifted into a single
  request-handler function if you'd rather not run a persistent server.

Whichever you choose, set `OPENAI_API_KEY` as a **platform-level secret**,
never in a file that gets committed or bundled into the Flutter client.

Once deployed, point the Flutter app at it:

```bash
flutter run -d chrome --dart-define=BACKEND_BASE_URL=https://your-backend.example.com
```

## Architecture

```
index.js                        Express app: routing, validation, CORS
lib/promptBuilder.js            Builds the structured illustration prompt
                                 (pure function, no I/O — unit tested)
lib/imageProviders/index.js     Picks a provider by IMAGE_PROVIDER env var
lib/imageProviders/openaiProvider.js  Real provider (calls OpenAI Images API)
lib/imageProviders/mockProvider.js    Local-dev provider (no external calls)
public/mock/                    Static placeholder asset for the mock provider
```

Adding a new provider (e.g. a different image API) means adding one file
under `lib/imageProviders/` and one `case` in `index.js` there — nothing
else in the request-handling code changes.
