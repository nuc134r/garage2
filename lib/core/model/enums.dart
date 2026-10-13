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

enum VolumeUnit {
  liter(1.0),
  galUs(3.785411784),
  galUk(4.54609);

  const VolumeUnit(this.literFactor);

  /// How many litres one unit is.
  final double literFactor;
}

enum EfficiencyUnit { litersPer100Km, kmPerLiter, mpgUs, mpgUk }
