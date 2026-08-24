import '../models/story.dart';

/// Placeholder stories so the Stories screen has something to show before
/// Phase 3 introduces real journal-entry-backed stories.
const List<Story> mockStories = [
  Story(
    id: 'story_japan_trip',
    title: 'Japan Trip',
    description: 'Two weeks across Tokyo, Kyoto, and Osaka.',
    coverColorSeed: 0,
    entryCount: 4,
  ),
  Story(
    id: 'story_summer_2026',
    title: 'Summer 2026',
    description: 'Long days, warm evenings.',
    coverColorSeed: 1,
    entryCount: 2,
  ),
  Story(
    id: 'story_first_week_uni',
    title: 'First Week at University',
    description: 'New city, new people, new routines.',
    coverColorSeed: 2,
    entryCount: 3,
  ),
];
