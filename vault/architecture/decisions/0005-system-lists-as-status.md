---
title: System lists are a status column, not rows in `lists`
status: accepted
date: 2026-10-21
---

# 0005 — System lists are a status column, not rows in `lists`

## Context

Every user has two built-in lists, *Want to watch* and *Watched*, plus any number of custom playlist-like lists. The uniform option is one `lists` table where the built-in two are rows flagged `is_system`.

## Decision

The two system lists are **`user_movies.status`**, a nullable enum, not rows in `lists`. Custom lists are a separate `lists` / `list_members` / `list_items` structure.

## Alternatives considered

- **One `lists` table with an `is_system` flag.** Uniform schema and one UI path. But nothing would stop a film being in both *Want to watch* and *Watched* at once — the app would have to keep them mutually exclusive by hand, and any bug leaves a film in two places. Ratings would also need a home, and `list_items.rating` is [[architecture/decisions/0004-global-ratings|the wrong place]].
- **A third enum value `'favorite'`.** Explicitly rejected and worth recording: favourite is orthogonal to watched. If it is ever wanted it is a boolean column.

## Consequences

- Exclusivity is structural. `primary key (user_id, tmdb_id)` makes "in both lists" unrepresentable rather than merely forbidden.
- The rating lives on the same row as the status, which is where it belongs.
- System list names are client-side ARB strings keyed off the enum, so they localize per user. Custom list names are user-typed and stay verbatim.
- **The cost:** system and custom lists have different shapes, so the UI could grow two parallel list screens. Paid once in the domain layer:

```dart
sealed class CollectionRef {}
class SystemCollection extends CollectionRef { final MovieStatus status; }
class CustomCollection extends CollectionRef { final String listId; }

abstract class CollectionRepository {
  Future<List<CollectionItem>> items(CollectionRef ref);
  Future<void> add(CollectionRef ref, MovieSummary movie);
  Future<void> remove(CollectionRef ref, int tmdbId);
}
```

One collection page, one item tile, two repository branches. This is the main Flutter-side consequence of the decision and should be built in LIB-01, before either list UI.

- `status` is nullable so that removing a film from *Watched* can keep its rating — `null` means "not in a system list, but watched and judged". See [[architecture/data-model]].
