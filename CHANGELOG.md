# Changelog

Each section becomes the notes of the GitHub release with that version
(`tool/changelog.sh <version>`; see docs/RELEASING.md). Newest first; rename *Unreleased* to the
version when releasing.

## 3.0.3

- Smoother splash: the app's first screen is now built after the word is written, while the logo holds
  still, instead of during the writing (its data still loads meanwhile), and each frame of the writing
  takes less work to draw.

## 3.0.2

- Vehicle menu: runs to the right edge of the screen, so longer reminder notes fit on one line; vehicles
  keep their usual order instead of the current one jumping to the top; the whole *Manage garage* row
  is tappable; long garages scroll inside the menu.

## 3.0.1

- Statistics → Costs: the monthly average (in the summary and the *Outlook*) and the projected year
  are left out for periods shorter than two months, where they would only repeat the period's total.
- Reminders past their distance say how far over they are ("overdue by 300 km") instead of a guess at
  how long ago that was.

## 3.0.0

- Phone vehicle selector: instead of a bottom sheet, a menu unfolds over the switcher with the current
  vehicle first, while the page behind blurs and dims. Each vehicle shows its odometer and how many
  reminders are overdue or due soon, with a larger car drawing.
- Settings: the *Data* section comes first, and every item that opens another page shows a chevron.
- Garage: the quick backup button is gone from the app bar (backups live in *Settings → Backup & restore*).

## 2.12.0

- Welcome screen: *Try with demo data* fills the garage with two sample vehicles and a year of history,
  to look around before entering your own. (Replaces the debug-only *Load sample data* in Settings.)

## 2.11.3

- Splash screen: the word is written in one go, without pauses between strokes.

## 2.11.2

- After the splash the app fades in with a short slide from the right, as pages open, instead of
  appearing at once. The app is no longer rebuilt from scratch when the splash goes away.

## 2.11.1

- Splash screen: about twice as fast (1.1 s in total), with a much quicker fade into the app, and no
  more jump above the *r* as the word finishes.

## 2.11.0

- Splash screen: the app opens on the icon's colour and writes out "garage" by hand, in the logo's own
  letters, while it loads. Tap to skip; off when the system asks for reduced animations.

## 2.10.7

- Settings: the *About* section is reversed — Licenses, Source code, Feedback, then App version.
- Documented the `.garage` backup format with a JSON Schema and an example (docs/backup), for
  converting data from other apps.

## 2.10.6

- Reminder details: swipe across the card to switch between *History* and *Intervals*; the content slides
  in from the side it comes from.

## 2.10.5

- Home screen entries no longer fade in after filtering (they also faded in while scrolling).

## 2.10.4

- Settings and the garage opened by a link (e.g. `#/settings` on the web) have a back arrow to the home
  screen; before, there was no way back.

## 2.10.3

- The last active vehicle can't be archived (the garage explains why).
- The paperclip on an entry's icon no longer flickers while the icon flies to the entry.
- Filtering the home screen entries fades the list in, one entry after another.
- Reminder details: *History* and *Intervals* are tabs.

## 2.10.2

- Odometer suggestions above the keyboard: each one reacts across its whole half of the strip; picking
  one checks only the odometer (the rest of the form no longer turns red) and moves on to the next field.
- The keyboard's *Next* key moves through odometer, volume, price and total.

## 2.10.1

- **New car drawings** for vehicle avatars: modern proportions taken from real cars of each type
  (lower and longer, realistic wheel size), a high beltline with chrome window trim, black pillars,
  slim LED lamps and two-tone alloys; crossovers and pickups get unpainted plastic around the arches.

## 2.10.0

- Entries with attachments show a small paperclip on the corner of their icon (list and details).
- Odometer: while typing it, the last reading and an estimate for the entry's date (from your average
  daily distance) sit on top of the keyboard like keyboard suggestions — one tap fills the field. On
  desktop they appear under the field. Validation messages wrap instead of being cut off.

## 2.9.2

- Home screen tiles: up to four in a row on wide screens (web, tablets), two on phones.
- Entries with attachments show the paperclip after the title, so they stay one line.
- Opening an entry, its total flies to the details along with the icon and title.
- A home tile opens its statistics tab without flying the tile over.
- Empty screens (e.g. an empty garage) show their message in the middle.

## 2.9.1

- Statistics show money without cents (except small amounts such as cost per km) and shorten large
  numbers: ₽469K, 1.51K $, 17.4K km.

## 2.9.0

- **Statistics redesigned.** A summary on top: cost of ownership with the change against the
  previous period, cost per km, distance and efficiency with their trends, and short findings
  (biggest cost, upcoming service and its usual price, record efficiency, cheaper station).
  Below it four tabs:
  - **Costs:** costs by month with the average, where the money goes (fuel, service and each
    category), cost per km by month, spending against the previous period, and an outlook (this
    year at the current pace, upcoming services).
  - **Driving:** distance by month (busiest highlighted), the average day of the week, the odometer
    with when it reaches the next round number, and daily to yearly averages.
  - **Fuel / Charging:** efficiency of every fill with its trend, efficiency by month, the price
    paid per month (average and range), stations and fuel types compared, and record fills.
  - **Service:** what's next with the usual cost, a timeline of services by reminder, service cost
    by year and the history.
- New periods: last 6 months and calendar years; statistics open on the last 12 months.
- **Compare vehicles** (button in the statistics bar): running cost, monthly and total cost,
  distance and efficiency of all vehicles side by side.

## 2.8.1

- The vehicle selector (and the side panel on wide screens) no longer has *Add vehicle*; add vehicles
  in *Manage garage*.

## 2.8.0

- **Notifications by vehicle** (Settings → Notifications → By vehicle): turn a vehicle's reminders
  off or notify about it earlier or later than the others. Carried over in full backups.
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
