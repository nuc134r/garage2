import 'package:flutter/material.dart';

export 'hero_tags.dart';

/// Text that flies between routes, morphing its style (size, weight, colour) on the way.
class HeroText extends StatelessWidget {
  const HeroText(this.text, {super.key, required this.tag, this.style, this.maxLines, this.textAlign});

  final Object tag;
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, animation, direction, fromContext, toContext) {
        final from = _styleOf(fromContext) ?? resolved;
        final to = _styleOf(toContext) ?? resolved;
        final curved = CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
        return AnimatedBuilder(
          animation: curved,
          builder: (_, _) {
            // The animation runs 0→1 on push and 1→0 on pop, always from the source to the destination route.
            final style = direction == HeroFlightDirection.push
                ? TextStyle.lerp(from, to, curved.value)
                : TextStyle.lerp(to, from, curved.value);
            return Material(
              type: MaterialType.transparency,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(text, style: style, maxLines: 1, softWrap: false),
              ),
            );
          },
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Text(text, style: resolved, maxLines: maxLines, textAlign: textAlign, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  static TextStyle? _styleOf(BuildContext heroContext) {
    final hero = heroContext.widget;
    if (hero is! Hero) return null;
    final material = hero.child;
    if (material is! Material) return null;
    final text = material.child;
    return text is Text ? text.style : null;
  }
}

/// A round icon badge that scales with the space it gets, so it can fly between sizes.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.size,
    this.background,
    this.foreground,
    this.attached = false,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? foreground;

  /// Shows a small paperclip on the bottom-right corner (the entry has attachments).
  final bool attached;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final d = constraints.biggest.shortestSide;
          final circle = Container(
            width: d,
            height: d,
            decoration: BoxDecoration(color: background ?? scheme.secondaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: d * .5, color: foreground ?? scheme.onSecondaryContainer),
          );
          if (!attached) return Center(child: circle);
          // Scales with the badge (20 px on a 40 px icon); the ring in the page colour separates it from the icon.
          final mark = d * .5;
          return Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                circle,
                Positioned(
                  right: -d * .075,
                  bottom: -d * .075,
                  child: Container(
                    width: mark,
                    height: mark,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surfaceContainerHighest,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: d * .05),
                    ),
                    child: Icon(Icons.attach_file, size: mark * .55, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
