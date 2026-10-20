import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/format/vehicle_format.dart';
import 'package:garage/l10n/l10n.dart';

import 'helpers.dart';

void main() {
  final en = VehicleFormat(lookupAppLocalizations(const Locale('en')), testVehicle());
  final ru = VehicleFormat(lookupAppLocalizations(const Locale('ru')), testVehicle());

  test('short money drops cents and shortens thousands', () {
    expect(en.shortMoney(46917784), '€469K');
    expect(en.shortMoney(150702), '€1.51K');
    expect(en.shortMoney(81508), '€815');
    expect(en.shortMoney(5150), '€52');
    expect(en.shortMoney(9), '€0.09', reason: 'small amounts such as cost per km keep cents');
    expect(ru.shortMoney(46917784), '469 тыс. €');
  });

  test('short numbers and distances', () {
    expect(en.shortDistance(17350), '17.4K km');
    expect(en.shortDistance(815), '815 km');
    expect(en.shortNumber(6.54, maxDigits: 1), '6.5');
  });
}
