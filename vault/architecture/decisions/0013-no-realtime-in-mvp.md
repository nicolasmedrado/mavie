---
title: No Realtime in the MVP
status: accepted
date: 2026-10-21
---

# 0013 — No Realtime in the MVP

## Context

Supabase Realtime can push row changes to subscribed clients, which sounds like exactly what a shared list wants: your partner rates a film, your screen updates.

**Realtime respects table RLS.** `user_movies` RLS is `user_id = auth.uid()` and nothing else — [[architecture/decisions/0007-cross-member-reads-via-rpc]] — so a subscription will simply never deliver another user's rating. Ratings are read through a definer RPC, and an RPC is not a subscribable stream.

## Decision

No Realtime in the MVP. List and library screens refresh on focus, plus pull-to-refresh.

## Alternatives considered

- **Loosen `user_movies` RLS so Realtime can deliver.** Would reintroduce exactly the cross-user policy that 0007 rejects. Trading the security model for a UI nicety.
- **Subscribe to `list_items` only.** Possible — items *are* covered by `is_list_member`. But it delivers "a film was added", not "a score was given", which is the interesting event. Half a feature.
- **Poll on a timer.** Battery and quota cost for two users who are usually in the same room.

## Consequences

- When one person rates something, the other sees it on next focus or pull-to-refresh. For two users who talk to each other, indistinguishable from live.
- Providers must invalidate on resume — an `AppLifecycleListener` invalidating the relevant providers, not a manual refresh button.
- **If live updates are ever wanted**, the correct mechanism is a `list_activity` table written by an `after update` trigger on `user_movies`, one row per shared list containing that film, with `select using (is_list_member(list_id))`. It is subscribable, leaks nothing the list screen does not already show, and doubles as an activity feed. Recorded in [[product/post-mvp]].
- The `supabase_flutter` dependency includes Realtime regardless; this is a decision not to use it, not to exclude it.
