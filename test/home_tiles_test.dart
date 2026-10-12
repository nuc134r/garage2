import 'package:flutter_test/flutter_test.dart';
import 'package:garage/features/home/domain/home_tiles.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';

void main() {
  test('missing setting gives the defaults', () {
    expect(parseHomeTiles(null), defaultHomeTiles);
  });

  test('empty setting means no tiles', () {
    expect(parseHomeTiles(''), isEmpty);
  });

  test('round-trips through the setting string', () {
    const tiles = [HomeTile(HomeMetric.fuelPrice, StatsPeriod.year), HomeTile(HomeMetric.odometer, StatsPeriod.week)];
    final encoded = encodeHomeTiles(tiles);
    expect(encoded, 'fuelPrice:year,odometer:allTime');
    expect(parseHomeTiles(encoded), tiles);
  });

  test('skips unknown metrics and defaults unknown periods', () {
    expect(parseHomeTiles('bogus:week,mileage:decade'), const [HomeTile(HomeMetric.mileage)]);
    expect(parseHomeTiles('garbage'), defaultHomeTiles);
  });

  test('caps the number of tiles', () {
    expect(parseHomeTiles(List.filled(20, 'mileage:week').join(',')), hasLength(maxHomeTiles));
  });
}
