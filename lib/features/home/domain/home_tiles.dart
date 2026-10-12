import '../../stats/domain/stats_calculator.dart';

/// A value that can be shown in a home screen stat tile.
enum HomeMetric {
  fuelCost,
  efficiency,
  odometer,
  totalCost,
  serviceCost,
  otherCost,
  mileage,
  fuelVolume,
  fuelPrice,
  costPerDistance;

  /// The odometer is a current reading, not an aggregate over a period.
  bool get hasPeriod => this != odometer;
}

/// One configured tile: what to show and over which period.
class HomeTile {
  const HomeTile(this.metric, [this.period = StatsPeriod.month]);

  final HomeMetric metric;
  final StatsPeriod period;

  /// The period the tile actually covers.
  StatsPeriod get effectivePeriod => metric.hasPeriod ? period : StatsPeriod.allTime;

  HomeTile copyWith({HomeMetric? metric, StatsPeriod? period}) => HomeTile(metric ?? this.metric, period ?? this.period);

  @override
  bool operator ==(Object other) => other is HomeTile && other.metric == metric && other.effectivePeriod == effectivePeriod;

  @override
  int get hashCode => Object.hash(metric, effectivePeriod);

  @override
  String toString() => '${metric.name}:${effectivePeriod.name}';
}

const defaultHomeTiles = [
  HomeTile(HomeMetric.fuelCost),
  HomeTile(HomeMetric.efficiency),
  HomeTile(HomeMetric.odometer, StatsPeriod.allTime),
  HomeTile(HomeMetric.totalCost),
];

const maxHomeTiles = 8;

/// "fuelCost:month,odometer:allTime"; unknown parts are skipped, null/garbage gives the defaults.
List<HomeTile> parseHomeTiles(String? value) {
  if (value == null) return defaultHomeTiles;
  if (value.isEmpty) return const [];
  final metrics = HomeMetric.values.asNameMap();
  final periods = StatsPeriod.values.asNameMap();
  final tiles = <HomeTile>[];
  for (final part in value.split(',')) {
    final [m, p, ...] = [...part.split(':'), ''];
    final metric = metrics[m];
    if (metric == null) continue;
    tiles.add(HomeTile(metric, periods[p] ?? StatsPeriod.month));
  }
  return tiles.isEmpty ? defaultHomeTiles : tiles.take(maxHomeTiles).toList();
}

String encodeHomeTiles(List<HomeTile> tiles) => tiles.join(',');
