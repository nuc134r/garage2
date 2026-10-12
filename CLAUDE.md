# Garage (garage2)

Flutter app (Android + web) for tracking vehicle fuel, service, expenses and reminders.
Flutter is pinned with FVM (`.fvmrc`, 3.47.7) — always run `fvm flutter …` / `fvm dart …`.

## Stack
- **Drift** (SQLite; WASM worker on web) — schema in `lib/core/db/tables.dart`
- **Riverpod 3** with hand-written providers (no riverpod_generator: it can't see Drift's generated row types)
- **go_router** — all paths in `Routes` (`lib/app/router.dart`); vehicle id is in the URL (`/v/:vid/...`)
- **gen-l10n** — `lib/l10n/app_en.arb` (template) and `app_ru.arb`; use `context.l10n`

## Layout
- `lib/core/` — db, enums/unit conversion, `VehicleFormat` (locale + vehicle units/currency), shared widgets
- `lib/features/<feature>/{data,domain,presentation}` — vehicles, entries, reminders, stats, dictionaries, backup, settings, home
- Domain logic is plain Dart and unit-tested: `stats_calculator.dart`, `reminder_status.dart`, `notification_plan.dart`, `backup_data.dart`
- Notifications: `ReminderNotifications` (platform service, overridden in `main()`; no-op in tests) +
  `notificationSyncProvider` (watched by the app root) which reschedules on any reminder/settings change.
  Android schedules ahead; web can only show a summary on open.

## Conventions
- Money is stored as integer minor units; fuel volume/odometer in the vehicle's own units.
- Every synced row has a UUID `id`, `createdAt`, `updatedAt` (set `updatedAt` on every write) — backup merge depends on it.
- No hardcoded UI strings: add keys to both ARB files, then `fvm flutter gen-l10n`.
- After changing tables: `fvm dart run build_runner build`, bump `schemaVersion` and add a migration.
- `test/app_smoke_test.dart` renders every route with sample data at phone and desktop widths — add new routes there.

## Icons
Never edit generated icon files (`android/.../res/{drawable,mipmap-*}/ic_*`, `web/icons`, `web/favicon.png`,
`assets/app_icon.png`); change `icons/*.svg` and run `python tool/generate_icons.py`.

## Commands
```bash
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build
fvm flutter gen-l10n
```
