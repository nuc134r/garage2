import 'package:flutter/material.dart';

import '../core/model/enums.dart';
import '../features/dictionaries/data/dictionary_repository.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension EntryTypeUi on EntryType {
  String label(AppLocalizations l10n) => switch (this) {
        EntryType.fuel => l10n.entryTypeFuel,
        EntryType.service => l10n.entryTypeService,
        EntryType.expense => l10n.entryTypeExpense,
        EntryType.odometer => l10n.entryTypeOdometer,
      };

  IconData get icon => switch (this) {
        EntryType.fuel => Icons.local_gas_station_outlined,
        EntryType.service => Icons.build_outlined,
        EntryType.expense => Icons.payments_outlined,
        EntryType.odometer => Icons.speed_outlined,
      };
}

extension DistanceUnitUi on DistanceUnit {
  String label(AppLocalizations l10n) => switch (this) {
        DistanceUnit.km => l10n.unitKm,
        DistanceUnit.mi => l10n.unitMi,
      };
}

extension VolumeUnitUi on VolumeUnit {
  String label(AppLocalizations l10n) => switch (this) {
        VolumeUnit.liter => l10n.unitLiter,
        VolumeUnit.galUs => l10n.unitGalUs,
        VolumeUnit.galUk => l10n.unitGalUk,
      };
}

extension EfficiencyUnitUi on EfficiencyUnit {
  String label(AppLocalizations l10n) => switch (this) {
        EfficiencyUnit.litersPer100Km => l10n.unitLitersPer100Km,
        EfficiencyUnit.kmPerLiter => l10n.unitKmPerLiter,
        EfficiencyUnit.mpgUs => l10n.unitMpgUs,
        EfficiencyUnit.mpgUk => l10n.unitMpgUk,
      };
}

extension DictionaryKindUi on DictionaryKind {
  String label(AppLocalizations l10n) => switch (this) {
        DictionaryKind.fuelType => l10n.dictFuelTypes,
        DictionaryKind.fuelStation => l10n.dictFuelStations,
        DictionaryKind.serviceStation => l10n.dictServiceStations,
        DictionaryKind.expenseCategory => l10n.dictExpenseCategories,
      };

  String singular(AppLocalizations l10n) => switch (this) {
        DictionaryKind.fuelType => l10n.fuelType,
        DictionaryKind.fuelStation => l10n.fuelStation,
        DictionaryKind.serviceStation => l10n.serviceStation,
        DictionaryKind.expenseCategory => l10n.expenseCategory,
      };
}

/// Localized name of a reminder preset key from `ReminderPreset.all`.
String reminderPresetName(AppLocalizations l10n, String key) => switch (key) {
      'engineOil' => l10n.presetEngineOil,
      'transmissionFluid' => l10n.presetTransmissionFluid,
      'fuelFilter' => l10n.presetFuelFilter,
      'timingBelt' => l10n.presetTimingBelt,
      'powerSteeringFluid' => l10n.presetPowerSteeringFluid,
      'brakeFluid' => l10n.presetBrakeFluid,
      'belts' => l10n.presetBelts,
      'coolant' => l10n.presetCoolant,
      'sparkPlugs' => l10n.presetSparkPlugs,
      'valveAdjustment' => l10n.presetValveAdjustment,
      _ => key,
    };

/// Human duration for a number of days: "3 days", "2 weeks", "5 months", "1 year".
String formatDays(AppLocalizations l10n, int days) {
  final d = days.abs();
  if (d >= 365) return l10n.nYears((d / 365).round());
  if (d >= 60) return l10n.nMonths((d / 30).round());
  if (d >= 14) return l10n.nWeeks((d / 7).round());
  return l10n.nDays(d);
}
