import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../db/database.dart';
import '../model/enums.dart';
import 'car_painter.dart';

export 'car_painter.dart';
export 'hero_widgets.dart';

/// Home/stat indicator: small label and period on top, big value with units below.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.title, required this.period, required this.value, this.units = '', this.onTap, this.onLongPress});

  final String title;
  final String period;
  final String value;
  final String units;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        onLongPress: onLongPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Opacity(opacity: .8, child: Text(title, style: theme.textTheme.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ),
                  Opacity(opacity: .4, child: Text(period, style: theme.textTheme.labelSmall)),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Opacity(opacity: .7, child: Text(units, style: theme.textTheme.labelMedium)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled card grouping list tiles ("island").
class Island extends StatelessWidget {
  const Island({super.key, this.title, required this.children, this.margin = const EdgeInsets.fromLTRB(12, 4, 12, 8)});

  final String? title;
  final List<Widget> children;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) SectionTitle(title!),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary))),
          ?trailing,
        ],
      ),
    );
  }
}

/// A label/value row for detail and stats screens.
class ValueTile extends StatelessWidget {
  const ValueTile({super.key, required this.label, required this.value, this.icon, this.onTap});

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Label and value share the row; a long value (e.g. a station name) wraps on its side
    // instead of squeezing the label.
    return ListTile(
      leading: icon == null ? null : Icon(icon, color: theme.colorScheme.primary),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 16),
          Flexible(child: Text(value, style: theme.textTheme.bodyLarge, textAlign: TextAlign.end)),
        ],
      ),
      onTap: onTap,
    );
  }
}

class VehicleAvatar extends StatelessWidget {
  const VehicleAvatar(this.vehicle, {super.key, this.radius = 18});

  final Vehicle vehicle;
  final double radius;

  @override
  Widget build(BuildContext context) =>
      VehicleBadge(name: vehicle.name, color: vehicle.color, bodyType: vehicle.bodyType, radius: radius);
}

/// Round vehicle badge: a schematic car in the vehicle's colour, or the name's initial without a body type.
class VehicleBadge extends StatelessWidget {
  const VehicleBadge({super.key, required this.name, required this.color, this.bodyType, this.radius = 18});

  final String name;
  final int color;
  final BodyType? bodyType;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = bodyType;
    if (body != null) {
      final background = theme.colorScheme.surfaceContainerHighest;
      return CircleAvatar(
        radius: radius,
        backgroundColor: background,
        child: CarDrawing(body: body, color: Color(color), width: radius * 1.8),
      );
    }
    final scheme = ColorScheme.fromSeed(seedColor: Color(color), brightness: theme.brightness);
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(initial, style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w600)),
    );
  }
}

/// Remaining-share bar; turns red when overdue.
class RemainingBar extends StatelessWidget {
  const RemainingBar({super.key, required this.fraction, this.height = 6, this.label});

  /// Remaining share: 1 = full bar (just done), 0 = empty (due), negative = overdue (red track).
  final double fraction;
  final double height;

  /// Shown below the bar with a small arrow pointing up at the end of the filled part
  /// (e.g. "in 2,100 km"); kept inside the bar's width near the edges.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final overdue = fraction < 0;
    final dueSoon = fraction < 0.1;
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: height,
        color: overdue || dueSoon ? scheme.error : scheme.primary,
        backgroundColor: overdue ? scheme.errorContainer : scheme.primaryContainer,
      ),
    );
    if (label == null) return bar;

    // Where the filled part ends; a little in from the edges so the arrow stays on the bar.
    final position = fraction.clamp(0.02, 0.98);
    final color = overdue || dueSoon ? scheme.error : scheme.onSurfaceVariant;
    final text = Text(
      label!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w500),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar,
        SizedBox(
          height: 10,
          child: CustomSingleChildLayout(
            delegate: _FitHorizontally(position),
            child: SizedBox(
              width: 22,
              child: OverflowBox(maxHeight: 22, child: Icon(Icons.arrow_drop_up, size: 22, color: color)),
            ),
          ),
        ),
        Stack(
          children: [
            // Gives the row the label's height; the visible copy is positioned over it.
            ExcludeSemantics(child: Visibility.maintain(visible: false, child: text)),
            Positioned.fill(child: CustomSingleChildLayout(delegate: _FitHorizontally(position), child: text)),
          ],
        ),
      ],
    );
  }
}

/// Centres the child on [position] (0–1) of the available width, shifted inwards so it never
/// leaves the bounds; the child is at most as wide as the space.
class _FitHorizontally extends SingleChildLayoutDelegate {
  const _FitHorizontally(this.position);

  final double position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = position * size.width - childSize.width / 2;
    return Offset(x.clamp(0.0, (size.width - childSize.width).clamp(0.0, double.infinity)), 0);
  }

  @override
  bool shouldRelayout(_FitHorizontally old) => old.position != position;
}

/// Renders an [AsyncValue] with a spinner and a simple error view.
class AsyncBuilder<T> extends StatelessWidget {
  const AsyncBuilder(this.value, {super.key, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.errorGeneric(error.toString()))),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  required String action,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
          FilledButton(
            style: destructive ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError) : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<String?> promptText(BuildContext context, {required String title, String initial = '', String? label}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(context.l10n.save)),
      ],
    ),
  ).then((v) => (v == null || v.isEmpty) ? null : v);
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
