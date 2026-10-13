import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../db/database.dart';

/// Formats values in a vehicle's units and currency for the active locale.
class VehicleFormat {
  VehicleFormat(this.l10n, this.vehicle)
      : locale = l10n.localeName,
        _currency = NumberFormat.simpleCurrency(locale: l10n.localeName, name: vehicle.currencyCode);

  factory VehicleFormat.of(BuildContext context, Vehicle vehicle) => VehicleFormat(context.l10n, vehicle);

  final AppLocalizations l10n;
  final Vehicle vehicle;
  final String locale;
  final NumberFormat _currency;

  int get currencyDigits => _currency.decimalDigits ?? 2;
  String get currencySymbol => _currency.currencySymbol;
  num get _minorFactor => pow(10, currencyDigits);

  String get distanceUnit => vehicle.distanceUnit.label(l10n);
  String get volumeUnit => vehicle.volumeUnit.label(l10n);
  String get efficiencyUnit => vehicle.efficiencyUnit.label(l10n);

  String number(num value, {int maxDigits = 0}) {
    final f = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = maxDigits;
    return f.format(value);
  }

  /// "2 400,50 ₽"
  String money(num minor) => _currency.format(minor / _minorFactor);

  /// Money without the currency symbol, for stat tiles that show units separately.
  String moneyValue(num minor) => number(minor / _minorFactor, maxDigits: (minor / _minorFactor).abs() >= 1000 ? 0 : currencyDigits);

  /// Short number for chart axes: "12K".
  String compactNumber(num value) => NumberFormat.compact(locale: locale).format(value);

  /// Short money for chart axes: "12K", "1.5M".
  String compactMoney(num minor) => NumberFormat.compact(locale: locale).format(minor / _minorFactor);

  /// Plain value for editing in a text field, e.g. "2400.5".
  String moneyInput(int minor) => _trim((minor / _minorFactor).toStringAsFixed(currencyDigits));

  int? parseMoney(String text) {
    final v = parseDecimal(text);
    return v == null ? null : (v * _minorFactor).round();
  }

  String distance(num value) => '${number(value)} $distanceUnit';
  String volume(double value) => '${number(value, maxDigits: 2)} $volumeUnit';
  String efficiency(double value) => '${number(value, maxDigits: 1)} $efficiencyUnit';

  String date(DateTime d) => DateFormat.yMMMd(locale).format(d);

  /// "Today", "Yesterday", "3 days ago", "Mar 5", "Mar 5, 2023".
  String friendlyDate(DateTime d, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final days = today.difference(DateUtils.dateOnly(d)).inDays;
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.yesterday;
    if (days > 1 && days < 7) return l10n.daysAgo(days);
    if (d.year == today.year) return DateFormat.MMMd(locale).format(d);
    return DateFormat.yMMMd(locale).format(d);
  }
}

/// Parses user input accepting both "," and "." as the decimal separator and ignoring spaces.
double? parseDecimal(String text) {
  final cleaned = text.replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

String formatDecimalInput(double value, {int digits = 2}) => _trim(value.toStringAsFixed(digits));

String _trim(String s) => s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
