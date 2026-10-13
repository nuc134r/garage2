import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/format/vehicle_format.dart';
import '../../../l10n/l10n.dart';
import '../domain/stats_calculator.dart';

/// Categorical series colours (fuel, service, other), stepped per brightness and validated
/// against the card surfaces for colour-vision deficiencies. Exact values are in the tables below the charts.
List<Color> _seriesColors(Brightness b) => b == Brightness.dark
    ? const [Color(0xFF3987E5), Color(0xFFD95926), Color(0xFF199E70)]
    : const [Color(0xFF2A78D6), Color(0xFFEB6834), Color(0xFF1BAF7A)];

const _chartHeight = 200.0;

FlGridData _grid(ColorScheme scheme) => FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withValues(alpha: .5), strokeWidth: 1),
);

Widget _axisLabel(BuildContext context, TitleMeta meta, String text) => SideTitleWidget(
  meta: meta,
  child: Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  ),
);

/// Stacked monthly costs by entry type.
class MonthlyCostsChart extends StatelessWidget {
  const MonthlyCostsChart({super.key, required this.months, required this.fmt});

  final List<MonthCosts> months;
  final VehicleFormat fmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final colors = _seriesColors(theme.brightness);
    final labels = [l10n.fuelCost, l10n.serviceCost, l10n.otherCost];
    final surface = theme.cardTheme.color ?? scheme.surfaceContainer;
    final maxTotal = months.map((m) => m.total).fold(0, max);
    final monthFormat = DateFormat.MMM(l10n.localeName);
    final yearMonthFormat = DateFormat.yMMMM(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(items: [for (var i = 0; i < 3; i++) (labels[i], colors[i])]),
        const SizedBox(height: 12),
        SizedBox(
          height: _chartHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = (constraints.maxWidth - 48) / max(months.length, 1);
              final barWidth = (slot * .6).clamp(4.0, 24.0);
              // Label every n-th month so labels never collide.
              final every = max(1, (40 / slot).ceil());
              return BarChart(
                BarChartData(
                  maxY: maxTotal == 0 ? 1 : maxTotal * 1.1,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: _grid(scheme),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, meta) =>
                            v == meta.max ? const SizedBox.shrink() : _axisLabel(context, meta, fmt.compactMoney(v)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= months.length || (months.length - 1 - i) % every != 0) {
                            return const SizedBox.shrink();
                          }
                          return _axisLabel(context, meta, monthFormat.format(months[i].month));
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, _, _, _) {
                        final m = months[group.x];
                        final values = [m.fuel, m.service, m.other];
                        return BarTooltipItem(
                          '${yearMonthFormat.format(m.month)}\n',
                          theme.textTheme.labelMedium!.copyWith(
                            color: scheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.start,
                          children: [
                            for (var i = 0; i < 3; i++)
                              if (values[i] != 0)
                                TextSpan(
                                  text: '${labels[i]}: ${fmt.money(values[i])}\n',
                                  style: theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                                ),
                            TextSpan(
                              text: fmt.money(m.total),
                              style: theme.textTheme.labelMedium!.copyWith(
                                color: scheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (final (i, m) in months.indexed)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: m.total.toDouble(),
                            width: barWidth,
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            rodStackItems: _stack(m, colors, surface),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Segments bottom-up, separated by a thin surface-coloured gap.
  static List<BarChartRodStackItem> _stack(MonthCosts m, List<Color> colors, Color surface) {
    final items = <BarChartRodStackItem>[];
    var y = 0.0;
    for (final (i, v) in [m.fuel, m.service, m.other].indexed) {
      if (v == 0) continue;
      items.add(BarChartRodStackItem(y, y + v, colors[i], borderSide: BorderSide(color: surface, width: 1)));
      y += v;
    }
    return items;
  }
}

/// A single-series trend line over time with its average.
class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points, required this.format, required this.averageLabel});

  final List<TrendPoint> points;
  final String Function(double value) format;
  final String averageLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = context.l10n.localeName;
    final color = _seriesColors(theme.brightness).first;
    final surface = theme.cardTheme.color ?? scheme.surfaceContainer;
    final t0 = points.first.date;
    double x(DateTime d) => d.difference(t0).inHours / 24;
    final values = points.map((p) => p.value);
    final lo = values.reduce(min), hi = values.reduce(max);
    final pad = max((hi - lo) * .15, hi.abs() * .02);
    final avg = values.reduce((a, b) => a + b) / points.length;
    final span = x(points.last.date);
    final dateFormat = span > 300 ? DateFormat.yMMM(locale) : DateFormat.MMMd(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$averageLabel ${format(avg)}',
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _chartHeight,
          child: LineChart(
            LineChartData(
              minY: lo - pad,
              maxY: hi + pad,
              minX: 0,
              maxX: max(span, 1),
              gridData: _grid(scheme),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, meta) =>
                        v == meta.max || v == meta.min ? const SizedBox.shrink() : _axisLabel(context, meta, format(v)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(span / 3, 1),
                    getTitlesWidget: (v, meta) => v > meta.max - span * .15
                        ? const SizedBox.shrink()
                        : _axisLabel(context, meta, dateFormat.format(t0.add(Duration(hours: (v * 24).round())))),
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: avg,
                    color: scheme.onSurfaceVariant.withValues(alpha: .6),
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  FlLine(color: scheme.outline, strokeWidth: 1),
                  FlDotData(
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 5, color: color, strokeWidth: 2, strokeColor: surface),
                  ),
                ),
            ],
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      LineTooltipItem(
                        '${DateFormat.yMMMd(locale).format(points[s.spotIndex].date)}\n',
                        theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                        children: [
                          TextSpan(
                            text: format(s.y),
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: scheme.onInverseSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (final p in points) FlSpot(x(p.date), p.value)],
                  color: color,
                  barWidth: 2,
                  isCurved: false,
                  dotData: FlDotData(
                    show: points.length <= 16,
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2, strokeColor: surface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(String, Color)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final (label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
      ],
    );
  }
}
