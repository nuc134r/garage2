# Backlog

## Next (requested)
- [ ] Fix remaining todos (this list)
- [ ] Push notifications for upcoming maintenance (reminders due soon / overdue, by date and estimated by mileage)
  - Android: `flutter_local_notifications` + scheduled checks; web: Notifications API while the tab is open
- [ ] File attachments for entries (bill photos, PDFs)
  - Storage: `attachments` table (entryId, name, mimeType, bytes/blob) — works on web via the same Drift DB
  - Backup: base64 in JSON, only in full mode (or a separate "include attachments" switch)
- [ ] App icon and notification icon (assets to be provided)

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
