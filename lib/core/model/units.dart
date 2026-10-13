import 'enums.dart';

/// Converts a fuel amount over a distance (both in the vehicle's own units)
/// into the requested efficiency unit. Returns null when not computable.
double? convertEfficiency({
  required double volume,
  required double distance,
  required VolumeUnit volumeUnit,
  required DistanceUnit distanceUnit,
  required EfficiencyUnit target,
}) {
  if (volume <= 0 || distance <= 0 || volumeUnit.isEnergy != target.isEnergy) return null;
  final km = distance * distanceUnit.kmFactor;
  if (volumeUnit.isEnergy) {
    return switch (target) {
      EfficiencyUnit.kwhPer100Km => volume / km * 100,
      EfficiencyUnit.kmPerKwh => km / volume,
      EfficiencyUnit.miPerKwh => km / DistanceUnit.mi.kmFactor / volume,
      _ => null,
    };
  }
  final liters = volume * volumeUnit.literFactor!;
  return switch (target) {
    EfficiencyUnit.litersPer100Km => liters / km * 100,
    EfficiencyUnit.kmPerLiter => km / liters,
    EfficiencyUnit.mpgUs => (km / DistanceUnit.mi.kmFactor) / (liters / VolumeUnit.galUs.literFactor!),
    EfficiencyUnit.mpgUk => (km / DistanceUnit.mi.kmFactor) / (liters / VolumeUnit.galUk.literFactor!),
    _ => null,
  };
}

/// Whether a lower value means better efficiency for this unit.
bool lowerIsBetter(EfficiencyUnit unit) => unit.lowerIsBetter;
