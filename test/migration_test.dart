import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';

import 'generated_migrations/schema.dart';

// Schemas are dumped in `drift_schemas/`; see CLAUDE.md for the commands to run after a schema change.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in GeneratedHelper.versions.where((v) => v < GeneratedHelper.versions.last)) {
    test('upgrades from v$from to the current schema', () async {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, db.schemaVersion);
      await db.close();
    });
  }

  test('v1 data survives the upgrade', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      "INSERT INTO vehicles (id, created_at, updated_at, name) VALUES ('v', '2025-01-01T00:00:00', '2025-01-01T00:00:00', 'Old')",
    );
    schema.rawDatabase.execute(
      'INSERT INTO reminders (id, created_at, updated_at, vehicle_id, name, interval_days) '
      "VALUES ('r', '2025-01-01T00:00:00', '2025-01-01T00:00:00', 'v', 'Oil', 365)",
    );
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    final reminder = (await db.select(db.reminders).get()).single;
    expect(reminder.name, 'Oil');
    expect(reminder.lastDoneDate, isNull);
    expect(await db.select(db.attachments).get(), isEmpty);
  });
}
