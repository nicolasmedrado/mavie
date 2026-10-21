---
title: TMDb key ships in the client — accepted risk
status: accepted
date: 2026-10-21
---

# 0012 — TMDb key ships in the client — accepted risk

## Context

The TMDb API key is kept out of git in a `.env` file, loaded at startup with `flutter_dotenv`. But `.env` is registered as a Flutter **asset**, so it ships inside the app bundle: `unzip` plus `strings` on the APK recovers the key. The git-ignore protects the repository, not the artifact.

An earlier approach used a git-ignored Dart constants file (`lib/data/tmdb_api_key.dart`), which had exactly the same property and was replaced by `.env`.

## Decision

Accept it for the MVP. Keep the key in `.env`, keep `.env` out of git, and document the exposure rather than pretending it is secret.

## Alternatives considered

- **Route TMDb through a Supabase Edge Function** with a server-held key. The real fix, and wanted anyway for server-side `movies_cache` writes. Deferred because it adds a deployment surface before the core product loop exists.
- **Obfuscate the key in the binary.** Security theatre — raises the effort from seconds to minutes.
- **Ship no key and require each user to supply one.** Honest and terrible for a two-person app.

## Consequences

- The key is a **read-only** TMDb v3 key. The worst outcome is rate-limit abuse of one TMDb account — not data loss, not access to user data.
- Supabase keys are different: the anon key is designed to be public, and the data is protected by [[architecture/security-model|RLS]], not by key secrecy. The **service role key must never be in the app** — it bypasses RLS entirely.
- The Edge Function migration is recorded in [[product/post-mvp]] as accepted debt with a repayment path, not forgotten.
- `.env.example` stays committed so a fresh clone knows what to create. See [[operations/local-setup]].
