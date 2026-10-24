import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../backup/presentation/backup_actions.dart';
import '../data/vehicle_repository.dart';

enum _Action { edit, archive, delete }

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vehicles = ref.watch(allVehiclesProvider);
    final summaries = ref.watch(vehicleSummariesProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        leading: homeUpButton(context),
        title: Text(l10n.garage),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
        onPressed: () => context.push(Routes.newVehicle),
      ),
      body: AsyncBuilder(
        vehicles,
        builder: (list) {
          if (list.isEmpty) return EmptyState(icon: Icons.directions_car, text: l10n.noVehicles);
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            buildDefaultDragHandles: false,
            onReorderItem: (from, to) {
              final ids = list.map((v) => v.id).toList();
              ids.insert(to, ids.removeAt(from));
              ref.read(vehicleRepositoryProvider).reorder(ids);
            },
            itemBuilder: (context, i) {
              final v = list[i];
              final summary = summaries[v.id];
              final fmt = VehicleFormat.of(context, v);
              final parts = [
                l10n.entriesCount(summary?.entryCount ?? 0),
                if (summary?.lastOdometer != null) fmt.distance(summary!.lastOdometer!),
                if (v.archived) l10n.archived,
              ];
              return Opacity(
                key: ValueKey(v.id),
                opacity: v.archived ? .55 : 1,
                child: ListTile(
                  leading: VehicleAvatar(v, radius: 22),
                  title: Text(v.name),
                  subtitle: Text(parts.join(' · ')),
                  onTap: v.archived ? null : () => context.go(Routes.home(v.id)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<_Action>(
                        onSelected: (a) => _onAction(
                          context,
                          ref,
                          v,
                          summary?.entryCount ?? 0,
                          a,
                          active: list.where((x) => !x.archived).length,
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(value: _Action.edit, child: Text(l10n.edit)),
                          PopupMenuItem(
                            value: _Action.archive,
                            child: Text(v.archived ? l10n.unarchive : l10n.archive),
                          ),
                          PopupMenuItem(value: _Action.delete, child: Text(l10n.delete)),
                        ],
                      ),
                      ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    Vehicle v,
    int entryCount,
    _Action action, {
    required int active,
  }) async {
    final l10n = context.l10n;
    final repo = ref.read(vehicleRepositoryProvider);
    switch (action) {
      case _Action.edit:
        context.push(Routes.editVehicle(v.id));
      case _Action.archive:
        // The app always needs one vehicle to open on.
        if (!v.archived && active <= 1) {
          showSnack(context, l10n.cannotArchiveLast);
          return;
        }
        await repo.setArchived(v.id, !v.archived);
      case _Action.delete:
        final ok = await confirm(
          context,
          title: l10n.deleteVehicleTitle(v.name),
          message: l10n.deleteVehicleMessage(entryCount),
          action: l10n.delete,
          destructive: true,
        );
        if (!ok) return;
        await safetyRestorePoint(ref, 'beforeDelete');
        await repo.delete(v.id);
    }
  }
}
