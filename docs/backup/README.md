# The `.garage` backup format

garage saves backups as one **UTF-8 JSON file** with the `.garage` extension. The same file restores
on Android and on the web, and it is also the way to **bring data in from another app**: convert
that app's export to this format, then open it in garage under *Settings → Backup & restore → Restore from file*.

- [`garage-backup.schema.json`](garage-backup.schema.json) is the JSON Schema (draft 2020-12).
  Validate a converted file against it before importing.
- [`example.garage`](example.garage) is a small complete file: one car with refuels (one of them a
  partial fill), a service that resets a reminder, an expense and an odometer reading.
  `test/backup_format_doc_test.dart` imports it, so it stays valid.

This page describes format version (`schema`) **1**.

## File layout

```jsonc
{
  "format": "garage-backup",        // required, exactly this
  "schema": 1,                      // required; files with a newer version are refused
  "mode": "quick",                  // "quick" (data) or "full" (data + settings + attachments)
  "app": "2.10.6+52",               // who wrote the file; informational, may be null
  "exportedAt": "2026-10-20T12:00:00.000Z",
  "vehicles": [],                   // the lists below may be empty or missing
  "entries": [],
  "reminders": [],
  "reminderResets": [],
  "fuelTypes": [],
  "places": [],
  "expenseCategories": [],
  "deleted": [],                    // deletion records for merging; leave empty
  "settings": {},                   // full backups only; leave out
  "attachments": []                 // optional; receipts and other files
}
```

The app writes files named `garage-YYYYMMDD-HHMM.garage`, but any name works.

## Common rules

- **Every field listed for a row must be present**, even if it is `null` or `""`. Unknown fields
  are an error in the schema; the app ignores them.
- **ids** are UUIDs (generate v4) and must be unique across the file. Keep them stable: importing a
  row whose id already exists updates it instead of adding a copy, so re-running a migration with
  the same ids does not duplicate anything. A deterministic UUID (v5 from the source app's id) is
  a good way to get stable ids.
- **Every row except `reminderResets` and `deleted` has `id`, `createdAt` and `updatedAt`.** Use the
  source app's timestamps if it has them, otherwise the migration time. On a merge import the copy
  with the later `updatedAt` wins.
- **Dates and times** are ISO 8601 strings. Without `Z` or an offset they are the device's local time;
  this is how the app writes the dates the user sees (`"2026-01-10T18:30:00.000"`). A date-only
  value (`"2026-01-10"`) is midnight local time. With `Z` they are UTC.
- **Money is an integer in minor units** of the vehicle's currency: 12.34 EUR → `1234`,
  1500 JPY → `1500` (yen has no minor unit). Round, never write fractions.
- **Distance, fuel and odometer use the vehicle's own units** (`distanceUnit`, `volumeUnit`). Do not
  convert values from the source app; set the vehicle's units to match them instead.
- **Enums are written by name** exactly as listed below (case-sensitive).

## Rows

### `vehicles`

| Field | Type | Notes |
|---|---|---|
| `name` | string, 1–100 chars | |
| `color` | integer | ARGB as unsigned 32-bit, e.g. `0xFF2196F3` → `4280391411`. Default slate grey `4284513675`. |
| `bodyType` | enum or `null` | `sedan`, `hatchback`, `wagon`, `coupe`, `suv`, `pickup`, `van`. Picks the car drawing; `null` shows the first letter of the name. |
| `purchaseDate` | date or `null` | |
| `initialOdometer` | integer | Odometer when tracking started (usually the first entry's reading or less). `0` if unknown. |
| `distanceUnit` | enum | `km`, `mi` |
| `volumeUnit` | enum | `liter`, `galUs`, `galUk`, `kwh` (`kwh` = electric vehicle) |
| `efficiencyUnit` | enum | Fuel: `litersPer100Km`, `kmPerLiter`, `mpgUs`, `mpgUk`. Electric (`kwh`): `kwhPer100Km`, `kmPerKwh`, `miPerKwh`. Only changes how efficiency is shown. |
| `currencyCode` | string | ISO 4217, e.g. `EUR`. All of the vehicle's costs are in it. |
| `archived` | boolean | Archived vehicles are hidden from the selector. Keep at least one vehicle not archived. |
| `sortOrder` | integer | Order in the vehicle list, ascending from `0`. |

### `entries`

One list for everything that happens to a vehicle; `type` says what it is.

| Field | Type | Notes |
|---|---|---|
| `vehicleId` | id | The vehicle. Entries of a vehicle missing from the file and the device are skipped. |
| `type` | enum | `fuel` (refuel or charge), `service`, `expense`, `odometer` (a reading only) |
| `date` | date-time | |
| `odometer` | integer | Reading at the entry, in the vehicle's distance unit. **Required for every type.** If the source has none (common for expenses), use the reading of the nearest entry in time, or interpolate between the neighbours. |
| `note` | string | `""` if none. Put any source fields that have no place here (e.g. service items, tags). |
| `totalCost` | integer | Minor units. `0` for `odometer` entries. |
| `volume` | number or `null` | `fuel` only: amount added, in the vehicle's volume unit (kWh when electric). `null` for other types. If the source has only cost and unit price, volume = cost / price. |
| `fullTank` | boolean | `fuel` only: filled up / charged to full. `false` for partial fills. `true` for other types. |
| `fuelTypeId` | id or `null` | `fuel` only: a `fuelTypes` row. |
| `placeId` | id or `null` | `fuel`: a `places` row of kind `fuel` (station). `service`: a `places` row of kind `service` (workshop). `null` otherwise. |
| `expenseCategoryId` | id or `null` | `expense` only: an `expenseCategories` row. |

The price per unit is not stored; the app shows `totalCost / volume`.

**Efficiency** is measured with the full-tank method: between two `fuel` entries with
`fullTank: true`, it adds up the volume of every fill after the first, up to and including the
second, and divides by the odometer difference. So mark partial fills `fullTank: false`, and keep a
missed fill-up out rather than guessing it: a gap shows as one unusually long segment.

### `reminders`

Maintenance due every N distance and/or every N days.

| Field | Type | Notes |
|---|---|---|
| `vehicleId` | id | |
| `name` | string, 1–100 chars | e.g. "Oil change" |
| `intervalDistance` | integer or `null` | Every N distance units. |
| `intervalDays` | integer or `null` | Every N days (a year is `365`). Set at least one of the two. |
| `lastDoneDate` | date or `null` | When it was last done, if that is not one of the entries. |
| `lastDoneOdometer` | integer or `null` | The reading at that time. |
| `archived` | boolean | |

The reminder counts from its latest **reset** (below), or from `lastDoneDate`/`lastDoneOdometer`
when it has none.

### `reminderResets`

`{ "entryId": …, "reminderId": … }` — says that the work of a reminder was done at a `service` entry
(the entry "resets" the reminder). An entry can reset several reminders. These links also build
the reminder's history of intervals. No id or timestamps.

### Lists: `fuelTypes`, `places`, `expenseCategories`

The choices users pick in entries. Each has `name` (1–100 chars); `places` also has `kind`:
`fuel` (fuel or charging station) or `service` (workshop). Create one row per distinct name in the
source (trimmed, case-insensitive) and point entries at it.

### `attachments` (optional)

Files attached to an entry, e.g. receipt photos.

| Field | Type | Notes |
|---|---|---|
| `entryId` | id | |
| `name` | string | File name, e.g. `receipt.jpg`. |
| `mimeType` | string | `image/jpeg`, `image/png`, `application/pdf`, … |
| `size` | integer | Byte length (recomputed on import). |
| `data` | string | The file, standard base64 with padding. |

Leave the `attachments` key out if there are none. With *Replace all*, a file without the key keeps
the attachments already on the device (for entries that come back), while a file with the key, even
an empty list, replaces them.

### `deleted` and `settings`

`deleted` lists rows deleted on the exporting device (`rowId`, `sourceTable` — the SQL table name such
as `entries` or `fuel_types` — and `deletedAt`), so merging the backup deletes them elsewhere too.
`settings` holds app preferences in full backups (`themeMode`, `locale`, `notifyLeadDays`, …).
A migration writes `"deleted": []` and leaves `settings` out.

## Importing

*Settings → Backup & restore → Restore from file*, then choose:

- **Merge** — adds the file to what is on the device. Rows with the same id are updated if the file's
  `updatedAt` is later. Safe to repeat.
- **Replace all** — deletes all vehicles, entries, reminders and lists first.

Unless restore points are turned off, the app saves one before importing, so an import can be undone
from *Settings → Backup & restore*.

## Migrating from another app

A checklist for a person or an LLM writing the converter:

1. Read the source export and find, per vehicle: name, units, currency, and each record's date,
   odometer, cost and kind (refuel, service, expense, other).
2. Create one `vehicles` row per vehicle. Pick `distanceUnit`, `volumeUnit` and `currencyCode` to
   match the source numbers; choose `efficiencyUnit` to taste (`litersPer100Km` in most of the
   world, `mpgUs` in the US, `kwhPer100Km` for electric). Guess `bodyType` from the model if you
   can, otherwise `null`.
3. Build the lists: distinct fuel grades → `fuelTypes`; stations → `places` with `kind: "fuel"`;
   garages → `places` with `kind: "service"`; expense categories → `expenseCategories`.
4. Convert each record to an `entries` row: money to integer minor units, volume as a number,
   `fullTank` from the source's full/partial flag (`true` if it has none), a missing odometer
   filled in from the neighbouring records. Records that are only an odometer reading become
   `type: "odometer"`. Unknown record kinds become `expense` with a category named after them.
5. Convert maintenance reminders, if any. Where the source says which service record completed a
   reminder, add a `reminderResets` link; otherwise set `lastDoneDate`/`lastDoneOdometer`.
6. Set `initialOdometer` to the lowest reading (or the source's starting value).
7. Use stable UUIDs, ISO dates, and fill every field — including `null`s and `"note": ""`.
8. Validate against [`garage-backup.schema.json`](garage-backup.schema.json), check that every
   `vehicleId`, `fuelTypeId`, `placeId`, `expenseCategoryId`, `entryId` and `reminderId` points to a
   row in the file, then import with **Merge**.

References to rows missing from both the file and the device are dropped on import (entries and
reminders of a missing vehicle are skipped; a missing list item reference becomes `null`), so a
broken reference loses data silently — check them before importing.
