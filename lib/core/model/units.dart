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
  if (volume <= 0 || distance <= 0) return null;
  final liters = volume * volumeUnit.literFactor;
  final km = distance * distanceUnit.kmFactor;
  return switch (target) {
    EfficiencyUnit.litersPer100Km => liters / km * 100,
    EfficiencyUnit.kmPerLiter => km / liters,
    EfficiencyUnit.mpgUs => (km / DistanceUnit.mi.kmFactor) / (liters / VolumeUnit.galUs.literFactor),
    EfficiencyUnit.mpgUk => (km / DistanceUnit.mi.kmFactor) / (liters / VolumeUnit.galUk.literFactor),
  };
}

/// Whether a lower value means better efficiency for this unit.
bool lowerIsBetter(EfficiencyUnit unit) => unit == EfficiencyUnit.litersPer100Km;
