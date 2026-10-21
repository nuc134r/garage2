import 'package:flutter/material.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/model/enums.dart';
import '../../../core/widgets/hero_widgets.dart';
import '../../../l10n/l10n.dart';

/// Title shown for an entry: its place/category name, else the type label.
String entryTitle(AppLocalizations l10n, Entry e, Map<String, String> names, {bool electric = false}) {
  final name = switch (e.type) {
    EntryType.fuel || EntryType.service => names[e.placeId],
    EntryType.expense => names[e.expenseCategoryId],
    EntryType.odometer => null,
  };
  return name ?? e.type.label(l10n, electric: electric);
}

class EntryListItem extends StatelessWidget {
  const EntryListItem({
    super.key,
    required this.entry,
    required this.fmt,
    required this.names,
    this.attachmentCount = 0,
    this.onTap,
  });

  final Entry entry;
  final VehicleFormat fmt;
  final Map<String, String> names;
  final int attachmentCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final e = entry;
    final details = [
      // The odometer only for odometer readings: elsewhere it is noise next to the gap lines.
      if (e.type == EntryType.odometer) fmt.distance(e.odometer),
      if (e.type == EntryType.fuel && e.volume != null) fmt.volume(e.volume!),
      if (e.type == EntryType.fuel && names[e.fuelTypeId] != null) names[e.fuelTypeId]!,
      if (e.type == EntryType.odometer && e.note.isNotEmpty) e.note.split('\n').first,
    ];
    return ListTile(
      onTap: onTap,
      leading: Hero(
        tag: HeroTags.entryIcon(e.id),
        child: IconBadge(icon: e.type.icon(electric: fmt.isElectric), size: 40),
      ),
      // The attachment mark sits after the title, so entries without details stay one line.
      title: Row(
        children: [
          Flexible(
            child: HeroText(entryTitle(l10n, e, names, electric: fmt.isElectric), tag: HeroTags.entryTitle(e.id), maxLines: 1),
          ),
          if (attachmentCount > 0) ...[
            const SizedBox(width: 6),
            Icon(Icons.attach_file, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
      subtitle: details.isEmpty ? null : Text(details.join(' • '), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (e.totalCost != 0)
            HeroText(
              fmt.money(e.totalCost),
              tag: HeroTags.entryCost(e.id),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
          Text(
            fmt.friendlyDate(e.date),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Faint "+350 km · 5 days" line between consecutive entries.
class EntryGap extends StatelessWidget {
  const EntryGap({super.key, required this.newer, required this.older, required this.fmt});

  final Entry newer;
  final Entry older;
  final VehicleFormat fmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final km = newer.odometer - older.odometer;
    final days = DateUtils.dateOnly(newer.date).difference(DateUtils.dateOnly(older.date)).inDays;
    if (km == 0 && days == 0) return const SizedBox(height: 2);
    final parts = [if (km != 0) '+${fmt.distance(km)}', if (days != 0) formatDays(fmt.l10n, days)];
    // Centred between the two entries it separates.
    return Center(
      child: Text(parts.join(' · '), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
    );
  }
}
