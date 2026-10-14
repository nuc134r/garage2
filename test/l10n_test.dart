import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:garage/l10n/l10n.dart';

void main() {
  test('backup summary puts each count in its place', () {
    expect(lookupAppLocalizations(const Locale('en')).backupContents(2, 196, 15), '2 vehicles, 196 entries, 15 reminders');
    expect(
      lookupAppLocalizations(const Locale('ru')).backupContents(2, 196, 15),
      'Автомобилей: 2, записей: 196, напоминаний: 15',
    );
  });

  // gen-l10n orders method parameters by the placeholder metadata, not by the message text.
  // Keeping both in the same order makes call sites read like the message.
  test('placeholder metadata follows the order of the English text', () {
    final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
    final mismatches = <String>[];
    for (final MapEntry(:key, :value) in arb.entries) {
      if (!key.startsWith('@') || key.startsWith('@@') || value is! Map) continue;
      final declared = (value['placeholders'] as Map?)?.keys.toList() ?? const [];
      if (declared.length < 2) continue;
      final message = arb[key.substring(1)] as String;
      final inText = RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m[1]!).toSet().toList();
      if (declared.join(',') != inText.join(',')) mismatches.add('${key.substring(1)}: $declared vs $inText');
    }
    expect(mismatches, isEmpty);
  });
}
