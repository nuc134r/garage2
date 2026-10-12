// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get add => 'Add';

  @override
  String get addFirstVehicle => 'Add your first vehicle';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get allDataDeleted => 'All data deleted';

  @override
  String get allReminders => 'All reminders';

  @override
  String get allStats => 'All stats';

  @override
  String get appTitle => 'Garage';

  @override
  String get appVersion => 'App version';

  @override
  String get appearance => 'Appearance';

  @override
  String get archive => 'Archive';

  @override
  String get archived => 'Archived';

  @override
  String get autoRestorePoints => 'Automatic restore points';

  @override
  String autoRestorePointsHint(int count) {
    return 'Daily and before every import or deletion. The last $count are kept on this device.';
  }

  @override
  String get avgDaily => 'Daily average';

  @override
  String get avgDistanceBetweenRefuels => 'Distance between refuels';

  @override
  String get avgDistanceBetweenServices => 'Distance between services';

  @override
  String get avgFuelPrice => 'Average fuel price';

  @override
  String get avgMonthly => 'Monthly average';

  @override
  String get avgTimeBetweenRefuels => 'Time between refuels';

  @override
  String get avgTimeBetweenServices => 'Time between services';

  @override
  String get avgYearly => 'Yearly average';

  @override
  String get backupAndRestore => 'Backup & restore';

  @override
  String backupContents(int entries, int reminders, int vehicles) {
    return '$vehicles vehicles, $entries entries, $reminders reminders';
  }

  @override
  String backupExportedAt(String date) {
    return 'Created $date';
  }

  @override
  String get backupHint => 'Move your history between devices';

  @override
  String get backupIncludesSettings => 'Includes app settings';

  @override
  String backupInvalid(String message) {
    return 'Cannot read backup: $message';
  }

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get byDistance => 'By mileage';

  @override
  String get byTime => 'By time';

  @override
  String get cancel => 'Cancel';

  @override
  String get color => 'Color';

  @override
  String costPerDistance(String unit) {
    return 'Cost per distance, $unit';
  }

  @override
  String get countingSince => 'Counting since';

  @override
  String get createReminder => 'Create a reminder';

  @override
  String get createReminderHint => 'Oil change, inspection, insurance…';

  @override
  String get createRestorePoint => 'Create restore point now';

  @override
  String get currency => 'Currency';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get data => 'Data';

  @override
  String get date => 'Date';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataMessage =>
      'All vehicles, entries and reminders will be deleted from this device. A restore point is created first if enabled.';

  @override
  String get deleteAllDataTitle => 'Delete all data?';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get deleteItemMessage =>
      'Entries that use it will keep their data but lose this label.';

  @override
  String deleteItemTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String deleteReminderTitle(String name) {
    return 'Delete reminder “$name”?';
  }

  @override
  String deleteVehicleMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All its $count entries and reminders will be deleted.',
      one: 'Its $count entry and all reminders will be deleted.',
      zero: 'This vehicle has no entries.',
    );
    return '$_temp0';
  }

  @override
  String deleteVehicleTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get dictExpenseCategories => 'Expense categories';

  @override
  String get dictFuelStations => 'Fuel stations';

  @override
  String get dictFuelTypes => 'Fuel types';

  @override
  String get dictServiceStations => 'Service stations';

  @override
  String get dictionaries => 'Lists';

  @override
  String get dictionariesHint => 'Fuel types, stations, expense categories';

  @override
  String get distanceInterval => 'Mileage interval';

  @override
  String dueIn(String value) {
    return 'in $value';
  }

  @override
  String get dueToday => 'due today';

  @override
  String get edit => 'Edit';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get efficiencyUnit => 'Fuel efficiency unit';

  @override
  String get entries => 'Entries';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
      zero: 'no entries',
    );
    return '$_temp0';
  }

  @override
  String entriesCountFiltered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count found',
      zero: 'none found',
    );
    return '$_temp0';
  }

  @override
  String get entryNotFound => 'Entry not found';

  @override
  String get entryTypeExpense => 'Expense';

  @override
  String get entryTypeFuel => 'Fuel';

  @override
  String get entryTypeOdometer => 'Odometer';

  @override
  String get entryTypeService => 'Service';

  @override
  String errorGeneric(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get estimatedByMileage => 'Estimated by mileage';

  @override
  String get every => 'every';

  @override
  String everyInterval(String value) {
    return 'every $value';
  }

  @override
  String get expenseCategory => 'Category';

  @override
  String get exportFile => 'Export file';

  @override
  String get exportSection => 'Export';

  @override
  String get firstRecord => 'First record';

  @override
  String get fuelCost => 'Fuel';

  @override
  String get fuelStation => 'Fuel station';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get fuelVolumeTotal => 'Fuel used';

  @override
  String get fullBackup => 'Full backup';

  @override
  String get fullBackupHint => 'Everything above plus app settings';

  @override
  String get fullTank => 'Full tank';

  @override
  String get fullTankHint => 'Needed to calculate fuel efficiency';

  @override
  String get garage => 'Garage';

  @override
  String get garageHint => 'Add, edit, reorder and archive vehicles';

  @override
  String get general => 'General';

  @override
  String get history => 'History';

  @override
  String get importSection => 'Import';

  @override
  String get initialOdometer => 'Initial odometer';

  @override
  String get intervalRequired => 'Set a mileage or time interval';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get lastDone => 'Last done';

  @override
  String lastValue(String value) {
    return 'Last: $value';
  }

  @override
  String get licenses => 'Licenses';

  @override
  String get manageGarage => 'Manage garage';

  @override
  String get merge => 'Merge';

  @override
  String get mileageRecorded => 'Recorded mileage';

  @override
  String nDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String nMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String nWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '$count week',
    );
    return '$_temp0';
  }

  @override
  String nYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'New entry';

  @override
  String get newReminder => 'New reminder';

  @override
  String get newVehicle => 'New vehicle';

  @override
  String get no => 'No';

  @override
  String get noDataForPeriod => 'No entries in this period';

  @override
  String get noEntriesFound => 'No entries match the filter';

  @override
  String get noEntriesYet =>
      'No entries yet. Add your first refuel or odometer reading.';

  @override
  String get noInterval => 'No interval set';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get noVehicles => 'No vehicles yet';

  @override
  String get note => 'Note';

  @override
  String notifAttentionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders need attention',
      one: '$count reminder needs attention',
    );
    return '$_temp0';
  }

  @override
  String get notifChannelName => 'Maintenance reminders';

  @override
  String get notifDueToday => 'Due today';

  @override
  String get notifLead => 'Notify in advance';

  @override
  String notifLeadDays(String value) {
    return '$value before';
  }

  @override
  String get notifLeadNone => 'Only on the due day';

  @override
  String get notifPermissionDenied =>
      'Notifications are blocked. Allow them in system or browser settings.';

  @override
  String get notifReminders => 'Maintenance reminders';

  @override
  String get notifRemindersHint =>
      'Notify before reminders are due, even when the app is closed';

  @override
  String get notifRemindersHintWeb =>
      'In the browser, shown when you open the app';

  @override
  String notifTitle(String name, String vehicle) {
    return '$name · $vehicle';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get odometer => 'Odometer';

  @override
  String odometerTooHigh(String value) {
    return 'Must not exceed $value (a later entry)';
  }

  @override
  String odometerTooLow(String value) {
    return 'Must be at least $value (an earlier entry)';
  }

  @override
  String get otherCost => 'Other expenses';

  @override
  String overdueBy(String value) {
    return 'overdue by $value';
  }

  @override
  String get ownedSince => 'Owned since';

  @override
  String get period30d => '30d';

  @override
  String get periodAllTime => 'All time';

  @override
  String get periodMonth => 'Last 30 days';

  @override
  String get periodTotal => 'total';

  @override
  String get periodWeek => 'Last 7 days';

  @override
  String get periodYear => 'Last year';

  @override
  String get presetBelts => 'Drive belts';

  @override
  String get presetBrakeFluid => 'Brake fluid';

  @override
  String get presetCoolant => 'Coolant';

  @override
  String get presetEngineOil => 'Engine oil';

  @override
  String get presetFuelFilter => 'Fuel filter';

  @override
  String get presetPowerSteeringFluid => 'Power steering fluid';

  @override
  String get presetSparkPlugs => 'Spark plugs';

  @override
  String get presetTimingBelt => 'Timing belt';

  @override
  String get presetTransmissionFluid => 'Transmission fluid';

  @override
  String get presetValveAdjustment => 'Valve adjustment';

  @override
  String get presets => 'Presets';

  @override
  String get quickBackup => 'Quick backup';

  @override
  String get quickBackupHint => 'All vehicles and history in one file';

  @override
  String get refuels => 'Refuels';

  @override
  String get reminderEditHint =>
      'The reminder is due when either interval runs out. Mark a service entry as resetting it to start over.';

  @override
  String get reminderHistoryEmpty => 'Not done yet';

  @override
  String get reminderHistoryHint =>
      'Select this reminder in a service entry to reset it';

  @override
  String get reminderName => 'Name';

  @override
  String get reminderNotFound => 'Reminder not found';

  @override
  String get reminderReset => 'Reset by this service';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersToReset => 'Reminders to reset';

  @override
  String get rename => 'Rename';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get required => 'Required';

  @override
  String get resetFilter => 'Reset filter';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupTitle => 'Restore backup';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get restoreFromFile => 'Restore from file';

  @override
  String get restoreFromFileHint => 'Open a .garage file from another device';

  @override
  String get restorePointBeforeDelete => 'Before deletion';

  @override
  String get restorePointBeforeImport => 'Before import';

  @override
  String get restorePointCreated => 'Restore point created';

  @override
  String get restorePointDaily => 'Daily';

  @override
  String get restorePointManual => 'Manual';

  @override
  String get restorePoints => 'Restore points';

  @override
  String get restoreReplaceHint =>
      'Current data will be replaced with this snapshot.';

  @override
  String get restoreStrategyHint =>
      'Merge adds new records and keeps the newest version of changed ones. Replace all deletes current data first.';

  @override
  String get save => 'Save';

  @override
  String get saveToDevice => 'Save to device';

  @override
  String get serviceCost => 'Service';

  @override
  String get serviceStation => 'Service station';

  @override
  String get services => 'Services';

  @override
  String get settings => 'Settings';

  @override
  String get shareFile => 'Share…';

  @override
  String get shareFileHint => 'Send to cloud storage, messenger or email';

  @override
  String get sincePrevious => 'Since previous';

  @override
  String sizeKb(int size) {
    return '$size KB';
  }

  @override
  String get statEfficiency => 'Efficiency';

  @override
  String get statExpenses => 'Expenses';

  @override
  String get statFuel => 'Fuel';

  @override
  String get statMileage => 'Mileage';

  @override
  String get statistics => 'Statistics';

  @override
  String statisticsFor(String name) {
    return 'Statistics · $name';
  }

  @override
  String get status => 'Status';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get timeInterval => 'Time interval';

  @override
  String get today => 'Today';

  @override
  String get totalCost => 'Total';

  @override
  String get trackedPeriod => 'Tracked period';

  @override
  String get unarchive => 'Restore from archive';

  @override
  String get unitDays => 'days';

  @override
  String get unitGalUk => 'gal (UK)';

  @override
  String get unitGalUs => 'gal (US)';

  @override
  String get unitKm => 'km';

  @override
  String get unitKmPerLiter => 'km/L';

  @override
  String get unitLiter => 'L';

  @override
  String get unitLitersPer100Km => 'L/100 km';

  @override
  String get unitMi => 'mi';

  @override
  String get unitMonths => 'months';

  @override
  String get unitMpgUk => 'MPG (UK)';

  @override
  String get unitMpgUs => 'MPG (US)';

  @override
  String get unitPrice => 'Price';

  @override
  String get unitWeeks => 'weeks';

  @override
  String get unitYears => 'years';

  @override
  String get unitsAndCurrency => 'Units & currency';

  @override
  String get vehicleName => 'Name';

  @override
  String get vehicleNameHint => 'e.g. Hyundai i30 N';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get volume => 'Volume';

  @override
  String get welcomeText =>
      'Track fuel, service and expenses for all your vehicles. Data stays on this device; move it with a backup file.';

  @override
  String get welcomeTitle => 'Welcome to Garage';

  @override
  String get yes => 'Yes';

  @override
  String get yesterday => 'Yesterday';
}
