import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addFirstVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle'**
  String get addFirstVehicle;

  /// No description provided for @addTile.
  ///
  /// In en, this message translates to:
  /// **'Add tile'**
  String get addTile;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get allDataDeleted;

  /// No description provided for @allReminders.
  ///
  /// In en, this message translates to:
  /// **'All reminders'**
  String get allReminders;

  /// No description provided for @allStats.
  ///
  /// In en, this message translates to:
  /// **'All stats'**
  String get allStats;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'garage'**
  String get appTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @attachChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get attachChooseFile;

  /// No description provided for @attachChooseFileHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, images and other documents'**
  String get attachChooseFileHint;

  /// No description provided for @attachChoosePhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose photos'**
  String get attachChoosePhotos;

  /// No description provided for @attachTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get attachTakePhoto;

  /// No description provided for @attachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'{name} is larger than {max} MB'**
  String attachmentTooLarge(String name, int max);

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @autoRestorePoints.
  ///
  /// In en, this message translates to:
  /// **'Automatic restore points'**
  String get autoRestorePoints;

  /// No description provided for @autoRestorePointsHint.
  ///
  /// In en, this message translates to:
  /// **'Daily and before every import or deletion. The last {count} are kept on this device.'**
  String autoRestorePointsHint(int count);

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get average;

  /// No description provided for @avgDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get avgDaily;

  /// No description provided for @avgDistanceBetweenRefuels.
  ///
  /// In en, this message translates to:
  /// **'Distance between refuels'**
  String get avgDistanceBetweenRefuels;

  /// No description provided for @avgDistanceBetweenServices.
  ///
  /// In en, this message translates to:
  /// **'Distance between services'**
  String get avgDistanceBetweenServices;

  /// No description provided for @avgFuelPrice.
  ///
  /// In en, this message translates to:
  /// **'Average fuel price'**
  String get avgFuelPrice;

  /// No description provided for @avgMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly average'**
  String get avgMonthly;

  /// No description provided for @avgTimeBetweenRefuels.
  ///
  /// In en, this message translates to:
  /// **'Time between refuels'**
  String get avgTimeBetweenRefuels;

  /// No description provided for @avgTimeBetweenServices.
  ///
  /// In en, this message translates to:
  /// **'Time between services'**
  String get avgTimeBetweenServices;

  /// No description provided for @avgYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly average'**
  String get avgYearly;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupAndRestore;

  /// No description provided for @backupContents.
  ///
  /// In en, this message translates to:
  /// **'{vehicles} vehicles, {entries} entries, {reminders} reminders'**
  String backupContents(int entries, int reminders, int vehicles);

  /// No description provided for @backupExportedAt.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String backupExportedAt(String date);

  /// No description provided for @backupHint.
  ///
  /// In en, this message translates to:
  /// **'Move your history between devices'**
  String get backupHint;

  /// No description provided for @backupIncludesSettings.
  ///
  /// In en, this message translates to:
  /// **'Includes app settings'**
  String get backupIncludesSettings;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Cannot read backup: {message}'**
  String backupInvalid(String message);

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @bodyCoupe.
  ///
  /// In en, this message translates to:
  /// **'Coupe'**
  String get bodyCoupe;

  /// No description provided for @bodyHatchback.
  ///
  /// In en, this message translates to:
  /// **'Hatchback'**
  String get bodyHatchback;

  /// No description provided for @bodyNone.
  ///
  /// In en, this message translates to:
  /// **'Initial'**
  String get bodyNone;

  /// No description provided for @bodyPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get bodyPickup;

  /// No description provided for @bodySedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get bodySedan;

  /// No description provided for @bodySuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get bodySuv;

  /// No description provided for @bodyType.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get bodyType;

  /// No description provided for @bodyVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get bodyVan;

  /// No description provided for @bodyWagon.
  ///
  /// In en, this message translates to:
  /// **'Wagon'**
  String get bodyWagon;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @byDistance.
  ///
  /// In en, this message translates to:
  /// **'By mileage'**
  String get byDistance;

  /// No description provided for @byTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get byTime;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chartEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency trend'**
  String get chartEfficiency;

  /// No description provided for @chartFuelPrice.
  ///
  /// In en, this message translates to:
  /// **'Fuel price trend'**
  String get chartFuelPrice;

  /// No description provided for @chartMonthlyCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs by month'**
  String get chartMonthlyCosts;

  /// No description provided for @chartOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get chartOdometer;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @costPerDistance.
  ///
  /// In en, this message translates to:
  /// **'Cost per distance, {unit}'**
  String costPerDistance(String unit);

  /// No description provided for @createReminder.
  ///
  /// In en, this message translates to:
  /// **'Create a reminder'**
  String get createReminder;

  /// No description provided for @createReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Oil change, inspection, insurance…'**
  String get createReminderHint;

  /// No description provided for @createRestorePoint.
  ///
  /// In en, this message translates to:
  /// **'Create restore point now'**
  String get createRestorePoint;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @customizeTiles.
  ///
  /// In en, this message translates to:
  /// **'Customize tiles'**
  String get customizeTiles;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataMessage.
  ///
  /// In en, this message translates to:
  /// **'All vehicles, entries and reminders will be deleted from this device. A restore point is created first if enabled.'**
  String get deleteAllDataMessage;

  /// No description provided for @deleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataTitle;

  /// No description provided for @deleteAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment?'**
  String get deleteAttachmentTitle;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Entries that use it will keep their data but lose this label.'**
  String get deleteItemMessage;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteItemTitle(String name);

  /// No description provided for @deleteReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder “{name}”?'**
  String deleteReminderTitle(String name);

  /// No description provided for @deleteVehicleMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This vehicle has no entries.} one{Its {count} entry and all reminders will be deleted.} other{All its {count} entries and reminders will be deleted.}}'**
  String deleteVehicleMessage(int count);

  /// No description provided for @deleteVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteVehicleTitle(String name);

  /// No description provided for @dictExpenseCategories.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get dictExpenseCategories;

  /// No description provided for @dictFuelStations.
  ///
  /// In en, this message translates to:
  /// **'Fuel stations'**
  String get dictFuelStations;

  /// No description provided for @dictFuelTypes.
  ///
  /// In en, this message translates to:
  /// **'Fuel types'**
  String get dictFuelTypes;

  /// No description provided for @dictServiceStations.
  ///
  /// In en, this message translates to:
  /// **'Service stations'**
  String get dictServiceStations;

  /// No description provided for @dictionaries.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get dictionaries;

  /// No description provided for @dictionariesHint.
  ///
  /// In en, this message translates to:
  /// **'Fuel types, stations, expense categories'**
  String get dictionariesHint;

  /// No description provided for @distanceInterval.
  ///
  /// In en, this message translates to:
  /// **'Mileage interval'**
  String get distanceInterval;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'in {value}'**
  String dueIn(String value);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'due today'**
  String get dueToday;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @editTile.
  ///
  /// In en, this message translates to:
  /// **'Tile'**
  String get editTile;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get editVehicle;

  /// No description provided for @efficiencyUnit.
  ///
  /// In en, this message translates to:
  /// **'Fuel efficiency unit'**
  String get efficiencyUnit;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no entries} one{{count} entry} other{{count} entries}}'**
  String entriesCount(int count);

  /// No description provided for @entriesCountFiltered.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{none found} other{{count} found}}'**
  String entriesCountFiltered(int count);

  /// No description provided for @entryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get entryNotFound;

  /// No description provided for @entryTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get entryTypeExpense;

  /// No description provided for @entryTypeFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get entryTypeFuel;

  /// No description provided for @entryTypeOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get entryTypeOdometer;

  /// No description provided for @entryTypeService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get entryTypeService;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String errorGeneric(String error);

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'every'**
  String get every;

  /// No description provided for @everyInterval.
  ///
  /// In en, this message translates to:
  /// **'every {value}'**
  String everyInterval(String value);

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @exportFile.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get exportFile;

  /// No description provided for @exportSection.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportSection;

  /// No description provided for @firstRecord.
  ///
  /// In en, this message translates to:
  /// **'First record'**
  String get firstRecord;

  /// No description provided for @fuelCost.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelCost;

  /// No description provided for @fuelStation.
  ///
  /// In en, this message translates to:
  /// **'Fuel station'**
  String get fuelStation;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get fuelType;

  /// No description provided for @fuelVolumeTotal.
  ///
  /// In en, this message translates to:
  /// **'Fuel used'**
  String get fuelVolumeTotal;

  /// No description provided for @fullBackup.
  ///
  /// In en, this message translates to:
  /// **'Full backup'**
  String get fullBackup;

  /// No description provided for @fullBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Everything above plus app settings and attachments'**
  String get fullBackupHint;

  /// No description provided for @fullCharge.
  ///
  /// In en, this message translates to:
  /// **'Charged to full'**
  String get fullCharge;

  /// No description provided for @fullChargeHint.
  ///
  /// In en, this message translates to:
  /// **'Needed to calculate consumption'**
  String get fullChargeHint;

  /// No description provided for @fullTank.
  ///
  /// In en, this message translates to:
  /// **'Full tank'**
  String get fullTank;

  /// No description provided for @fullTankHint.
  ///
  /// In en, this message translates to:
  /// **'Needed to calculate fuel efficiency'**
  String get fullTankHint;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @garageHint.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, reorder and archive vehicles'**
  String get garageHint;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @homeTiles.
  ///
  /// In en, this message translates to:
  /// **'Home screen tiles'**
  String get homeTiles;

  /// No description provided for @homeTilesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tiles. The home screen will show only the stats button.'**
  String get homeTilesEmpty;

  /// No description provided for @homeTilesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which stats appear on the home screen'**
  String get homeTilesHint;

  /// No description provided for @importSection.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importSection;

  /// No description provided for @initialOdometer.
  ///
  /// In en, this message translates to:
  /// **'Initial odometer'**
  String get initialOdometer;

  /// No description provided for @intervalRequired.
  ///
  /// In en, this message translates to:
  /// **'Set a mileage or time interval'**
  String get intervalRequired;

  /// No description provided for @intervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get intervals;

  /// No description provided for @intervalsNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'The chart appears after the second service that resets this reminder'**
  String get intervalsNeedTwo;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @lastDoneHint.
  ///
  /// In en, this message translates to:
  /// **'If it was already done before, counting starts from here instead of today'**
  String get lastDoneHint;

  /// No description provided for @lastDoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Last done (optional)'**
  String get lastDoneOptional;

  /// No description provided for @lastValue.
  ///
  /// In en, this message translates to:
  /// **'Last: {value}'**
  String lastValue(String value);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @manageGarage.
  ///
  /// In en, this message translates to:
  /// **'Manage garage'**
  String get manageGarage;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @mileageRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded mileage'**
  String get mileageRecorded;

  /// No description provided for @nDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String nDays(int count);

  /// No description provided for @nMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month} other{{count} months}}'**
  String nMonths(int count);

  /// No description provided for @nWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} week} other{{count} weeks}}'**
  String nWeeks(int count);

  /// No description provided for @nYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year} other{{count} years}}'**
  String nYears(int count);

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @newReminder.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminder;

  /// No description provided for @newVehicle.
  ///
  /// In en, this message translates to:
  /// **'New vehicle'**
  String get newVehicle;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get noDataForPeriod;

  /// No description provided for @noEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No entries match the filter'**
  String get noEntriesFound;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Add your first refuel or odometer reading.'**
  String get noEntriesYet;

  /// No description provided for @noInterval.
  ///
  /// In en, this message translates to:
  /// **'No interval set'**
  String get noInterval;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noReminders;

  /// No description provided for @noServicesForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No services in this period'**
  String get noServicesForPeriod;

  /// No description provided for @noVehicles.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get noVehicles;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @notifAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} reminder needs attention} other{{count} reminders need attention}}'**
  String notifAttentionTitle(int count);

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Maintenance reminders'**
  String get notifChannelName;

  /// No description provided for @notifDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get notifDueToday;

  /// No description provided for @notifLead.
  ///
  /// In en, this message translates to:
  /// **'Notify in advance'**
  String get notifLead;

  /// No description provided for @notifLeadDays.
  ///
  /// In en, this message translates to:
  /// **'{value} before'**
  String notifLeadDays(String value);

  /// No description provided for @notifLeadNone.
  ///
  /// In en, this message translates to:
  /// **'Only on the due day'**
  String get notifLeadNone;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them in system or browser settings.'**
  String get notifPermissionDenied;

  /// No description provided for @notifReminders.
  ///
  /// In en, this message translates to:
  /// **'Maintenance reminders'**
  String get notifReminders;

  /// No description provided for @notifRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Notify before reminders are due, even when the app is closed'**
  String get notifRemindersHint;

  /// No description provided for @notifRemindersHintWeb.
  ///
  /// In en, this message translates to:
  /// **'In the browser, shown when you open the app'**
  String get notifRemindersHintWeb;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {vehicle}'**
  String notifTitle(String name, String vehicle);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @odometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get odometer;

  /// No description provided for @odometerTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Must not exceed {value} (a later entry)'**
  String odometerTooHigh(String value);

  /// No description provided for @odometerTooLow.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {value} (an earlier entry)'**
  String odometerTooLow(String value);

  /// No description provided for @openReleasePage.
  ///
  /// In en, this message translates to:
  /// **'Open release page'**
  String get openReleasePage;

  /// No description provided for @otherCost.
  ///
  /// In en, this message translates to:
  /// **'Other expenses'**
  String get otherCost;

  /// No description provided for @overdueBy.
  ///
  /// In en, this message translates to:
  /// **'overdue by {value}'**
  String overdueBy(String value);

  /// No description provided for @ownedSince.
  ///
  /// In en, this message translates to:
  /// **'Owned since'**
  String get ownedSince;

  /// No description provided for @period1y.
  ///
  /// In en, this message translates to:
  /// **'1y'**
  String get period1y;

  /// No description provided for @period30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get period30d;

  /// No description provided for @period7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get period7d;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get periodCustom;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get periodMonth;

  /// No description provided for @periodTotal.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get periodTotal;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get periodWeek;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get periodYear;

  /// No description provided for @presetBelts.
  ///
  /// In en, this message translates to:
  /// **'Drive belts'**
  String get presetBelts;

  /// No description provided for @presetBrakeFluid.
  ///
  /// In en, this message translates to:
  /// **'Brake fluid'**
  String get presetBrakeFluid;

  /// No description provided for @presetCoolant.
  ///
  /// In en, this message translates to:
  /// **'Coolant'**
  String get presetCoolant;

  /// No description provided for @presetEngineOil.
  ///
  /// In en, this message translates to:
  /// **'Engine oil'**
  String get presetEngineOil;

  /// No description provided for @presetFuelFilter.
  ///
  /// In en, this message translates to:
  /// **'Fuel filter'**
  String get presetFuelFilter;

  /// No description provided for @presetPowerSteeringFluid.
  ///
  /// In en, this message translates to:
  /// **'Power steering fluid'**
  String get presetPowerSteeringFluid;

  /// No description provided for @presetSparkPlugs.
  ///
  /// In en, this message translates to:
  /// **'Spark plugs'**
  String get presetSparkPlugs;

  /// No description provided for @presetTimingBelt.
  ///
  /// In en, this message translates to:
  /// **'Timing belt'**
  String get presetTimingBelt;

  /// No description provided for @presetTransmissionFluid.
  ///
  /// In en, this message translates to:
  /// **'Transmission fluid'**
  String get presetTransmissionFluid;

  /// No description provided for @presetValveAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Valve adjustment'**
  String get presetValveAdjustment;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @quickBackup.
  ///
  /// In en, this message translates to:
  /// **'Quick backup'**
  String get quickBackup;

  /// No description provided for @quickBackupHint.
  ///
  /// In en, this message translates to:
  /// **'All vehicles and history in one file'**
  String get quickBackupHint;

  /// No description provided for @refuels.
  ///
  /// In en, this message translates to:
  /// **'Refuels'**
  String get refuels;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @reminderEditHint.
  ///
  /// In en, this message translates to:
  /// **'The reminder is due when either interval runs out. Mark a service entry as resetting it to start over.'**
  String get reminderEditHint;

  /// No description provided for @reminderHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not done yet'**
  String get reminderHistoryEmpty;

  /// No description provided for @reminderHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select this reminder in a service entry to reset it'**
  String get reminderHistoryHint;

  /// No description provided for @reminderName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reminderName;

  /// No description provided for @reminderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reminder not found'**
  String get reminderNotFound;

  /// No description provided for @reminderReset.
  ///
  /// In en, this message translates to:
  /// **'Reset by this service'**
  String get reminderReset;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersToReset.
  ///
  /// In en, this message translates to:
  /// **'Reminders to reset'**
  String get remindersToReset;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @requiredInterval.
  ///
  /// In en, this message translates to:
  /// **'Required: every {value}'**
  String requiredInterval(String value);

  /// No description provided for @resetFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset filter'**
  String get resetFilter;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackupTitle;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get restoreFromFile;

  /// No description provided for @restoreFromFileHint.
  ///
  /// In en, this message translates to:
  /// **'Open a .garage file from another device'**
  String get restoreFromFileHint;

  /// No description provided for @restorePointBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Before deletion'**
  String get restorePointBeforeDelete;

  /// No description provided for @restorePointBeforeImport.
  ///
  /// In en, this message translates to:
  /// **'Before import'**
  String get restorePointBeforeImport;

  /// No description provided for @restorePointCreated.
  ///
  /// In en, this message translates to:
  /// **'Restore point created'**
  String get restorePointCreated;

  /// No description provided for @restorePointDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get restorePointDaily;

  /// No description provided for @restorePointManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get restorePointManual;

  /// No description provided for @restorePoints.
  ///
  /// In en, this message translates to:
  /// **'Restore points'**
  String get restorePoints;

  /// No description provided for @restoreReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Current data will be replaced with this snapshot.'**
  String get restoreReplaceHint;

  /// No description provided for @restoreStrategyHint.
  ///
  /// In en, this message translates to:
  /// **'Merge adds new records and keeps the newest version of changed ones. Replace all deletes current data first.'**
  String get restoreStrategyHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get saveToDevice;

  /// No description provided for @serviceCost.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceCost;

  /// No description provided for @serviceStation.
  ///
  /// In en, this message translates to:
  /// **'Service station'**
  String get serviceStation;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareFile.
  ///
  /// In en, this message translates to:
  /// **'Share…'**
  String get shareFile;

  /// No description provided for @shareFileHint.
  ///
  /// In en, this message translates to:
  /// **'Send to cloud storage, messenger or email'**
  String get shareFileHint;

  /// No description provided for @sincePrevious.
  ///
  /// In en, this message translates to:
  /// **'Since previous'**
  String get sincePrevious;

  /// No description provided for @sizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String sizeKb(int size);

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @sourceCodeHint.
  ///
  /// In en, this message translates to:
  /// **'github.com/nuc134r/garage2'**
  String get sourceCodeHint;

  /// No description provided for @statCostPerDistance.
  ///
  /// In en, this message translates to:
  /// **'Running cost'**
  String get statCostPerDistance;

  /// No description provided for @statDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statDistance;

  /// No description provided for @statEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get statEfficiency;

  /// No description provided for @statExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get statExpenses;

  /// No description provided for @statFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get statFuel;

  /// No description provided for @statFuelPrice.
  ///
  /// In en, this message translates to:
  /// **'Fuel price'**
  String get statFuelPrice;

  /// No description provided for @statFuelVolume.
  ///
  /// In en, this message translates to:
  /// **'Fuel volume'**
  String get statFuelVolume;

  /// No description provided for @statMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get statMileage;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statisticsFor.
  ///
  /// In en, this message translates to:
  /// **'Statistics · {name}'**
  String statisticsFor(String name);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @tilePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get tilePeriod;

  /// No description provided for @tileValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get tileValue;

  /// No description provided for @timeInterval.
  ///
  /// In en, this message translates to:
  /// **'Time interval'**
  String get timeInterval;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalCost;

  /// No description provided for @trackedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Tracked period'**
  String get trackedPeriod;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Restore from archive'**
  String get unarchive;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @unitGalUk.
  ///
  /// In en, this message translates to:
  /// **'gal (UK)'**
  String get unitGalUk;

  /// No description provided for @unitGalUs.
  ///
  /// In en, this message translates to:
  /// **'gal (US)'**
  String get unitGalUs;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitKmPerKwh.
  ///
  /// In en, this message translates to:
  /// **'km/kWh'**
  String get unitKmPerKwh;

  /// No description provided for @unitKmPerLiter.
  ///
  /// In en, this message translates to:
  /// **'km/L'**
  String get unitKmPerLiter;

  /// No description provided for @unitKwh.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get unitKwh;

  /// No description provided for @unitKwhPer100Km.
  ///
  /// In en, this message translates to:
  /// **'kWh/100 km'**
  String get unitKwhPer100Km;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLiter;

  /// No description provided for @unitLitersPer100Km.
  ///
  /// In en, this message translates to:
  /// **'L/100 km'**
  String get unitLitersPer100Km;

  /// No description provided for @unitMi.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get unitMi;

  /// No description provided for @unitMiPerKwh.
  ///
  /// In en, this message translates to:
  /// **'mi/kWh'**
  String get unitMiPerKwh;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get unitMonths;

  /// No description provided for @unitMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get unitMonthsShort;

  /// No description provided for @unitMpgUk.
  ///
  /// In en, this message translates to:
  /// **'MPG (UK)'**
  String get unitMpgUk;

  /// No description provided for @unitMpgUs.
  ///
  /// In en, this message translates to:
  /// **'MPG (US)'**
  String get unitMpgUs;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get unitPrice;

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get unitWeeks;

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get unitYears;

  /// No description provided for @unitsAndCurrency.
  ///
  /// In en, this message translates to:
  /// **'Units & currency'**
  String get unitsAndCurrency;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version'**
  String get upToDate;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'garage {version} is available'**
  String updateAvailable(String version);

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get updateDownloading;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Opening the installer…'**
  String get updateInstalling;

  /// No description provided for @updatePermission.
  ///
  /// In en, this message translates to:
  /// **'Allow garage to install apps, then try again'**
  String get updatePermission;

  /// No description provided for @updatesAuto.
  ///
  /// In en, this message translates to:
  /// **'Check for updates automatically'**
  String get updatesAuto;

  /// No description provided for @updatesAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Looks for new releases on GitHub when the app starts'**
  String get updatesAutoHint;

  /// No description provided for @vehicleName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vehicleName;

  /// No description provided for @vehicleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hyundai i30 N'**
  String get vehicleNameHint;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @webUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of garage is available'**
  String get webUpdateAvailable;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Track fuel, service and expenses for all your vehicles. Data stays on this device; move it with a backup file.'**
  String get welcomeText;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to garage'**
  String get welcomeTitle;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
