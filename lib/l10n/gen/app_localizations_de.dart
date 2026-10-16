// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addFirstVehicle => 'Füge dein erstes Fahrzeug hinzu';

  @override
  String get addTile => 'Kachel hinzufügen';

  @override
  String get addVehicle => 'Fahrzeug hinzufügen';

  @override
  String get allDataDeleted => 'Alle Daten gelöscht';

  @override
  String get allReminders => 'Alle Erinnerungen';

  @override
  String get allStats => 'Alle Statistiken';

  @override
  String get appTitle => 'garage';

  @override
  String get appVersion => 'App-Version';

  @override
  String get appearance => 'Darstellung';

  @override
  String get archive => 'Archivieren';

  @override
  String get archived => 'Archiviert';

  @override
  String get attach => 'Anhängen';

  @override
  String get attachChooseFile => 'Datei auswählen';

  @override
  String get attachChooseFileHint => 'PDF, Bilder und andere Dokumente';

  @override
  String get attachChoosePhotos => 'Fotos auswählen';

  @override
  String get attachTakePhoto => 'Foto aufnehmen';

  @override
  String attachmentTooLarge(String name, int max) {
    return '$name ist größer als $max MB';
  }

  @override
  String get attachments => 'Anhänge';

  @override
  String get autoRestorePoints => 'Automatische Wiederherstellungspunkte';

  @override
  String autoRestorePointsHint(int count) {
    return 'Täglich und vor jedem Import oder Löschen. Die letzten $count bleiben auf diesem Gerät.';
  }

  @override
  String get average => 'Ø';

  @override
  String get avgDaily => 'Tagesdurchschnitt';

  @override
  String get avgDistanceBetweenCharges => 'Strecke zwischen Ladevorgängen';

  @override
  String get avgDistanceBetweenRefuels => 'Strecke zwischen Tankstopps';

  @override
  String get avgDistanceBetweenServices => 'Strecke zwischen Wartungen';

  @override
  String get avgEnergyPrice => 'Ø Strompreis';

  @override
  String get avgFuelPrice => 'Ø Kraftstoffpreis';

  @override
  String get avgMonthly => 'Monatsdurchschnitt';

  @override
  String get avgTimeBetweenCharges => 'Zeit zwischen Ladevorgängen';

  @override
  String get avgTimeBetweenRefuels => 'Zeit zwischen Tankstopps';

  @override
  String get avgTimeBetweenServices => 'Zeit zwischen Wartungen';

  @override
  String get avgYearly => 'Jahresdurchschnitt';

  @override
  String get backupAndRestore => 'Sichern & wiederherstellen';

  @override
  String backupContents(int vehicles, int entries, int reminders) {
    return '$vehicles Fahrzeuge, $entries Einträge, $reminders Erinnerungen';
  }

  @override
  String backupExportedAt(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get backupIncludesSettings => 'Enthält App-Einstellungen';

  @override
  String backupInvalid(String message) {
    return 'Backup kann nicht gelesen werden: $message';
  }

  @override
  String get backupRestored => 'Backup wiederhergestellt';

  @override
  String get backupSaved => 'Backup gespeichert';

  @override
  String get bodyCoupe => 'Coupé';

  @override
  String get bodyHatchback => 'Schrägheck';

  @override
  String get bodyNone => 'Initial';

  @override
  String get bodyPickup => 'Pick-up';

  @override
  String get bodySedan => 'Limousine';

  @override
  String get bodySuv => 'SUV';

  @override
  String get bodyType => 'Karosserie';

  @override
  String get bodyVan => 'Van';

  @override
  String get bodyWagon => 'Kombi';

  @override
  String get byCategory => 'Nach Kategorie';

  @override
  String get byDistance => 'Nach Kilometerstand';

  @override
  String get byTime => 'Nach Zeit';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get changelog => 'Änderungsprotokoll';

  @override
  String get changelogOffline =>
      'GitHub ist nicht erreichbar; Änderungsprotokoll dieser Version wird angezeigt.';

  @override
  String get charges => 'Ladevorgänge';

  @override
  String get chargingStation => 'Ladestation';

  @override
  String get chartEfficiency => 'Verbrauchsverlauf';

  @override
  String get chartEnergyPrice => 'Strompreis-Verlauf';

  @override
  String get chartFuelPrice => 'Kraftstoffpreisverlauf';

  @override
  String get chartMonthlyCosts => 'Kosten pro Monat';

  @override
  String get chartOdometer => 'Kilometerstand';

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get clear => 'Leeren';

  @override
  String get color => 'Farbe';

  @override
  String costPerDistance(String unit) {
    return 'Kosten pro Strecke, $unit';
  }

  @override
  String get createReminder => 'Erinnerung erstellen';

  @override
  String get createReminderHint => 'Ölwechsel, HU, Versicherung…';

  @override
  String get createRestorePoint => 'Jetzt Wiederherstellungspunkt erstellen';

  @override
  String get currency => 'Währung';

  @override
  String get customizeTiles => 'Kacheln anpassen';

  @override
  String get dangerZone => 'Gefahrenbereich';

  @override
  String get data => 'Daten';

  @override
  String get date => 'Datum';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor $count Tag',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get deleteAllData => 'Alle Daten löschen';

  @override
  String get deleteAllDataMessage =>
      'Alle Fahrzeuge, Einträge und Erinnerungen werden von diesem Gerät gelöscht. Falls aktiviert, wird vorher ein Wiederherstellungspunkt erstellt.';

  @override
  String get deleteAllDataTitle => 'Alle Daten löschen?';

  @override
  String get deleteAttachmentTitle => 'Anhang löschen?';

  @override
  String get deleteEntryTitle => 'Diesen Eintrag löschen?';

  @override
  String get deleteItemMessage =>
      'Einträge, die ihn verwenden, behalten ihre Daten, verlieren aber diese Bezeichnung.';

  @override
  String deleteItemTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String deleteReminderTitle(String name) {
    return 'Erinnerung „$name“ löschen?';
  }

  @override
  String deleteVehicleMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Einträge und Erinnerungen werden gelöscht.',
      one: 'Sein $count Eintrag und alle Erinnerungen werden gelöscht.',
      zero: 'Dieses Fahrzeug hat keine Einträge.',
    );
    return '$_temp0';
  }

  @override
  String deleteVehicleTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get dictExpenseCategories => 'Ausgabenkategorien';

  @override
  String get dictFuelStations => 'Tankstellen';

  @override
  String get dictFuelTypes => 'Kraftstoffarten';

  @override
  String get dictServiceStations => 'Werkstätten';

  @override
  String get dictionaries => 'Listen';

  @override
  String get distanceInterval => 'Kilometerintervall';

  @override
  String dueIn(String value) {
    return 'in $value';
  }

  @override
  String get dueToday => 'heute fällig';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get editReminder => 'Erinnerung bearbeiten';

  @override
  String get editTile => 'Kachel';

  @override
  String get editVehicle => 'Fahrzeug bearbeiten';

  @override
  String get efficiencyUnit => 'Verbrauchseinheit';

  @override
  String get energy => 'Energie';

  @override
  String get energyUsed => 'Energieverbrauch';

  @override
  String get entries => 'Einträge';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '$count Eintrag',
      zero: 'keine Einträge',
    );
    return '$_temp0';
  }

  @override
  String entriesCountFiltered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gefunden',
      zero: 'nichts gefunden',
    );
    return '$_temp0';
  }

  @override
  String get entryNotFound => 'Eintrag nicht gefunden';

  @override
  String get entryTypeCharging => 'Laden';

  @override
  String get entryTypeExpense => 'Ausgabe';

  @override
  String get entryTypeFuel => 'Tanken';

  @override
  String get entryTypeOdometer => 'Kilometerstand';

  @override
  String get entryTypeService => 'Wartung';

  @override
  String errorGeneric(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String get every => 'alle';

  @override
  String everyInterval(String value) {
    return 'alle $value';
  }

  @override
  String get expenseCategory => 'Kategorie';

  @override
  String get exportFile => 'Datei exportieren';

  @override
  String get exportSection => 'Export';

  @override
  String get feedback => 'Feedback';

  @override
  String feedbackCopied(String email) {
    return '$email kopiert';
  }

  @override
  String get firstRecord => 'Erster Eintrag';

  @override
  String get fuelCost => 'Kraftstoff';

  @override
  String get fuelStation => 'Tankstelle';

  @override
  String get fuelType => 'Kraftstoffart';

  @override
  String get fuelVolumeTotal => 'Getankte Menge';

  @override
  String get fullBackup => 'Vollständiges Backup';

  @override
  String get fullBackupHint => 'Alles oben plus App-Einstellungen und Anhänge';

  @override
  String get fullCharge => 'Voll geladen';

  @override
  String get fullChargeHint => 'Nötig zur Verbrauchsberechnung';

  @override
  String get fullTank => 'Vollgetankt';

  @override
  String get fullTankHint => 'Nötig zur Verbrauchsberechnung';

  @override
  String get garage => 'Garage';

  @override
  String get general => 'Allgemein';

  @override
  String get history => 'Verlauf';

  @override
  String get homeTiles => 'Startbildschirm-Kacheln';

  @override
  String get homeTilesEmpty =>
      'Keine Kacheln. Der Startbildschirm zeigt nur die Statistik-Schaltfläche.';

  @override
  String get importSection => 'Import';

  @override
  String get initialOdometer => 'Anfangskilometerstand';

  @override
  String get intervalRequired => 'Lege ein Kilometer- oder Zeitintervall fest';

  @override
  String get intervals => 'Intervalle';

  @override
  String get intervalsNeedTwo =>
      'Das Diagramm erscheint nach der zweiten Wartung, die diese Erinnerung zurücksetzt';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get lastDoneHint =>
      'Wurde es schon früher erledigt, wird ab hier statt ab heute gezählt';

  @override
  String get lastDoneOptional => 'Zuletzt erledigt (optional)';

  @override
  String lastValue(String value) {
    return 'Zuletzt: $value';
  }

  @override
  String get later => 'Später';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get manageGarage => 'Garage verwalten';

  @override
  String get merge => 'Zusammenführen';

  @override
  String get mileageRecorded => 'Erfasste Strecke';

  @override
  String nDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '$count Tag',
    );
    return '$_temp0';
  }

  @override
  String nMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Monate',
      one: '$count Monat',
    );
    return '$_temp0';
  }

  @override
  String nWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wochen',
      one: '$count Woche',
    );
    return '$_temp0';
  }

  @override
  String nYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Jahre',
      one: '$count Jahr',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'Neuer Eintrag';

  @override
  String get newReminder => 'Neue Erinnerung';

  @override
  String get newVehicle => 'Neues Fahrzeug';

  @override
  String get no => 'Nein';

  @override
  String get noDataForPeriod => 'Keine Einträge in diesem Zeitraum';

  @override
  String get noEntriesFound => 'Keine Einträge entsprechen dem Filter';

  @override
  String get noEntriesYet =>
      'Noch keine Einträge. Füge deine erste Tankfüllung oder einen Kilometerstand hinzu.';

  @override
  String get noInterval => 'Kein Intervall festgelegt';

  @override
  String get noReminders => 'Noch keine Erinnerungen';

  @override
  String get noServicesForPeriod => 'Keine Wartungen in diesem Zeitraum';

  @override
  String get noVehicles => 'Noch keine Fahrzeuge';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get note => 'Notiz';

  @override
  String notifAttentionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erinnerungen brauchen Aufmerksamkeit',
      one: '$count Erinnerung braucht Aufmerksamkeit',
    );
    return '$_temp0';
  }

  @override
  String get notifChannelName => 'Wartungserinnerungen';

  @override
  String get notifDueToday => 'Heute fällig';

  @override
  String get notifLead => 'Vorab benachrichtigen';

  @override
  String notifLeadDays(String value) {
    return '$value vorher';
  }

  @override
  String get notifLeadNone => 'Nur am Fälligkeitstag';

  @override
  String get notifPermissionDenied =>
      'Benachrichtigungen sind blockiert. Erlaube sie in den System- oder Browsereinstellungen.';

  @override
  String get notifReminders => 'Wartungserinnerungen';

  @override
  String notifTitle(String name, String vehicle) {
    return '$name · $vehicle';
  }

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get odometer => 'Kilometerstand';

  @override
  String odometerTooHigh(String value) {
    return 'Darf $value nicht überschreiten (späterer Eintrag)';
  }

  @override
  String odometerTooLow(String value) {
    return 'Muss mindestens $value sein (früherer Eintrag)';
  }

  @override
  String get openReleasePage => 'Release-Seite öffnen';

  @override
  String get otherCost => 'Sonstige Ausgaben';

  @override
  String overdueBy(String value) {
    return '$value überfällig';
  }

  @override
  String get ownedSince => 'Im Besitz seit';

  @override
  String get period1y => '1 J.';

  @override
  String get period30d => '30 T.';

  @override
  String get period7d => '7 T.';

  @override
  String get periodAllTime => 'Gesamt';

  @override
  String get periodCustom => 'Benutzerdefiniert…';

  @override
  String get periodMonth => 'Letzte 30 Tage';

  @override
  String get periodTotal => 'gesamt';

  @override
  String get periodWeek => 'Letzte 7 Tage';

  @override
  String get periodYear => 'Letztes Jahr';

  @override
  String get predictiveBack => 'Vorausschauende Zurück-Geste';

  @override
  String get presetBelts => 'Keilriemen';

  @override
  String get presetBrakeFluid => 'Bremsflüssigkeit';

  @override
  String get presetCoolant => 'Kühlmittel';

  @override
  String get presetEngineOil => 'Motoröl';

  @override
  String get presetFuelFilter => 'Kraftstofffilter';

  @override
  String get presetPowerSteeringFluid => 'Servolenkungsöl';

  @override
  String get presetSparkPlugs => 'Zündkerzen';

  @override
  String get presetTimingBelt => 'Zahnriemen';

  @override
  String get presetTransmissionFluid => 'Getriebeöl';

  @override
  String get presetValveAdjustment => 'Ventilspiel einstellen';

  @override
  String get presets => 'Vorlagen';

  @override
  String get quickBackup => 'Schnelles Backup';

  @override
  String get quickBackupHint => 'Alle Fahrzeuge und der Verlauf in einer Datei';

  @override
  String get refuels => 'Tankstopps';

  @override
  String get reload => 'Neu laden';

  @override
  String get reminderEditHint =>
      'Die Erinnerung ist fällig, sobald eines der Intervalle abläuft. Markiere einen Wartungseintrag als Zurücksetzung, um neu zu beginnen.';

  @override
  String get reminderHistoryEmpty => 'Noch nicht erledigt';

  @override
  String get reminderHistoryHint =>
      'Wähle diese Erinnerung in einem Wartungseintrag aus, um sie zurückzusetzen';

  @override
  String get reminderName => 'Name';

  @override
  String get reminderNotFound => 'Erinnerung nicht gefunden';

  @override
  String get reminderReset => 'Durch diese Wartung zurückgesetzt';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get remindersToReset => 'Zurückzusetzende Erinnerungen';

  @override
  String get remove => 'Entfernen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get replaceAll => 'Alles ersetzen';

  @override
  String get required => 'Erforderlich';

  @override
  String requiredInterval(String value) {
    return 'Vorgeschrieben: alle $value';
  }

  @override
  String get resetFilter => 'Filter zurücksetzen';

  @override
  String get resetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get restoreBackupTitle => 'Backup wiederherstellen';

  @override
  String get restoreFromBackup => 'Aus Backup wiederherstellen';

  @override
  String get restoreFromFile => 'Aus Datei wiederherstellen';

  @override
  String get restoreFromFileHint =>
      'Öffne eine .garage-Datei von einem anderen Gerät';

  @override
  String get restorePointBeforeDelete => 'Vor dem Löschen';

  @override
  String get restorePointBeforeImport => 'Vor dem Import';

  @override
  String get restorePointCreated => 'Wiederherstellungspunkt erstellt';

  @override
  String get restorePointDaily => 'Täglich';

  @override
  String get restorePointManual => 'Manuell';

  @override
  String get restorePoints => 'Wiederherstellungspunkte';

  @override
  String get restoreReplaceHint =>
      'Die aktuellen Daten werden durch diesen Stand ersetzt.';

  @override
  String get restoreStrategyHint =>
      'Zusammenführen fügt neue Datensätze hinzu und behält bei geänderten die neueste Version. Alles ersetzen löscht zuerst die aktuellen Daten.';

  @override
  String get save => 'Speichern';

  @override
  String get saveToDevice => 'Auf Gerät speichern';

  @override
  String get serviceCost => 'Wartung';

  @override
  String get serviceStation => 'Werkstatt';

  @override
  String get services => 'Wartungen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get share => 'Teilen';

  @override
  String get shareFile => 'Teilen…';

  @override
  String get shareFileHint => 'An Cloud-Speicher, Messenger oder E-Mail senden';

  @override
  String get sincePreviousCharge => 'Seit dem letzten Laden';

  @override
  String get sincePreviousRefuel => 'Seit dem letzten Tanken';

  @override
  String sizeKb(int size) {
    return '$size KB';
  }

  @override
  String get sourceCode => 'Quellcode';

  @override
  String get sourceCodeHint => 'github.com/nuc134r/garage2';

  @override
  String get statCostPerDistance => 'Fahrtkosten';

  @override
  String get statDistance => 'Strecke';

  @override
  String get statEfficiency => 'Verbrauch';

  @override
  String get statEnergy => 'Energie';

  @override
  String get statEnergyPrice => 'Strompreis';

  @override
  String get statExpenses => 'Ausgaben';

  @override
  String get statFuel => 'Kraftstoff';

  @override
  String get statFuelPrice => 'Kraftstoffpreis';

  @override
  String get statFuelVolume => 'Kraftstoffmenge';

  @override
  String get statMileage => 'Fahrleistung';

  @override
  String get statistics => 'Statistik';

  @override
  String statisticsFor(String name) {
    return 'Statistik · $name';
  }

  @override
  String get status => 'Status';

  @override
  String get theme => 'Design';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'System';

  @override
  String get tilePeriod => 'Zeitraum';

  @override
  String get tileValue => 'Kennzahl';

  @override
  String get timeInterval => 'Zeitintervall';

  @override
  String get today => 'Heute';

  @override
  String get totalCost => 'Gesamt';

  @override
  String get trackedPeriod => 'Erfasster Zeitraum';

  @override
  String get unarchive => 'Aus Archiv holen';

  @override
  String get uncategorized => 'Ohne Kategorie';

  @override
  String get unitDays => 'Tage';

  @override
  String get unitGalUk => 'gal (UK)';

  @override
  String get unitGalUs => 'gal (US)';

  @override
  String get unitKm => 'km';

  @override
  String get unitKmPerKwh => 'km/kWh';

  @override
  String get unitKmPerLiter => 'km/L';

  @override
  String get unitKwh => 'kWh';

  @override
  String get unitKwhPer100Km => 'kWh/100 km';

  @override
  String get unitLiter => 'L';

  @override
  String get unitLitersPer100Km => 'L/100 km';

  @override
  String get unitMi => 'mi';

  @override
  String get unitMiPerKwh => 'mi/kWh';

  @override
  String get unitMonths => 'Monate';

  @override
  String get unitMonthsShort => 'Mon.';

  @override
  String get unitMpgUk => 'MPG (UK)';

  @override
  String get unitMpgUs => 'MPG (US)';

  @override
  String get unitPrice => 'Preis';

  @override
  String get unitWeeks => 'Wochen';

  @override
  String get unitYears => 'Jahre';

  @override
  String get unitsAndCurrency => 'Einheiten & Währung';

  @override
  String get upToDate => 'Du hast die neueste Version';

  @override
  String get update => 'Aktualisieren';

  @override
  String updateAvailable(String version) {
    return 'garage $version ist verfügbar';
  }

  @override
  String get updateDownloading => 'Update wird heruntergeladen…';

  @override
  String updateFailed(String error) {
    return 'Update fehlgeschlagen: $error';
  }

  @override
  String get updateInstalling => 'Installationsprogramm wird geöffnet…';

  @override
  String get updatePermission =>
      'Erlaube garage, Apps zu installieren, und versuche es erneut';

  @override
  String updateTo(String version) {
    return 'Auf $version aktualisieren';
  }

  @override
  String get updatesAuto => 'Automatisch nach Updates suchen';

  @override
  String get vehicleName => 'Name';

  @override
  String get vehicleNameHint => 'z. B. Hyundai i30 N';

  @override
  String get vehicles => 'Fahrzeuge';

  @override
  String get volume => 'Menge';

  @override
  String get webUpdateAvailable => 'Eine neue Version von garage ist verfügbar';

  @override
  String get welcomeText =>
      'Erfasse Tanken, Wartung und Ausgaben für all deine Fahrzeuge. Die Daten bleiben auf diesem Gerät; übertrage sie mit einer Backup-Datei.';

  @override
  String get welcomeTitle => 'Willkommen bei garage';

  @override
  String get whatsNew => 'Neuigkeiten';

  @override
  String get yes => 'Ja';

  @override
  String get yesterday => 'Gestern';
}
