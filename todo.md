# Backlog

## Next (requested)
- [ ] Fix remaining todos (this list)
- [x] Push notifications for upcoming maintenance (reminders due soon / overdue, by date and estimated by mileage)
  - Android: scheduled ahead (due-soon + due day, 10:00) and a daily "needs attention" summary on open
  - Web: summary shown when the app is opened (browsers can't schedule while closed)
- [ ] Configurable home screen stats (choose which tiles and periods appear on the home screen)
- [ ] File attachments for entries (bill photos, PDFs)
  - Storage: `attachments` table (entryId, name, mimeType, bytes/blob) — works on web via the same Drift DB
  - Backup: base64 in JSON, only in full mode (or a separate "include attachments" switch)
- [x] App icon and notification icon (`icons/*.svg` → `tool/generate_icons.py`)
- [ ] Repository link (https://github.com/nuc134r/garage2) in Settings → About
- [ ] App name should always be lowercase "garage"
- [ ] Fancy Hero / container-transform animations when navigating to entries, reminders, stats, etc.
  (e.g. entry icon → details header, reminder tile → details, stat tile → stats screen; must work with go_router)

## Open
- [ ] Release signing for Android (currently signed with debug keys), CI
- [ ] Charts on the stats screen (monthly costs, efficiency trend)
- [ ] Custom date range on the stats screen
- [ ] Vehicle photo
- [ ] Reminder: set "last done" date/odometer when creating it (now counts from creation)
- [ ] Deletions don't propagate on merge import (merge is upsert-only by design)

## Known environment quirks
- The Claude desktop browser pane blocks network requests from SharedWorkers, so the
  drift web worker can't load `sqlite3.wasm` there. Real Chrome/Edge/Firefox are fine.
