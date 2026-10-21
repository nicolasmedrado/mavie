---
title: Design system
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
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

- [ ] `AppColors`, `AppTypography`, `AppSpacing`, radius and elevation tokens
- [ ] `AppTheme.light` and `AppTheme.dark`
- [ ] `app.dart` wires `theme`, `darkTheme`, `themeMode: ThemeMode.system`
- [ ] Migrate the two existing pages off their hardcoded values
- [ ] A named token for the rating colour

## Test scenario

1. Run the app, switch the OS between light and dark
   - **Expected:** both themes legible, no invisible text, no white-on-white poster placeholder
2. `grep -rnE "Colors\.|SizedBox\((width|height): [0-9]" lib/`
   - **Expected:** no hits outside `core/theme/`

## Dependencies

- **Blocked by:** FND-02
- **Blocks:** FND-07 (the widgets consume these tokens), FND-10 (shell chrome), every screen after

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
