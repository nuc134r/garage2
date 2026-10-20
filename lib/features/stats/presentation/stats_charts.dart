import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/format/vehicle_format.dart';
import '../../../l10n/l10n.dart';
import '../domain/stats_calculator.dart';

/// Categorical series colours (fuel, service, other), stepped per brightness and validated
/// against the card surfaces for colour-vision deficiencies. Exact values are in the tables below the charts.
List<Color> _seriesColors(Brightness b) => chartPalette(b);

/// Categorical colours for charts; the first three are fuel, service and other expenses.
List<Color> chartPalette(Brightness b) => b == Brightness.dark
    ? const [Color(0xFF3987E5), Color(0xFFD95926), Color(0xFF199E70), Color(0xFFC98A1B), Color(0xFF9D6BD8), Color(0xFF4FA3B8)]
    : const [Color(0xFF2A78D6), Color(0xFFEB6834), Color(0xFF1BAF7A), Color(0xFFD9961C), Color(0xFF8E5BCC), Color(0xFF2F8FA6)];

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
  const MonthlyCostsChart({super.key, required this.months, required this.fmt, this.averageLabel});

  final List<MonthCosts> months;
  final VehicleFormat fmt;

  /// Shows the average month (caption and dashed line) when set.
  final String? averageLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final colors = _seriesColors(theme.brightness);
    final labels = [fmt.isElectric ? l10n.entryTypeCharging : l10n.fuelCost, l10n.serviceCost, l10n.otherCost];
    final surface = theme.cardTheme.color ?? scheme.surfaceContainer;
    final maxTotal = months.map((m) => m.total).fold(0, max);
    final average = months.isEmpty ? 0.0 : months.fold(0, (a, m) => a + m.total) / months.length;
    final monthFormat = DateFormat.MMM(l10n.localeName);
    final yearMonthFormat = DateFormat.yMMMM(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(items: [for (var i = 0; i < 3; i++) (labels[i], colors[i])]),
        if (averageLabel != null) ...[
          const SizedBox(height: 6),
          _AverageCaption('$averageLabel ${fmt.money(average)}'),
        ],
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
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [if (averageLabel != null) _averageLine(scheme, average)],
                  ),
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
  const TrendChart({super.key, required this.points, required this.format, this.averageLabel});

  final List<TrendPoint> points;
  final String Function(double value) format;

  /// Shows the average (caption and dashed line) when set.
  final String? averageLabel;

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
        if (averageLabel != null) ...[
          Text(
            '$averageLabel ${format(avg)}',
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
        ],
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
                  if (averageLabel != null)
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

/// One column per value (e.g. distance between services) with the [required] value as a dashed
/// line; columns above it are drawn in the error colour.
class IntervalColumnsChart extends StatelessWidget {
  const IntervalColumnsChart({
    super.key,
    required this.values,
    required this.labels,
    required this.required,
    required this.format,
    required this.requiredLabel,
  });

  final List<double> values;

  /// X-axis label per column (e.g. the date the gap ended).
  final List<String> labels;
  final double required;
  final String Function(double value) format;

  /// Caption for the dashed line, e.g. "Required: every 7,500 km".
  final String requiredLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _seriesColors(theme.brightness).first;
    final top = [required, ...values].reduce(max) * 1.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              child: CustomPaint(size: const Size(18, 2), painter: _DashPainter(scheme.onSurfaceVariant)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(requiredLabel, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _chartHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = (constraints.maxWidth - 48) / max(values.length, 1);
              final every = max(1, (56 / slot).ceil());
              return BarChart(
                BarChartData(
                  maxY: top,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: _grid(scheme),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(y: required, color: scheme.onSurfaceVariant, strokeWidth: 1.5, dashArray: const [5, 4]),
                    ],
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, meta) =>
                            v == meta.max ? const SizedBox.shrink() : _axisLabel(context, meta, format(v)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length || (labels.length - 1 - i) % every != 0) {
                            return const SizedBox.shrink();
                          }
                          return _axisLabel(context, meta, labels[i]);
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                        '${labels[group.x]}\n',
                        theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                        children: [
                          TextSpan(
                            text: format(rod.toY),
                            style: theme.textTheme.labelMedium!.copyWith(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  barGroups: [
                    for (final (i, v) in values.indexed)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: v,
                            width: (slot * .55).clamp(6.0, 28.0),
                            color: v > required ? scheme.error : color,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(min(x + 5, size.width), size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}


HorizontalLine _averageLine(ColorScheme scheme, double y) =>
    HorizontalLine(y: y, color: scheme.onSurfaceVariant.withValues(alpha: .7), strokeWidth: 1, dashArray: const [4, 4]);

/// "– – avg 135 $" above a chart, matching its dashed average line.
class _AverageCaption extends StatelessWidget {
  const _AverageCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomPaint(size: const Size(18, 2), painter: _DashPainter(theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
      ],
    );
  }
}

BarTooltipItem _barTooltip(ThemeData theme, String title, String value) => BarTooltipItem(
      '$title\n',
      theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onInverseSurface),
      children: [
        TextSpan(
          text: value,
          style: theme.textTheme.labelMedium!.copyWith(color: theme.colorScheme.onInverseSurface, fontWeight: FontWeight.w600),
        ),
      ],
    );

/// One column per bar, e.g. distance per month or per weekday, with an optional average line and one
/// highlighted column.
class ColumnsChart extends StatelessWidget {
  const ColumnsChart({
    super.key,
    required this.bars,
    required this.format,
    this.averageLabel,
    this.highlight,
    this.height = _chartHeight,
    this.fromZero = true,
  });

  /// Axis label, tooltip title and value of each column.
  final List<({String label, String title, double value})> bars;
  final String Function(double value) format;

  /// Shows the average (caption and dashed line) when set.
  final String? averageLabel;

  /// Index of a column drawn in the accent colour.
  final int? highlight;
  final double height;

  /// False: the axis starts a little below the lowest value, so small differences (e.g. efficiency) show.
  final bool fromZero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = chartPalette(theme.brightness);
    final values = bars.map((b) => b.value);
    final top = values.isEmpty ? 1.0 : values.reduce(max);
    final low = values.isEmpty ? 0.0 : values.reduce(min);
    final bottom = fromZero ? 0.0 : max(0.0, low - max((top - low) * .8, top * .05));
    final average = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / bars.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (averageLabel != null) ...[_AverageCaption('$averageLabel ${format(average)}'), const SizedBox(height: 12)],
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = (constraints.maxWidth - 48) / max(bars.length, 1);
              final every = max(1, (40 / slot).ceil());
              return BarChart(
                BarChartData(
                  minY: bottom,
                  maxY: top <= 0 ? 1 : (fromZero ? top * 1.12 : top + (top - bottom) * .12),
                  alignment: BarChartAlignment.spaceAround,
                  gridData: _grid(scheme),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(horizontalLines: [if (averageLabel != null) _averageLine(scheme, average)]),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, meta) => v == meta.max || (!fromZero && v == meta.min)
                            ? const SizedBox.shrink()
                            : _axisLabel(context, meta, format(v)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= bars.length || (bars.length - 1 - i) % every != 0) return const SizedBox.shrink();
                          return _axisLabel(context, meta, bars[i].label);
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, _, rod, _) => _barTooltip(theme, bars[group.x].title, format(rod.toY)),
                    ),
                  ),
                  barGroups: [
                    for (final (i, b) in bars.indexed)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            fromY: bottom,
                            toY: b.value,
                            width: (slot * .6).clamp(4.0, 28.0),
                            color: i == highlight ? palette[3] : palette[0],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
}

/// A ring of shares with the total in the middle and a legend with amounts and percentages.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.slices, required this.format, required this.total, this.totalLabel});

  final List<({String label, int value, Color color})> slices;
  final String Function(int value) format;

  /// Shown in the middle.
  final String total;
  final String? totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.cardTheme.color ?? scheme.surfaceContainer;
    final sum = slices.fold(0, (a, s) => a + s.value);
    final ring = SizedBox.square(
      dimension: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(enabled: false),
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.value.toDouble(),
                    color: s.color,
                    radius: 22,
                    showTitle: false,
                    borderSide: BorderSide(color: surface, width: 0),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(total, style: theme.textTheme.titleMedium),
                  if (totalLabel != null)
                    Text(totalLabel!, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final legend = Column(
      children: [
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(s.label, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                Text(format(s.value), style: theme.textTheme.bodyMedium),
                SizedBox(
                  width: 46,
                  child: Text(
                    sum == 0 ? '' : '${(s.value / sum * 100).round()} %',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < 300
          ? Column(children: [ring, const SizedBox(height: 12), legend])
          : Row(children: [ring, const SizedBox(width: 16), Expanded(child: legend)]),
    );
  }
}

/// Running totals of this period against the previous one (dashed), by days since each period began.
class CumulativeChart extends StatelessWidget {
  const CumulativeChart({
    super.key,
    required this.current,
    required this.start,
    required this.days,
    required this.format,
    required this.axisFormat,
    required this.currentLabel,
    this.previous,
    this.previousLabel,
  });

  final List<(double day, int total)> current;
  final List<(double day, int total)>? previous;

  /// First day of the current period and its length, for the x axis.
  final DateTime start;
  final double days;
  /// Totals (minor units) in the legend and on the axis.
  final String Function(num minor) format;
  final String Function(num minor) axisFormat;
  final String currentLabel;
  final String? previousLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = chartPalette(theme.brightness).first;
    final muted = scheme.onSurfaceVariant.withValues(alpha: .7);
    final locale = context.l10n.localeName;
    final monthFormat = days > 400 ? DateFormat.yMMM(locale) : DateFormat.MMM(locale);
    List<FlSpot> spots(List<(double, int)> s) => [for (final (x, y) in s) FlSpot(x, y.toDouble())];
    Widget legend(Color c, String text, {bool dashed = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dashed
                ? CustomPaint(size: const Size(18, 2), painter: _DashPainter(c))
                : Container(width: 18, height: 3, color: c),
            const SizedBox(width: 6),
            Text(text, style: theme.textTheme.labelMedium),
          ],
        );
    final top = [current.last.$2, ?previous?.last.$2].reduce(max).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            legend(color, '$currentLabel ${format(current.last.$2)}'),
            if (previous != null && previousLabel != null) legend(muted, '$previousLabel ${format(previous!.last.$2)}', dashed: true),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _chartHeight * .9,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(days, 1),
              minY: 0,
              maxY: top <= 0 ? 1 : top * 1.08,
              gridData: _grid(scheme),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, meta) =>
                        v == meta.max ? const SizedBox.shrink() : _axisLabel(context, meta, axisFormat(v)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(days / 3, 1),
                    getTitlesWidget: (v, meta) => v > meta.max - days * .15
                        ? const SizedBox.shrink()
                        : _axisLabel(context, meta, monthFormat.format(start.add(Duration(days: v.round())))),
                  ),
                ),
              ),
              lineBarsData: [
                if (previous != null)
                  LineChartBarData(
                    spots: spots(previous!),
                    isStepLineChart: true,
                    color: muted,
                    barWidth: 1.5,
                    dashArray: const [5, 4],
                    dotData: const FlDotData(show: false),
                  ),
                LineChartBarData(
                  spots: spots(current),
                  isStepLineChart: true,
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Values over time as dots (e.g. efficiency per fill) with a smoothed trend line through them.
class ScatterTrendChart extends StatelessWidget {
  const ScatterTrendChart({
    super.key,
    required this.points,
    required this.trend,
    required this.format,
    this.averageLabel,
    this.onTap,
  });

  final List<TrendPoint> points;
  final List<TrendPoint> trend;
  final String Function(double value) format;
  final String? averageLabel;

  /// Called with the index of a tapped point.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = chartPalette(theme.brightness);
    final surface = theme.cardTheme.color ?? scheme.surfaceContainer;
    final locale = context.l10n.localeName;
    final t0 = points.first.date;
    double x(DateTime d) => d.difference(t0).inHours / 24;
    final values = points.map((p) => p.value);
    final lo = values.reduce(min), hi = values.reduce(max);
    final pad = max((hi - lo) * .15, hi.abs() * .02);
    final avg = values.reduce((a, b) => a + b) / points.length;
    final span = max(x(points.last.date), 1.0);
    final dateFormat = span > 300 ? DateFormat.yMMM(locale) : DateFormat.MMMd(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (averageLabel != null) ...[_AverageCaption('$averageLabel ${format(avg)}'), const SizedBox(height: 12)],
        SizedBox(
          height: _chartHeight,
          child: LineChart(
            LineChartData(
              minY: lo - pad,
              maxY: hi + pad,
              minX: 0,
              maxX: span,
              gridData: _grid(scheme),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(horizontalLines: [if (averageLabel != null) _averageLine(scheme, avg)]),
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
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  final spot = response?.lineBarSpots?.where((s) => s.barIndex == 1).firstOrNull;
                  if (event is FlTapUpEvent && spot != null) onTap?.call(spot.spotIndex);
                },
                getTouchedSpotIndicator: (bar, indexes) => [
                  for (final _ in indexes)
                    TouchedSpotIndicatorData(
                      FlLine(color: scheme.outline, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (_, _, _, _) =>
                            FlDotCirclePainter(radius: 5, color: palette[0], strokeWidth: 2, strokeColor: surface),
                      ),
                    ),
                ],
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      s.barIndex != 1
                          ? null
                          : LineTooltipItem(
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
                  spots: [for (final p in trend) FlSpot(x(p.date), p.value)],
                  color: palette[1],
                  barWidth: 2.5,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: [for (final p in points) FlSpot(x(p.date), p.value)],
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: FlDotData(
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 3.5,
                      color: palette[0].withValues(alpha: .85),
                      strokeWidth: 1,
                      strokeColor: surface,
                    ),
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

/// Per-month price: the average as a line inside a band from the lowest to the highest fill.
class PriceRangeChart extends StatelessWidget {
  const PriceRangeChart({super.key, required this.months, required this.format, required this.legend});

  final List<({DateTime month, double low, double avg, double high})> months;
  final String Function(double value) format;

  /// Labels for the average line and the low–high band.
  final (String average, String range) legend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = chartPalette(theme.brightness).first;
    final locale = context.l10n.localeName;
    final monthFormat = DateFormat.MMM(locale);
    final lo = months.map((m) => m.low).reduce(min), hi = months.map((m) => m.high).reduce(max);
    final pad = max((hi - lo) * .15, hi * .02);
    final every = max(1, (months.length / 6).ceil());
    List<FlSpot> line(double Function(({DateTime month, double low, double avg, double high})) f) =>
        [for (final (i, m) in months.indexed) FlSpot(i.toDouble(), f(m))];
    final band = color.withValues(alpha: .18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(items: [(legend.$1, color), (legend.$2, band.withValues(alpha: .45))]),
        const SizedBox(height: 12),
        SizedBox(
          height: _chartHeight,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(months.length - 1, 1).toDouble(),
              minY: lo - pad,
              maxY: hi + pad,
              gridData: _grid(scheme),
              borderData: FlBorderData(show: false),
              betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 1, color: band)],
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
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (v != i || i < 0 || i >= months.length || (months.length - 1 - i) % every != 0) {
                        return const SizedBox.shrink();
                      }
                      return _axisLabel(context, meta, monthFormat.format(months[i].month));
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      s.barIndex != 2
                          ? null
                          : LineTooltipItem(
                              '${DateFormat.yMMMM(locale).format(months[s.spotIndex].month)}\n',
                              theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                              children: [
                                TextSpan(
                                  text: '${format(months[s.spotIndex].low)} – ${format(months[s.spotIndex].high)}\n',
                                  style: theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                                ),
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
                LineChartBarData(spots: line((m) => m.low), color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
                LineChartBarData(spots: line((m) => m.high), color: Colors.transparent, barWidth: 0, dotData: const FlDotData(show: false)),
                LineChartBarData(
                  spots: line((m) => m.avg),
                  color: color,
                  barWidth: 2.5,
                  dotData: FlDotData(show: months.length <= 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Service events on a time axis, one row per reminder (plus one for services without a reminder).
class ServiceTimelineChart extends StatelessWidget {
  const ServiceTimelineChart({super.key, required this.rows, required this.events, this.onTap});

  final List<String> rows;
  final List<({DateTime date, int row, String title})> events;

  /// Called with the index of a tapped event.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = chartPalette(theme.brightness);
    final locale = context.l10n.localeName;
    final dates = events.map((e) => e.date);
    final t0 = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final t1 = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    double x(DateTime d) => d.difference(t0).inHours / 24;
    final span = max(x(t1), 30.0);
    final dateFormat = span > 300 ? DateFormat.yMMM(locale) : DateFormat.MMMd(locale);
    const rowHeight = 34.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            for (final (i, r) in rows.indexed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: palette[i % palette.length], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(r, style: theme.textTheme.labelMedium),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: rows.length * rowHeight + 28,
          child: ScatterChart(
            ScatterChartData(
              minX: -span * .04,
              maxX: span * 1.04,
              minY: -.5,
              maxY: rows.length - .5,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 1,
                checkToShowHorizontalLine: (v) => (v - v.round()).abs() < .01,
                getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant.withValues(alpha: .5), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(span / 3, 1),
                    getTitlesWidget: (v, meta) => v < 0 || v > span * .9
                        ? const SizedBox.shrink()
                        : _axisLabel(context, meta, dateFormat.format(t0.add(Duration(days: v.round())))),
                  ),
                ),
              ),
              scatterTouchData: ScatterTouchData(
                touchCallback: (event, response) {
                  final spot = response?.touchedSpot;
                  if (event is FlTapUpEvent && spot != null) onTap?.call(spot.spotIndex);
                },
                touchTooltipData: ScatterTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spot) {
                    final e = events[events.indexWhere((e) => x(e.date) == spot.x && rows.length - 1 - e.row == spot.y)];
                    return ScatterTooltipItem(
                      '${DateFormat.yMMMd(locale).format(e.date)}\n',
                      textStyle: theme.textTheme.labelSmall!.copyWith(color: scheme.onInverseSurface),
                      children: [
                        TextSpan(
                          text: e.title,
                          style: theme.textTheme.labelMedium!.copyWith(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
                ),
              ),
              scatterSpots: [
                for (final e in events)
                  ScatterSpot(
                    x(e.date),
                    (rows.length - 1 - e.row).toDouble(),
                    dotPainter: FlDotCirclePainter(
                      radius: 7,
                      color: palette[e.row % palette.length],
                      strokeWidth: 2,
                      strokeColor: theme.cardTheme.color ?? scheme.surfaceContainer,
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

/// A tiny trend line without axes, ending in a dot.
class Sparkline extends StatelessWidget {
  const Sparkline(this.values, {super.key, this.color});

  final List<double> values;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    final c = color ?? Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v)],
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 2,
            color: c,
            dotData: FlDotData(
              checkToShowDot: (s, _) => s.x == values.length - 1,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 2.5, color: c, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(show: true, color: c.withValues(alpha: .12)),
          ),
        ],
      ),
    );
  }
}
