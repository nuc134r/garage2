import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';

/// Kinds of user-editable name lists.
enum DictionaryKind { fuelType, fuelStation, serviceStation, expenseCategory }

class DictionaryItem {
  const DictionaryItem(this.id, this.name);

  final String id;
  final String name;
}

class DictionaryRepository {
  DictionaryRepository(this._db);

  final AppDatabase _db;

  Stream<List<DictionaryItem>> watch(DictionaryKind kind) {
    switch (kind) {
      case DictionaryKind.fuelType:
        return (_db.select(_db.fuelTypes)..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .watch()
            .map((rows) => [for (final r in rows) DictionaryItem(r.id, r.name)]);
      case DictionaryKind.expenseCategory:
        return (_db.select(_db.expenseCategories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .watch()
            .map((rows) => [for (final r in rows) DictionaryItem(r.id, r.name)]);
      case DictionaryKind.fuelStation:
      case DictionaryKind.serviceStation:
        final placeKind = kind == DictionaryKind.fuelStation ? PlaceKind.fuel : PlaceKind.service;
        return (_db.select(_db.places)
              ..where((p) => p.kind.equalsValue(placeKind))
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .watch()
            .map((rows) => [for (final r in rows) DictionaryItem(r.id, r.name)]);
    }
  }

  Future<String> add(DictionaryKind kind, String name) async {
    final id = newId();
    switch (kind) {
      case DictionaryKind.fuelType:
        await _db.into(_db.fuelTypes).insert(FuelTypesCompanion.insert(id: Value(id), name: name));
      case DictionaryKind.expenseCategory:
        await _db.into(_db.expenseCategories).insert(ExpenseCategoriesCompanion.insert(id: Value(id), name: name));
      case DictionaryKind.fuelStation:
        await _db.into(_db.places).insert(PlacesCompanion.insert(id: Value(id), name: name, kind: PlaceKind.fuel));
      case DictionaryKind.serviceStation:
        await _db.into(_db.places).insert(PlacesCompanion.insert(id: Value(id), name: name, kind: PlaceKind.service));
    }
    return id;
  }

  Future<void> rename(DictionaryKind kind, String id, String name) async {
    final now = Value(DateTime.now());
    switch (kind) {
      case DictionaryKind.fuelType:
        await (_db.update(_db.fuelTypes)..where((t) => t.id.equals(id)))
            .write(FuelTypesCompanion(name: Value(name), updatedAt: now));
      case DictionaryKind.expenseCategory:
        await (_db.update(_db.expenseCategories)..where((t) => t.id.equals(id)))
            .write(ExpenseCategoriesCompanion(name: Value(name), updatedAt: now));
      case DictionaryKind.fuelStation:
      case DictionaryKind.serviceStation:
        await (_db.update(_db.places)..where((t) => t.id.equals(id)))
            .write(PlacesCompanion(name: Value(name), updatedAt: now));
    }
  }

  Future<void> delete(DictionaryKind kind, String id) => _db.deleteSynced(
        switch (kind) {
          DictionaryKind.fuelType => _db.fuelTypes,
          DictionaryKind.expenseCategory => _db.expenseCategories,
          DictionaryKind.fuelStation || DictionaryKind.serviceStation => _db.places,
        },
        id,
      );
}

final dictionaryRepositoryProvider = Provider((ref) => DictionaryRepository(ref.watch(appDatabaseProvider)));

final dictionaryProvider = StreamProvider.family<List<DictionaryItem>, DictionaryKind>(
    (ref, kind) => ref.watch(dictionaryRepositoryProvider).watch(kind));

/// All dictionary names by id, for labelling entries.
final dictionaryNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final lists = await Future.wait([
    for (final kind in DictionaryKind.values) ref.watch(dictionaryProvider(kind).future),
  ]);
  return {for (final list in lists) for (final item in list) item.id: item.name};
});
