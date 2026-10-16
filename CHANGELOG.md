# Changelog

Each section becomes the notes of the GitHub release with that version
(`tool/changelog.sh <version>`; see docs/RELEASING.md). Newest first; rename *Unreleased* to the
version when releasing.

## Unreleased

- **Fixed:** cancelling an update download closed the app (or the screen behind the progress
  dialog) and showed an "Update failed" message.

## 2.7.1

- Larger "garage" logo on the app icon, and a larger notification icon.
- The project is now MIT-licensed.

## 2.7.0

- **Spanish, German and French** translations (Settings → Language).
- **Electric vehicles** speak of charging: entries, filters, home tiles and statistics say *Charging*,
  *Energy* and *Charging station* with a charger icon, and the entry form skips the fuel type.
- Sample data: a Honda Civic, a Volkswagen Tiguan and an electric Tesla Model 3, in US dollars.
- Wide screens (web, tablets): every screen besides home is a centred column of readable width
  instead of stretching across the whole window.

## 2.6.0

- **App version** screen (Settings → About → App version): big app icon, version, the update check
  (*Check for updates* / *Update to …*) with the automatic check switch, and this changelog.
- About: App version, Feedback, Source code and Licenses.

## 2.5.3

- Home entry list: refuels no longer show the fuel efficiency (it stays on the refuel's details
  and in statistics).

## 2.5.2

- Filled icons throughout.
- Home entry list: the odometer reading is gone from entries (kept for odometer readings).
- The app version is shown without build number and commit (e.g. *2.5.2*).
- Settings are less cluttered (no explanations under predictive back, maintenance reminders,
  the Data items and the update check) and have a **Feedback** item that writes to garage@nuc134r.io.
- New entry form: the entry type is picked from four tiles (icon above its name) that always fit,
  instead of a segmented button whose label wrapped.

## 2.5.1

- New setting (Android, Settings → Appearance): **predictive back gesture**, off by default — while
  swiping back the page shrinks and shows the previous one.
- Reminder details: more space between the bar and its arrow.
- **Fixed:** PDFs and other documents open in a viewer app on Android (2.5.0 still offered to share them).

## 2.5.0

- Reminder details: the distance and time left sit under their bars in smaller text, with a small
  arrow pointing at where the bar ends; near the edges the text stays inside.
- Entry details: a long station name no longer squeezes its label; it wraps on its own side.
- Refuels show the distance and time since the previous refuel (the lists still show the gaps
  between all entries); other entry types no longer show "since previous".
- Attachments have even padding and are the last block, after the note (details and editor).
- PDFs and other documents open in a viewer (on Android the default viewer app, e.g. Google Drive's;
  on the web a new tab) instead of the share sheet.

## 2.4.1

- The distance and time between entries are centred between them (home list and reminder history).

## 2.4.0

- Reminder details: the mileage estimate sits in parentheses after the distance
  ("in 2,100 km (~6 weeks)"); the separate estimate and "last done" rows are gone.
- Reminder history shows the distance and time between consecutive services.
- The History title switches to **Intervals**: a column per gap between services (by mileage and/or
  time) with the required interval as a dashed line; gaps longer than required are red.
- The distance and time between entries line up with the entry titles (home list and reminder history).

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
