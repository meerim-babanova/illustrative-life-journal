# Phase 2 — implementation notes

Design: `Phase 2 Screens.dc.html` (open in a browser). Flutter code below
drops into the existing project; **no Phase 1 screen was removed** and the
theme files (`app_colors`, `app_typography`, `app_theme`) are untouched.

## What changed, and why

### Illustrations now actually generate
Phase 1 shipped `MockJournalGenerationService`: a 2-second delay that
returned an integer seed, and a Journal Page that read
"Illustration coming in a later phase". Nothing could ever appear.

Phase 2 adds a real, two-stage pipeline behind the same seam:

1. `SceneInterpreter` reads the user's own words and produces a structured
   `IllustrationScene` — time of day, weather, place, mood, whether they
   were alone, plus a palette.
2. `LocalSceneIllustrationProvider` returns that scene, and `SceneArt`
   paints it: sky gradient, light and haze, hills / skyline / trees / water,
   rain or snow, companion silhouettes, paper vignette.
3. `SceneIllustration` composites the user's saved `CharacterConfig` on
   top via the existing `CharacterPreview`, so **the same character appears
   on every page** with no asset pipeline.

This runs offline, needs no API key, and is deterministic per seed — which
is what makes "Regenerate" and "restore an earlier take" meaningful. When a
hosted image model is added, implement `IllustrationProvider` and change one
constructor; no screen or model changes.

### The overflow stripes are fixed
Two real layout bugs from Phase 1:

* `StoriesScreen` used `SliverGridDelegateWithMaxCrossAxisExtent` with
  `childAspectRatio: 0.82`, plus a `StoryCard` containing a 16:10
  `AspectRatio` cover **and** unbounded text. At many widths the tile was
  shorter than its content → RenderFlex overflow.
* `HomeScreen` put a two-line title + two-line body inside
  `SizedBox(height: 90)`.

Both now use a fixed `mainAxisExtent` with a fixed-height cover and
`maxLines`/`ellipsis` text, so tiles can't be shorter than their content at
any width. Column counts come from `Breakpoints`.

### Screens
| Screen | File |
| --- | --- |
| Write Memory | `journal/presentation/screens/journal_entry_screen.dart` |
| Generating + Failure | `journal/presentation/screens/generation_screen.dart` |
| Journal page | `journal/presentation/screens/journal_page_screen.dart` |
| Regenerate sheet | `journal/presentation/widgets/regenerate_sheet.dart` |
| Home | `home/presentation/screens/home_screen.dart` |
| Stories | `stories/presentation/screens/stories_screen.dart` |

Generation shows an indeterminate `DriftingLine` and two crossfading lines
of copy — never a percentage. Failure says "Your illustration got a little
lost along the way", shows the kept draft, and offers Try again / Save the
writing for now; no exception text ever reaches the UI (`JournalProvider`
swallows it into a boolean).

Responsive: `core/layout/breakpoints.dart` — narrow < 700 < tablet < 1000 <
laptop < 1320 < desktop. Write and Journal switch to two columns at laptop;
grids go 1 / 2 / 3 / 4 columns.

## API changes to be aware of
* `JournalPage` now carries `id`, `scene`, `previousTakes` instead of
  `illustrationSeed`.
* `JournalProvider.isGenerating` → `isWorking`; `error` → `hasFailed`;
  new `retry()`, `regenerate()`, `restoreTake()`, `keepPage()`.
* `MockJournalGenerationService` → `SceneJournalGenerationService`. If a
  test or `app.dart` referenced the mock by name, update that reference.

## Run
```bash
flutter pub get
flutter analyze
flutter run
```
