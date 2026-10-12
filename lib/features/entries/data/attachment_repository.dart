import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';

/// Attachment metadata without the content, for lists.
class AttachmentInfo {
  const AttachmentInfo({
    required this.id,
    required this.entryId,
    required this.name,
    required this.mimeType,
    required this.size,
    required this.createdAt,
  });

  final String id;
  final String entryId;
  final String name;
  final String mimeType;
  final int size;
  final DateTime createdAt;

  bool get isImage => mimeType.startsWith('image/');
}

class AttachmentRepository {
  AttachmentRepository(this._db);

  /// Larger files are rejected: they live in the database and in full backups.
  static const maxSize = 15 * 1024 * 1024;

  final AppDatabase _db;

  $AttachmentsTable get _t => _db.attachments;

  Stream<List<AttachmentInfo>> watchForEntry(String entryId) {
    final q = _db.selectOnly(_t)
      ..addColumns([_t.id, _t.entryId, _t.name, _t.mimeType, _t.size, _t.createdAt])
      ..where(_t.entryId.equals(entryId))
      ..orderBy([OrderingTerm.asc(_t.createdAt)]);
    return q.watch().map((rows) => [
          for (final r in rows)
            AttachmentInfo(
              id: r.read(_t.id)!,
              entryId: r.read(_t.entryId)!,
              name: r.read(_t.name)!,
              mimeType: r.read(_t.mimeType)!,
              size: r.read(_t.size)!,
              createdAt: r.read(_t.createdAt)!,
            ),
        ]);
  }

  /// Number of attachments per entry of a vehicle.
  Stream<Map<String, int>> watchCountsForVehicle(String vehicleId) {
    final count = _t.id.count();
    final q = _db.selectOnly(_t).join([innerJoin(_db.entries, _db.entries.id.equalsExp(_t.entryId), useColumns: false)])
      ..addColumns([_t.entryId, count])
      ..where(_db.entries.vehicleId.equals(vehicleId))
      ..groupBy([_t.entryId]);
    return q.watch().map((rows) => {for (final r in rows) r.read(_t.entryId)!: r.read(count)!});
  }

  Future<Uint8List?> bytes(String id) async {
    final q = _db.selectOnly(_t)
      ..addColumns([_t.data])
      ..where(_t.id.equals(id));
    return (await q.getSingleOrNull())?.read(_t.data);
  }

  Future<String> add({required String entryId, required String name, required String mimeType, required Uint8List data}) async {
    final id = newId();
    await _db.into(_t).insert(AttachmentsCompanion.insert(
          id: Value(id),
          entryId: entryId,
          name: name,
          mimeType: mimeType,
          size: data.length,
          data: data,
        ));
    return id;
  }

  Future<void> delete(String id) => (_db.delete(_t)..where((a) => a.id.equals(id))).go();
}

final attachmentRepositoryProvider = Provider((ref) => AttachmentRepository(ref.watch(appDatabaseProvider)));

final attachmentsProvider = StreamProvider.autoDispose
    .family<List<AttachmentInfo>, String>((ref, entryId) => ref.watch(attachmentRepositoryProvider).watchForEntry(entryId));

final attachmentCountsProvider = StreamProvider.autoDispose.family<Map<String, int>, String>(
    (ref, vehicleId) => ref.watch(attachmentRepositoryProvider).watchCountsForVehicle(vehicleId));

/// Content of one attachment; kept while something shows it.
final attachmentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, id) => ref.watch(attachmentRepositoryProvider).bytes(id));
