import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../home/domain/home_tiles.dart';

abstract final class SettingKeys {
  static const themeMode = 'themeMode';
  static const locale = 'locale';
  static const lastVehicleId = 'lastVehicleId';
  static const restorePoints = 'restorePoints';
  static const lastRestorePointAt = 'lastRestorePointAt';
  static const notifications = 'notifications';
  static const notifyLeadDays = 'notifyLeadDays';
  static const lastAttentionDay = 'lastAttentionDay';
  static const homeTiles = 'homeTiles';

  /// Settings carried over in a full backup (device-specific ones are excluded).
  static const portable = {themeMode, locale, restorePoints, notifyLeadDays, homeTiles};
}

class AppSettingsState {
  const AppSettingsState(this.values);

  final Map<String, String> values;

  ThemeMode get themeMode => ThemeMode.values.asNameMap()[values[SettingKeys.themeMode]] ?? ThemeMode.dark;

  /// Null means "follow the system".
  Locale? get locale => switch (values[SettingKeys.locale]) {
        null || '' => null,
        final code => Locale(code),
      };

  String? get lastVehicleId => values[SettingKeys.lastVehicleId];

  bool get restorePointsEnabled => values[SettingKeys.restorePoints] != 'false';

  DateTime? get lastRestorePointAt => DateTime.tryParse(values[SettingKeys.lastRestorePointAt] ?? '');

  /// Off until the user enables it (the permission prompt needs a user gesture on the web).
  bool get notificationsEnabled => values[SettingKeys.notifications] == 'true';

  int get notifyLeadDays => int.tryParse(values[SettingKeys.notifyLeadDays] ?? '') ?? 7;

  /// Day (yyyy-mm-dd) the "needs attention" summary was last shown.
  String? get lastAttentionDay => values[SettingKeys.lastAttentionDay];

  List<HomeTile> get homeTiles => parseHomeTiles(values[SettingKeys.homeTiles]);
}

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSettingsState> watch() => _db
      .select(_db.appSettings)
      .watch()
      .map((rows) => AppSettingsState({for (final r in rows) r.key: r.value}));

  Future<AppSettingsState> load() async =>
      AppSettingsState({for (final r in await _db.select(_db.appSettings).get()) r.key: r.value});

  Future<void> set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appSettings)..where((s) => s.key.equals(key))).go();
    } else {
      await _db.into(_db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
    }
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(appDatabaseProvider)));

final appSettingsProvider = StreamProvider<AppSettingsState>((ref) => ref.watch(settingsRepositoryProvider).watch());
