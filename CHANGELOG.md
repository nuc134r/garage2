# Changelog

Each section becomes the notes of the GitHub release with that version
(`tool/changelog.sh <version>`; see docs/RELEASING.md). Newest first.

## 2.3.3

- Reminder progress bars are back to showing how much of each reminder's own interval is left
  (whichever of distance or time runs out first), as in 2.3.1.
- The reminder details header shows only the time until due ("in ~6 weeks"), like the home list;
  the status section below still shows distance and date.

## 2.3.2

- Reminder progress bars use one shared time scale (6 months = full bar), so a reminder due sooner
  always has the shorter bar. *(Reverted in 2.3.3.)*

## 2.3.1

- Home screen reminders show only the time until due: the sooner of the date interval and the
  distance interval estimated from your average daily mileage ("in ~6 weeks" when estimated).
- Reminders are sorted by that time, soonest first.
- Progress bars shrink as time runs out (empty bar on a red track = overdue).
- Releases can be published from the Actions tab without pushing a tag.

## 2.3.0

- **In-app updates (Android):** a card on the home screen offers new releases from GitHub with the
  release notes; *Update* downloads the APK for your phone and opens the installer.
  Settings → About has an auto-check switch and *Check for updates*.
- **Electric vehicles:** kWh as fuel unit with kWh/100 km, km/kWh or mi/kWh efficiency;
  charging entries say *Energy* and *Charged to full*.
- **Car avatars redrawn:** smooth, modern shapes with distinct proportions per body type.
- **16 car colours,** most common first (white, black, gray, silver, blue, red, …).
- **Web:** shows the real app version, a refresh loads a new deploy instead of a cached one,
  and a *Reload* card appears when a newer version is deployed.

## 2.2.0

- **Statistics in tabs** (fuel, expenses, mileage, service) with charts: costs by month,
  efficiency, fuel price and odometer trends; a custom date range besides the presets.
- **Vehicle avatars:** pick a body type (sedan, hatchback, wagon, coupe, SUV, pickup, van) and get
  a small car drawing in the vehicle's colour.
- **Reminders:** optional "last done" date and odometer when creating one.
- **Backups:** deletions now carry over when merging a backup into another device.
- **Fixed:** page transitions and Hero animations were missing; Android predictive back gesture.

## 2.0.0

- **File attachments** for entries: bill photos and PDFs, viewable in a zoomable gallery;
  included in full backups.
- **Configurable home screen tiles:** choose the stats and periods shown on the home screen.
- **Animations** between lists and details (entries, reminders, stat tiles).
- The app is called *garage* (lowercase) everywhere; source code link in Settings → About.

## 1.0.3

First release of the rebuilt app (Android and web):

- Multiple vehicles with a vehicle switcher; fuel, service, expense and odometer entries.
- Home screen with stat tiles, reminders and the entry history with gaps between entries.
- Maintenance reminders by distance and/or time, with notifications.
- Statistics, lists of fuel types, stations and expense categories.
- Quick and full backups as a `.garage` file that moves between Android and web; restore points.
- English and Russian, light and dark theme.
