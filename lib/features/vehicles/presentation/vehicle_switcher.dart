import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../data/vehicle_repository.dart';

/// App bar title: avatar + vehicle name + dropdown arrow; opens the picker sheet.
class VehicleSwitcherButton extends StatelessWidget {
  const VehicleSwitcherButton({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showVehiclePicker(context, currentId: vehicle.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VehicleAvatar(vehicle, radius: 16),
              const SizedBox(width: 10),
              Flexible(child: Text(vehicle.name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showVehiclePicker(BuildContext context, {String? currentId}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: VehicleList(
          currentId: currentId,
          onNavigate: (go) {
            Navigator.pop(sheetContext);
            go(context);
          },
        ),
      ),
    ),
  );
}

/// Vehicle list with "add" and "manage" actions; used by the picker sheet and the wide-screen side panel.
class VehicleList extends ConsumerWidget {
  const VehicleList({super.key, this.currentId, this.onNavigate, this.showTitle = true});

  final String? currentId;
  final bool showTitle;

  /// Wraps navigation so a sheet can close itself first.
  final void Function(void Function(BuildContext context) go)? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final summaries = ref.watch(vehicleSummariesProvider).value ?? const {};

    void navigate(void Function(BuildContext) go) => onNavigate != null ? onNavigate!(go) : go(context);

    return ListView(
      shrinkWrap: true,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(l10n.vehicles, style: Theme.of(context).textTheme.titleMedium),
          ),
        for (final v in vehicles)
          ListTile(
            leading: VehicleAvatar(v),
            title: Text(v.name),
            subtitle: summaries[v.id]?.lastOdometer == null
                ? null
                : Text(VehicleFormat.of(context, v).distance(summaries[v.id]!.lastOdometer!)),
            selected: v.id == currentId,
            trailing: v.id == currentId ? const Icon(Icons.check) : null,
            onTap: () => navigate((c) => c.go(Routes.home(v.id))),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(l10n.addVehicle),
          onTap: () => navigate((c) => c.push(Routes.newVehicle)),
        ),
        ListTile(
          leading: const Icon(Icons.garage_outlined),
          title: Text(l10n.manageGarage),
          onTap: () => navigate((c) => c.push(Routes.garage)),
        ),
      ],
    );
  }
}
