# Garage

Vehicle fuel, service and expense tracker for Android and web. Multiple vehicles, reminders,
statistics, English and Russian.

## Run

```bash
fvm flutter run                 # Android device/emulator
fvm flutter run -d chrome       # web
fvm flutter test
fvm flutter build apk
fvm flutter build web
```

Debug builds (or `--dart-define=GARAGE_DEMO=true`) show **Settings → Load sample data**.

## Releases

Web deploys to GitHub Pages on every push to `main`; pushing a `v*` tag builds signed APKs
and publishes a GitHub release. Setup and signing: [docs/RELEASING.md](docs/RELEASING.md).

## Code generation

Drift tables generate `lib/core/db/database.g.dart`; ARB files generate `lib/l10n/gen/`.

```bash
fvm dart run build_runner build
fvm flutter gen-l10n
```

## Web database assets

The web build runs SQLite as WASM in a worker. Both files in `web/` must match the resolved
`sqlite3` package version (see `pubspec.lock`). After upgrading drift or sqlite3:

```bash
fvm dart compile js -O4 tool/drift_worker.dart -o web/drift_worker.js
curl -L -o web/sqlite3.wasm https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<version>/sqlite3.wasm
```

## Backups

A backup is a single `.garage` file (plain JSON, identical on Android and web):

- **Quick backup**: all vehicles, entries, reminders and lists.
- **Full backup**: the same plus app settings.
- **Import**: *Merge* upserts by id, keeping the newest version of each row (importing the same
  file twice changes nothing); *Replace all* wipes local data first.
- **Restore points**: snapshots kept inside the database (daily and before imports/deletions,
  last 10), so they work on web too.
