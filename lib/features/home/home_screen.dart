import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/db/database.dart';
import '../../core/format/vehicle_format.dart';
import '../../core/model/enums.dart';
import '../../core/widgets/widgets.dart';
import '../../l10n/l10n.dart';
import '../dictionaries/data/dictionary_repository.dart';
import '../entries/data/entry_repository.dart';
import '../entries/presentation/entry_list_item.dart';
import '../reminders/data/reminder_repository.dart';
import '../reminders/presentation/reminder_tile.dart';
import '../settings/data/settings_repository.dart';
import '../stats/domain/stats_calculator.dart';
import 'presentation/home_tiles_view.dart';
import '../vehicles/data/vehicle_repository.dart';
import '../vehicles/presentation/vehicle_switcher.dart';

/// Entry type filter per vehicle; empty means "all".
final entryFilterProvider = NotifierProvider.family<EntryFilter, Set<EntryType>, String>(EntryFilter.new);

class EntryFilter extends Notifier<Set<EntryType>> {
  EntryFilter(this.vehicleId);

  final String vehicleId;

  @override
  Set<EntryType> build() => const {};

  void toggle(EntryType type, bool selected) => state = selected ? {...state, type} : ({...state}..remove(type));

  void reset() => state = const {};
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.vehicleId});

  final String vehicleId;

  static const wideBreakpoint = 840.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehicleProvider(vehicleId));

    return switch (vehicle) {
      AsyncData(value: final v?) => _remember(ref, v, LayoutBuilder(
          builder: (context, constraints) {
            final content = _HomeContent(vehicle: v);
            if (constraints.maxWidth < wideBreakpoint) return content;
            final theme = Theme.of(context);
            return Material(
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Material(
                      color: theme.colorScheme.surfaceContainerLow,
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: VehicleList(currentId: v.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: content),
                    ),
                  ),
                ],
              ),
            );
          },
        )),
      AsyncData() => _redirectHome(context),
      AsyncError(:final error) => Scaffold(body: Center(child: Text(context.l10n.errorGeneric('$error')))),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _remember(WidgetRef ref, Vehicle v, Widget child) {
    final settings = ref.read(appSettingsProvider).value;
    if (settings != null && settings.lastVehicleId != v.id) {
      Future.microtask(() => ref.read(settingsRepositoryProvider).set(SettingKeys.lastVehicleId, v.id));
    }
    return child;
  }

  /// The vehicle no longer exists (deleted or replaced by a restore).
  Widget _redirectHome(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(Routes.launch);
    });
    return const Scaffold(body: SizedBox());
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= HomeScreen.wideBreakpoint;
    final fmt = VehicleFormat.of(context, vehicle);
    final entriesAsync = ref.watch(entriesProvider(vehicle.id));
    if (!entriesAsync.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final entries = entriesAsync.requireValue;
    final names = ref.watch(dictionaryNamesProvider).value ?? const {};
    final reminders = ref.watch(reminderStatusesProvider(vehicle.id)).value ?? const [];
    final filter = ref.watch(entryFilterProvider(vehicle.id));

    final efficiencies = fillEfficiencies(entries, vehicle);
    final visible = entries.reversed.where((e) => filter.isEmpty || filter.contains(e.type)).toList();

    void openStats() => context.push(Routes.stats(vehicle.id));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.newEntry),
        onPressed: () => context.push(Routes.newEntry(vehicle.id)),
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              titleSpacing: 8,
              title: wide ? Text(vehicle.name) : VehicleSwitcherButton(vehicle: vehicle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.settings,
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeStatTiles(
                      vehicle: vehicle,
                      entries: entries,
                      onOpenStats: (period) => context.push(Routes.stats(vehicle.id, period: period)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.insights),
                            label: Text(l10n.allStats),
                            onPressed: openStats,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.dashboard_customize_outlined),
                          tooltip: l10n.customizeTiles,
                          onPressed: () => context.push(Routes.homeTiles),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Island(
                title: l10n.reminders,
                children: [
                  for (final s in reminders.take(3))
                    ReminderTile(
                      status: s,
                      fmt: fmt,
                      onTap: () => context.push(Routes.reminder(vehicle.id, s.reminder.id)),
                    ),
                  if (reminders.isEmpty)
                    ListTile(
                      leading: const Icon(Icons.add_alert_outlined),
                      title: Text(l10n.createReminder),
                      subtitle: Text(l10n.createReminderHint),
                      onTap: () => context.push(Routes.newReminder(vehicle.id)),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: Text(l10n.allReminders),
                      trailing: Text('${reminders.length}'),
                      onTap: () => context.push(Routes.reminders(vehicle.id)),
                    ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _EntriesHeader(
                vehicleId: vehicle.id,
                count: visible.length,
                filtered: filter.isNotEmpty,
              ),
            ),
            if (visible.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  text: entries.isEmpty ? l10n.noEntriesYet : l10n.noEntriesFound,
                ),
              )
            else
              SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (context, i) {
                  final e = visible[i];
                  return Column(
                    children: [
                      EntryListItem(
                        entry: e,
                        fmt: fmt,
                        names: names,
                        efficiency: efficiencies[e.id],
                        onTap: () => context.push(Routes.entry(vehicle.id, e.id)),
                      ),
                      if (i + 1 < visible.length) EntryGap(newer: e, older: visible[i + 1], fmt: fmt),
                    ],
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }
}

/// Pinned "Entries" header with count and type filter chips.
class _EntriesHeader extends SliverPersistentHeaderDelegate {
  _EntriesHeader({required this.vehicleId, required this.count, required this.filtered});

  final String vehicleId;
  final int count;
  final bool filtered;

  static const _height = 104.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(_EntriesHeader old) => old.count != count || old.filtered != filtered || old.vehicleId != vehicleId;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Material(
      color: overlapsContent || shrinkOffset > 0 ? theme.colorScheme.surfaceContainer : theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(l10n.entries, style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Text(
                    filtered ? l10n.entriesCountFiltered(count) : l10n.entriesCount(count),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (filtered)
                    Consumer(
                      builder: (context, ref, _) => TextButton.icon(
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(l10n.resetFilter),
                        onPressed: () => ref.read(entryFilterProvider(vehicleId).notifier).reset(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final filter = ref.watch(entryFilterProvider(vehicleId));
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    for (final t in EntryType.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: filter.contains(t) ? null : Icon(t.icon, size: 18),
                          label: Text(t.label(l10n)),
                          selected: filter.contains(t),
                          onSelected: (sel) {
                            HapticFeedback.lightImpact();
                            ref.read(entryFilterProvider(vehicleId).notifier).toggle(t, sel);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
