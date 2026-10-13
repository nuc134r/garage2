import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/home_tiles.dart';
import 'home_tiles_view.dart';

/// Settings → Home screen tiles: add, remove, reorder and edit the home stat tiles.
class HomeTilesScreen extends ConsumerWidget {
  const HomeTilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tiles = ref.watch(appSettingsProvider).value?.homeTiles ?? defaultHomeTiles;
    final canAdd = tiles.length < maxHomeTiles;

    Future<void> edit(int i) async {
      final edited = await showHomeTileEditor(context, tiles[i]);
      if (edited != null) await saveHomeTiles(ref, [...tiles]..[i] = edited);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTiles),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: l10n.resetToDefault,
            onPressed: () => saveHomeTiles(ref, defaultHomeTiles),
          ),
        ],
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(l10n.addTile),
              onPressed: () async {
                final tile = await showHomeTileEditor(context, const HomeTile(HomeMetric.totalCost));
                if (tile != null) await saveHomeTiles(ref, [...tiles, tile]);
              },
            )
          : null,
      body: tiles.isEmpty
          ? EmptyState(icon: Icons.dashboard_customize, text: l10n.homeTilesEmpty)
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: tiles.length,
              onReorderItem: (from, to) {
                final list = [...tiles];
                list.insert(to, list.removeAt(from));
                saveHomeTiles(ref, list);
              },
              itemBuilder: (context, i) {
                final tile = tiles[i];
                return ListTile(
                  key: ValueKey('$i:$tile'),
                  leading: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                  title: Text(tile.metric.label(l10n)),
                  subtitle: Text(tile.effectivePeriod.label(l10n)),
                  onTap: () => edit(i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: l10n.delete,
                    onPressed: () => saveHomeTiles(ref, [...tiles]..removeAt(i)),
                  ),
                );
              },
            ),
    );
  }
}
