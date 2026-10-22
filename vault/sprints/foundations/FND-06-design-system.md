---
title: Design system
sprint: foundations
feature: —
milestone: mvp
status: in_progress
started_at: 2026-10-21
finished_at:
---

# FND-06 · Design system

## Goal

Colour, typography and spacing come from tokens. No hardcoded `Colors.amber`, no literal `SizedBox(height: 16)`, no `BorderRadius.circular(8)` invented per widget.

## Scope

Files: `lib/core/theme/{app_theme.dart, app_colors.dart, app_typography.dart, app_spacing.dart}`

Today the entire theme is one line:

```dart
theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple))
```

No `darkTheme`, no `themeMode`, no text theme, no custom font. Styling is improvised per widget.

### Target

- `AppTheme.light` and `AppTheme.dark`, both real. A film app is used at night — dark mode is not a polish item, and building it later means re-auditing every screen.
- A seed-based `ColorScheme` is fine as a base, but the **rating colour** needs to be a named semantic token rather than `Colors.amber` at the call site, since it appears on the details screen, in list rows, in member chips and in carousels.
- `AppSpacing` — a 4 pt scale (`xs 4`, `sm 8`, `md 16`, `lg 24`, `xl 32`). Replaces every literal `SizedBox`.
- `AppTypography` — map onto `TextTheme` so `Theme.of(context).textTheme.*` keeps working; do not invent a parallel API.
- Corner radii and elevation as tokens too — posters, cards and covers must agree.

Keep it small. The point is that every value has one home, not that the app needs forty tokens.

## Checklist

- [x] `AppColors`, `AppTypography`, `AppSpacing`, radius and elevation tokens
- [x] `AppTheme.light` and `AppTheme.dark`
- [x] `app.dart` wires `theme`, `darkTheme`, `themeMode: ThemeMode.system`
- [x] Migrate the two existing pages off their hardcoded values
- [x] A named token for the rating colour

## Test scenario

1. Run the app, switch the OS between light and dark
   - **Expected:** both themes legible, no invisible text, no white-on-white poster placeholder
   - **Manual check — left to the user to run; not performed by Claude.** Roteiro: `flutter run` no device/emulador, trocar o tema do SO (claro/escuro) com o app aberto, confirmar que texto e poster placeholder continuam legíveis nos dois temas
2. `grep -rnE "Colors\.|SizedBox\((width|height): [0-9]" lib/`
   - **Expected:** no hits outside `core/theme/`
   - **Result:** the only hits outside `core/theme/` are `AppColors.rating` / `AppColors.posterPlaceholder` — the token name itself contains the substring `Colors.`, not a hardcoded value. No literal `Colors.*` or numeric `SizedBox` left in the two pages

## Dependencies

- **Blocked by:** FND-02
- **Blocks:** FND-07 (the widgets consume these tokens), FND-10 (shell chrome), every screen after

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | Tokens added (`core/theme/`), `AppTheme.light`/`dark` wired in `app.dart`, both pages migrated. `flutter analyze` clean, 35 tests green. Pending your manual light/dark check |
