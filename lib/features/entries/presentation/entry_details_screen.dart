import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/model/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../dictionaries/data/dictionary_repository.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../stats/domain/stats_calculator.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/entry_repository.dart';
import 'attachments.dart';
import 'entry_list_item.dart';

class EntryDetailsScreen extends ConsumerWidget {
  const EntryDetailsScreen({super.key, required this.vehicleId, required this.entryId});

  final String vehicleId;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final entries = ref.watch(entriesProvider(vehicleId)).value;
    final names = ref.watch(dictionaryNamesProvider).value ?? const {};
    final resets = ref.watch(reminderResetsProvider(vehicleId)).value ?? const [];
    final reminders = ref.watch(remindersProvider(vehicleId)).value ?? const [];

    if (vehicle == null || entries == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final index = entries.indexWhere((e) => e.id == entryId);
    if (index < 0) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off, text: l10n.entryNotFound));
    }
    final e = entries[index];
    // Refuels show the interval since the previous refuel (lists show gaps between any entries).
    final prevRefuel = e.type == EntryType.fuel
        ? entries.take(index).where((x) => x.type == EntryType.fuel).lastOrNull
        : null;
    final fmt = VehicleFormat.of(context, vehicle);
    final efficiency = fillEfficiencies(entries, vehicle)[e.id];
    final fixed = {for (final r in resets) if (r.entryId == e.id) r.reminderId};

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: l10n.delete,
            onPressed: () async {
              final ok = await confirm(context, title: l10n.deleteEntryTitle, action: l10n.delete, destructive: true);
              if (!ok) return;
              await ref.read(entryRepositoryProvider).delete(e.id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: Text(l10n.edit),
        onPressed: () => context.push(Routes.editEntry(vehicleId, e.id)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const SizedBox(height: 8),
          Center(child: Hero(tag: HeroTags.entryIcon(e.id), child: IconBadge(icon: e.type.icon(electric: fmt.isElectric), size: 72))),
          const SizedBox(height: 12),
          Center(
            child: HeroText(
              entryTitle(l10n, e, names, electric: fmt.isElectric),
              tag: HeroTags.entryTitle(e.id),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          if (e.totalCost != 0)
            Center(
              child: HeroText(
                fmt.money(e.totalCost),
                tag: HeroTags.entryCost(e.id),
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          const SizedBox(height: 8),
          Island(
            title: l10n.general,
            children: [
              ValueTile(icon: Icons.event, label: l10n.date, value: fmt.date(e.date)),
              ValueTile(icon: Icons.speed, label: l10n.odometer, value: fmt.distance(e.odometer)),
              if (prevRefuel != null)
                ValueTile(
                  icon: Icons.timeline,
                  label: fmt.isElectric ? l10n.sincePreviousCharge : l10n.sincePreviousRefuel,
                  value: '+${fmt.distance(e.odometer - prevRefuel.odometer)} · '
                      '${formatDays(l10n, DateUtils.dateOnly(e.date).difference(DateUtils.dateOnly(prevRefuel.date)).inDays)}',
                ),
            ],
          ),
          if (e.type == EntryType.fuel)
            Island(
              title: e.type.label(l10n, electric: fmt.isElectric),
              children: [
                if (e.volume != null) ValueTile(
                    icon: fmt.isElectric ? Icons.bolt : Icons.water_drop,
                    label: fmt.isElectric ? l10n.energy : l10n.volume,
                    value: fmt.volume(e.volume!),
                  ),
                if (e.volume != null && e.volume! > 0)
                  ValueTile(icon: Icons.sell, label: l10n.unitPrice, value: fmt.money(e.totalCost / e.volume!)),
                ValueTile(
                  icon: fmt.isElectric ? Icons.battery_full : Icons.local_gas_station,
                  label: fmt.isElectric ? l10n.fullCharge : l10n.fullTank, value: e.fullTank ? l10n.yes : l10n.no),
                if (efficiency != null) ValueTile(icon: Icons.eco, label: l10n.statEfficiency, value: fmt.efficiency(efficiency)),
                if (names[e.fuelTypeId] != null) ValueTile(icon: Icons.category, label: l10n.fuelType, value: names[e.fuelTypeId]!),
                if (names[e.placeId] != null) ValueTile(icon: Icons.place, label: fmt.isElectric ? l10n.chargingStation : l10n.fuelStation, value: names[e.placeId]!),
              ],
            ),
          if (e.type == EntryType.service && (names[e.placeId] != null || fixed.isNotEmpty))
            Island(
              title: l10n.entryTypeService,
              children: [
                if (names[e.placeId] != null) ValueTile(icon: Icons.place, label: l10n.serviceStation, value: names[e.placeId]!),
                for (final r in reminders.where((r) => fixed.contains(r.id)))
                  ListTile(
                    leading: Icon(Icons.task_alt, color: theme.colorScheme.primary),
                    title: Text(r.name),
                    subtitle: Text(l10n.reminderReset),
                    onTap: () => context.push(Routes.reminder(vehicleId, r.id)),
                  ),
              ],
            ),
          if (e.type == EntryType.expense && names[e.expenseCategoryId] != null)
            Island(
              title: l10n.entryTypeExpense,
              children: [
                ValueTile(icon: Icons.category, label: l10n.expenseCategory, value: names[e.expenseCategoryId]!),
              ],
            ),
          if (e.note.isNotEmpty)
            Island(
              title: l10n.note,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(alignment: Alignment.centerLeft, child: SelectableText(e.note)),
                ),
              ],
            ),
          // Attachments are the last block.
          EntryAttachments(entryId: e.id),
        ],
      ),
    );
  }
}
