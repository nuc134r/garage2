import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dictionaries/data/dictionary_repository.dart';
import '../../entries/data/attachment_repository.dart';
import '../../entries/data/entry_repository.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../settings/data/settings_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';

/// Loads what the launch vehicle's home screen shows, so it is built in one go once the splash has
/// written the logo. While watched, the loaded data stays in memory for the home screen to pick up.
final homeWarmUpProvider = FutureProvider.autoDispose<void>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final settings = await ref.watch(appSettingsProvider.future);
  final id = launchVehicleId(vehicles, settings.lastVehicleId);
  if (id == null) return;
  await Future.wait([
    ref.watch(entriesProvider(id).future),
    ref.watch(reminderStatusesProvider(id).future),
    ref.watch(attachmentCountsProvider(id).future),
    ref.watch(dictionaryNamesProvider.future),
  ]);
});
