enum EntryType { fuel, service, expense, odometer }

enum PlaceKind { fuel, service }

/// Car body shape for the vehicle's schematic avatar.
enum BodyType { sedan, hatchback, wagon, coupe, suv, pickup, van }

enum DistanceUnit {
  km(1.0),
  mi(1.609344);

  const DistanceUnit(this.kmFactor);

  /// How many kilometres one unit is.
  final double kmFactor;
}

/// What a fuel entry measures: liquid fuel, or electricity for an EV.
enum VolumeUnit {
  liter(1.0),
  galUs(3.785411784),
  galUk(4.54609),
  kwh(null);

  const VolumeUnit(this.literFactor);

  /// How many litres one unit is; null for energy.
  final double? literFactor;

  bool get isEnergy => literFactor == null;
}

enum EfficiencyUnit {
  litersPer100Km,
  kmPerLiter,
  mpgUs,
  mpgUk,
  kwhPer100Km,
  kmPerKwh,
  miPerKwh;

  bool get isEnergy => index >= kwhPer100Km.index;

  /// Whether a lower value means better efficiency.
  bool get lowerIsBetter => this == litersPer100Km || this == kwhPer100Km;

  /// The units that make sense for [volume] and [distance]; the first one is the default.
  static List<EfficiencyUnit> forUnits(VolumeUnit volume, DistanceUnit distance) => volume.isEnergy
      ? (distance == DistanceUnit.mi ? const [miPerKwh, kwhPer100Km, kmPerKwh] : const [kwhPer100Km, kmPerKwh, miPerKwh])
      : (distance == DistanceUnit.mi
          ? const [mpgUs, mpgUk, litersPer100Km, kmPerLiter]
          : const [litersPer100Km, kmPerLiter, mpgUs, mpgUk]);
}
