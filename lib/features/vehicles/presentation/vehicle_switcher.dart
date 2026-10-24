import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../reminders/application/notification_sync.dart';
import '../data/vehicle_repository.dart';

/// App bar title: avatar + vehicle name + dropdown arrow; opens the vehicle menu over itself.
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
              Flexible(
                child: Text(
                  vehicle.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the vehicle menu over [context]'s switcher: the page behind blurs and dims, and a card
/// unfolds with the current vehicle's row on top of the switcher, then the other vehicles.
Future<void> showVehiclePicker(BuildContext context, {String? currentId}) {
  final box = context.findRenderObject()! as RenderBox;
  final anchor = box.localToGlobal(Offset.zero) & box.size;
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (menuContext, animation, _) => _VehicleMenu(
        anchor: anchor,
        currentId: currentId,
        animation: animation,
        onNavigate: (go) {
          Navigator.pop(menuContext);
          go(context);
        },
      ),
    ),
  );
}

class _VehicleMenu extends ConsumerWidget {
  const _VehicleMenu({
    required this.anchor,
    required this.currentId,
    required this.animation,
    required this.onNavigate,
  });

  final Rect anchor;
  final String? currentId;
  final Animation<double> animation;
  final void Function(void Function(BuildContext context) go) onNavigate;

  static const _maxBlur = 12.0;
  static const _dim = .35;
  static const _maxWidth = 480.0;
  static const _listTop = 6.0;
  static const _carRadius = 30.0;

  /// Rows 5 px shorter than a standard tile (a density step is 4 px).
  static const _density = VisualDensity(vertical: -1.25);

  // A compact two-line tile is 67 high, its car centred 12 + _carRadius in from the row's left edge (8 margin).
  static const _rowCenter = _listTop + 1 + 33.5;
  static const _rowHeight = 67.0 + 2;
  static const _avatarCenter = 8 + 12 + _carRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final summaries = ref.watch(vehicleSummariesProvider).value ?? const {};
    final statuses = ref.watch(allReminderStatusesProvider).value ?? const [];
    final index = max(0, vehicles.indexWhere((v) => v.id == currentId));

    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    // Lines the rows' cars up with the switcher's (its avatar sits 4 + 16 in), and runs to the screen edge.
    final left = max(8.0, anchor.left + 4 + 16 - _avatarCenter);
    final width = min(_maxWidth, screen.width - left - 8);
    // The vehicles keep their order; the current one's row lands on the switcher where there is room
    // above it, and the menu stays on screen otherwise.
    final top = max(padding.top + 4, anchor.center.dy - _rowCenter - index * _rowHeight);
    final maxHeight = screen.height - top - padding.bottom - 8;

    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    Widget subtitle(Vehicle v) {
      final odometer = summaries[v.id]?.lastOdometer;
      final mine = statuses.where((s) => s.vehicle.id == v.id).map((s) => s.status);
      final overdue = mine.where((s) => s.isOverdue).length;
      final dueSoon = mine.where((s) => s.isDueSoon && !s.isOverdue).length;
      final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
      return Text.rich(
        TextSpan(
          children: [
            if (odometer != null) TextSpan(text: VehicleFormat.of(context, v).distance(odometer)),
            if (overdue > 0 || dueSoon > 0) ...[
              if (odometer != null) const TextSpan(text: '  ·  '),
              TextSpan(
                text: overdue > 0 ? l10n.vehicleOverdueCount(overdue) : l10n.vehicleDueSoonCount(dueSoon),
                style: TextStyle(color: overdue > 0 ? cs.error : cs.tertiary, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
        style: style,
      );
    }

    return Stack(
      children: [
        // Blur and dim build up with the menu.
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final t = curved.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _maxBlur * t, sigmaY: _maxBlur * t),
                  child: ColoredBox(color: Colors.black.withValues(alpha: _dim * t)),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          width: width,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, child) => Opacity(
                opacity: (curved.value * 3).clamp(0.0, 1.0),
                // Unfolds downwards from the first row.
                child: ClipRect(
                  child: Align(alignment: Alignment.topCenter, heightFactor: 0.25 + 0.75 * curved.value, child: child),
                ),
              ),
              child: Material(
                color: cs.surfaceContainerHigh,
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: _listTop, bottom: 6),
                        children: [
                          for (final v in vehicles)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                              child: ListTile(
                                tileColor: v.id == currentId ? cs.secondaryContainer : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                visualDensity: _density,
                                leading: VehicleAvatar(v, radius: _carRadius, circle: false),
                                title: Text(
                                  v.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: subtitle(v),
                                trailing: v.id == currentId ? Icon(Icons.check, color: cs.onSecondaryContainer) : null,
                                onTap: () => v.id == currentId
                                    ? Navigator.pop(context)
                                    : onNavigate((c) => c.go(Routes.home(v.id))),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Fills the card below the divider, so the whole block is the button.
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      leading: const Icon(Icons.garage_outlined),
                      title: Text(l10n.manageGarage),
                      onTap: () => onNavigate((c) => c.push(Routes.garage)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Vehicle list with a "manage garage" action (vehicles are added there); the wide-screen side panel.
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
          leading: const Icon(Icons.garage),
          title: Text(l10n.manageGarage),
          onTap: () => navigate((c) => c.push(Routes.garage)),
        ),
      ],
    );
  }
}
