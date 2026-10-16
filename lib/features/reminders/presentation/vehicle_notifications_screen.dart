import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/presentation/settings_screen.dart' show chooseOption, leadLabel;
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/notification_plan.dart';

/// Settings → Notifications → By vehicle: turn a vehicle's reminders off or give it its own lead time.
class VehicleNotificationsScreen extends ConsumerWidget {
  const VehicleNotificationsScreen({super.key});

  /// Picker value for "use the app-wide lead time".
  static const _useDefault = -1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettingsState({});
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final prefs = settings.vehicleNotify;
    final defaultLead = leadLabel(l10n, settings.notifyLeadDays);

    Future<void> save(String vehicleId, VehicleNotify value) => ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.vehicleNotifications, encodeVehicleNotify({...prefs, vehicleId: value}));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifByVehicle)),
      body: vehicles.isEmpty
          ? EmptyState(icon: Icons.directions_car, text: l10n.noVehicles)
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Island(
                  children: [
                    for (final v in vehicles)
                      Builder(builder: (context) {
                        final p = prefs[v.id] ?? VehicleNotify.defaults;
                        return ListTile(
                          leading: VehicleAvatar(v, radius: 20),
                          title: Text(v.name),
                          subtitle: Text(switch (p) {
                            VehicleNotify(enabled: false) => l10n.notifVehicleOff,
                            VehicleNotify(leadDays: final days?) => leadLabel(l10n, days),
                            _ => l10n.notifLeadDefault(defaultLead),
                          }),
                          trailing: Switch(
                            value: p.enabled,
                            onChanged: (on) => save(v.id, VehicleNotify(enabled: on, leadDays: p.leadDays)),
                          ),
                          onTap: !p.enabled
                              ? null
                              : () async {
                                  final days = await chooseOption(
                                    context,
                                    l10n.notifLead,
                                    {
                                      _useDefault: l10n.notifLeadUseDefault,
                                      for (final d in const [0, 3, 7, 14, 30]) d: leadLabel(l10n, d),
                                    },
                                    p.leadDays ?? _useDefault,
                                  );
                                  if (days == null) return;
                                  await save(v.id, VehicleNotify(leadDays: days == _useDefault ? null : days));
                                },
                        );
                      }),
                  ],
                ),
              ],
            ),
    );
  }
}
