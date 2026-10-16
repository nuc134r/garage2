// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get add => 'Ajouter';

  @override
  String get addFirstVehicle => 'Ajoutez votre premier véhicule';

  @override
  String get addTile => 'Ajouter une tuile';

  @override
  String get addVehicle => 'Ajouter un véhicule';

  @override
  String get allDataDeleted => 'Toutes les données ont été supprimées';

  @override
  String get allReminders => 'Tous les rappels';

  @override
  String get allStats => 'Toutes les stats';

  @override
  String get appTitle => 'garage';

  @override
  String get appVersion => 'Version de l’app';

  @override
  String get appearance => 'Apparence';

  @override
  String get archive => 'Archiver';

  @override
  String get archived => 'Archivés';

  @override
  String get attach => 'Joindre';

  @override
  String get attachChooseFile => 'Choisir un fichier';

  @override
  String get attachChooseFileHint => 'PDF, images et autres documents';

  @override
  String get attachChoosePhotos => 'Choisir des photos';

  @override
  String get attachTakePhoto => 'Prendre une photo';

  @override
  String attachmentTooLarge(String name, int max) {
    return '$name dépasse $max Mo';
  }

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get autoRestorePoints => 'Points de restauration automatiques';

  @override
  String autoRestorePointsHint(int count) {
    return 'Chaque jour et avant chaque import ou suppression. Les $count derniers sont conservés sur cet appareil.';
  }

  @override
  String get average => 'moy.';

  @override
  String get avgDaily => 'Moyenne par jour';

  @override
  String get avgDistanceBetweenRefuels => 'Distance entre les pleins';

  @override
  String get avgDistanceBetweenServices => 'Distance entre les entretiens';

  @override
  String get avgFuelPrice => 'Prix moyen du carburant';

  @override
  String get avgMonthly => 'Moyenne par mois';

  @override
  String get avgTimeBetweenRefuels => 'Temps entre les pleins';

  @override
  String get avgTimeBetweenServices => 'Temps entre les entretiens';

  @override
  String get avgYearly => 'Moyenne par an';

  @override
  String get backupAndRestore => 'Sauvegarde et restauration';

  @override
  String backupContents(int vehicles, int entries, int reminders) {
    return 'Véhicules : $vehicles, entrées : $entries, rappels : $reminders';
  }

  @override
  String backupExportedAt(String date) {
    return 'Créée le $date';
  }

  @override
  String get backupIncludesSettings => 'Inclut les paramètres de l’app';

  @override
  String backupInvalid(String message) {
    return 'Impossible de lire la sauvegarde : $message';
  }

  @override
  String get backupRestored => 'Sauvegarde restaurée';

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String get bodyCoupe => 'Coupé';

  @override
  String get bodyHatchback => 'Compacte';

  @override
  String get bodyNone => 'Initiale';

  @override
  String get bodyPickup => 'Pick-up';

  @override
  String get bodySedan => 'Berline';

  @override
  String get bodySuv => 'SUV';

  @override
  String get bodyType => 'Carrosserie';

  @override
  String get bodyVan => 'Fourgon';

  @override
  String get bodyWagon => 'Break';

  @override
  String get byCategory => 'Par catégorie';

  @override
  String get byDistance => 'Par kilométrage';

  @override
  String get byTime => 'Par durée';

  @override
  String get cancel => 'Annuler';

  @override
  String get changelog => 'Journal des modifications';

  @override
  String get changelogOffline =>
      'GitHub est inaccessible ; affichage du journal de cette version.';

  @override
  String get chartEfficiency => 'Évolution de la consommation';

  @override
  String get chartFuelPrice => 'Évolution du prix du carburant';

  @override
  String get chartMonthlyCosts => 'Dépenses par mois';

  @override
  String get chartOdometer => 'Compteur';

  @override
  String get checkForUpdates => 'Rechercher des mises à jour';

  @override
  String get clear => 'Effacer';

  @override
  String get color => 'Couleur';

  @override
  String costPerDistance(String unit) {
    return 'Coût par distance, $unit';
  }

  @override
  String get createReminder => 'Créer un rappel';

  @override
  String get createReminderHint => 'Vidange, contrôle technique, assurance…';

  @override
  String get createRestorePoint => 'Créer un point de restauration';

  @override
  String get currency => 'Devise';

  @override
  String get customizeTiles => 'Personnaliser les tuiles';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get data => 'Données';

  @override
  String get date => 'Date';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a $count jour',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAllData => 'Supprimer toutes les données';

  @override
  String get deleteAllDataMessage =>
      'Tous les véhicules, entrées et rappels seront supprimés de cet appareil. Un point de restauration est d’abord créé s’il est activé.';

  @override
  String get deleteAllDataTitle => 'Supprimer toutes les données ?';

  @override
  String get deleteAttachmentTitle => 'Supprimer la pièce jointe ?';

  @override
  String get deleteEntryTitle => 'Supprimer cette entrée ?';

  @override
  String get deleteItemMessage =>
      'Les entrées qui l’utilisent garderont leurs données mais perdront ce libellé.';

  @override
  String deleteItemTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String deleteReminderTitle(String name) {
    return 'Supprimer le rappel « $name » ?';
  }

  @override
  String deleteVehicleMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ses $count entrées et tous ses rappels seront supprimés.',
      one: '$count entrée et tous les rappels de ce véhicule seront supprimés.',
      zero: 'Ce véhicule n’a aucune entrée.',
    );
    return '$_temp0';
  }

  @override
  String deleteVehicleTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get dictExpenseCategories => 'Catégories de dépenses';

  @override
  String get dictFuelStations => 'Stations-service';

  @override
  String get dictFuelTypes => 'Types de carburant';

  @override
  String get dictServiceStations => 'Garages';

  @override
  String get dictionaries => 'Listes';

  @override
  String get distanceInterval => 'Intervalle kilométrique';

  @override
  String dueIn(String value) {
    return 'dans $value';
  }

  @override
  String get dueToday => 'à faire aujourd’hui';

  @override
  String get edit => 'Modifier';

  @override
  String get editEntry => 'Modifier l’entrée';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get editTile => 'Tuile';

  @override
  String get editVehicle => 'Modifier le véhicule';

  @override
  String get efficiencyUnit => 'Unité de consommation';

  @override
  String get energy => 'Énergie';

  @override
  String get entries => 'Entrées';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
      zero: 'aucune entrée',
    );
    return '$_temp0';
  }

  @override
  String entriesCountFiltered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trouvées',
      one: '$count trouvée',
      zero: 'aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get entryNotFound => 'Entrée introuvable';

  @override
  String get entryTypeExpense => 'Dépense';

  @override
  String get entryTypeFuel => 'Carburant';

  @override
  String get entryTypeOdometer => 'Compteur';

  @override
  String get entryTypeService => 'Entretien';

  @override
  String errorGeneric(String error) {
    return 'Une erreur s’est produite : $error';
  }

  @override
  String get every => 'tous les';

  @override
  String everyInterval(String value) {
    return 'tous les $value';
  }

  @override
  String get expenseCategory => 'Catégorie';

  @override
  String get exportFile => 'Exporter le fichier';

  @override
  String get exportSection => 'Exporter';

  @override
  String get feedback => 'Commentaires';

  @override
  String feedbackCopied(String email) {
    return '$email copié';
  }

  @override
  String get firstRecord => 'Premier enregistrement';

  @override
  String get fuelCost => 'Carburant';

  @override
  String get fuelStation => 'Station-service';

  @override
  String get fuelType => 'Type de carburant';

  @override
  String get fuelVolumeTotal => 'Carburant consommé';

  @override
  String get fullBackup => 'Sauvegarde complète';

  @override
  String get fullBackupHint =>
      'Tout ce qui précède, plus les paramètres et les pièces jointes';

  @override
  String get fullCharge => 'Charge complète';

  @override
  String get fullChargeHint => 'Nécessaire pour calculer la consommation';

  @override
  String get fullTank => 'Plein complet';

  @override
  String get fullTankHint => 'Nécessaire pour calculer la consommation';

  @override
  String get garage => 'Garage';

  @override
  String get general => 'Général';

  @override
  String get history => 'Historique';

  @override
  String get homeTiles => 'Tuiles de l’écran d’accueil';

  @override
  String get homeTilesEmpty =>
      'Aucune tuile. L’écran d’accueil n’affichera que le bouton des statistiques.';

  @override
  String get importSection => 'Importer';

  @override
  String get initialOdometer => 'Kilométrage initial';

  @override
  String get intervalRequired =>
      'Définissez un intervalle kilométrique ou de temps';

  @override
  String get intervals => 'Intervalles';

  @override
  String get intervalsNeedTwo =>
      'Le graphique apparaît après le deuxième entretien qui réinitialise ce rappel';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get lastDoneHint =>
      'Si c’était déjà fait, le décompte part de cette date au lieu d’aujourd’hui';

  @override
  String get lastDoneOptional => 'Dernière fois (facultatif)';

  @override
  String lastValue(String value) {
    return 'Dernier : $value';
  }

  @override
  String get later => 'Plus tard';

  @override
  String get licenses => 'Licences';

  @override
  String get manageGarage => 'Gérer le garage';

  @override
  String get merge => 'Fusionner';

  @override
  String get mileageRecorded => 'Kilométrage enregistré';

  @override
  String nDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String nMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '$count mois',
    );
    return '$_temp0';
  }

  @override
  String nWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semaines',
      one: '$count semaine',
    );
    return '$_temp0';
  }

  @override
  String nYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '$count an',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'Nouvelle entrée';

  @override
  String get newReminder => 'Nouveau rappel';

  @override
  String get newVehicle => 'Nouveau véhicule';

  @override
  String get no => 'Non';

  @override
  String get noDataForPeriod => 'Aucune entrée sur cette période';

  @override
  String get noEntriesFound => 'Aucune entrée ne correspond au filtre';

  @override
  String get noEntriesYet =>
      'Aucune entrée pour l’instant. Ajoutez votre premier plein ou relevé de compteur.';

  @override
  String get noInterval => 'Aucun intervalle défini';

  @override
  String get noReminders => 'Aucun rappel pour l’instant';

  @override
  String get noServicesForPeriod => 'Aucun entretien sur cette période';

  @override
  String get noVehicles => 'Aucun véhicule pour l’instant';

  @override
  String get notSet => 'Non défini';

  @override
  String get note => 'Note';

  @override
  String notifAttentionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rappels demandent votre attention',
      one: '$count rappel demande votre attention',
    );
    return '$_temp0';
  }

  @override
  String get notifChannelName => 'Rappels d’entretien';

  @override
  String get notifDueToday => 'À faire aujourd’hui';

  @override
  String get notifLead => 'Prévenir à l’avance';

  @override
  String notifLeadDays(String value) {
    return '$value avant';
  }

  @override
  String get notifLeadNone => 'Uniquement le jour J';

  @override
  String get notifPermissionDenied =>
      'Les notifications sont bloquées. Autorisez-les dans les paramètres du système ou du navigateur.';

  @override
  String get notifReminders => 'Rappels d’entretien';

  @override
  String notifTitle(String name, String vehicle) {
    return '$name · $vehicle';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get odometer => 'Compteur';

  @override
  String odometerTooHigh(String value) {
    return 'Ne doit pas dépasser $value (entrée ultérieure)';
  }

  @override
  String odometerTooLow(String value) {
    return 'Doit être au moins $value (entrée antérieure)';
  }

  @override
  String get openReleasePage => 'Ouvrir la page de la version';

  @override
  String get otherCost => 'Autres dépenses';

  @override
  String overdueBy(String value) {
    return 'en retard de $value';
  }

  @override
  String get ownedSince => 'Possédé depuis';

  @override
  String get period1y => '1 an';

  @override
  String get period30d => '30 j';

  @override
  String get period7d => '7 j';

  @override
  String get periodAllTime => 'Tout';

  @override
  String get periodCustom => 'Personnalisé…';

  @override
  String get periodMonth => '30 derniers jours';

  @override
  String get periodTotal => 'total';

  @override
  String get periodWeek => '7 derniers jours';

  @override
  String get periodYear => 'Dernière année';

  @override
  String get predictiveBack => 'Geste de retour prédictif';

  @override
  String get presetBelts => 'Courroies d’accessoires';

  @override
  String get presetBrakeFluid => 'Liquide de frein';

  @override
  String get presetCoolant => 'Liquide de refroidissement';

  @override
  String get presetEngineOil => 'Huile moteur';

  @override
  String get presetFuelFilter => 'Filtre à carburant';

  @override
  String get presetPowerSteeringFluid => 'Liquide de direction assistée';

  @override
  String get presetSparkPlugs => 'Bougies d’allumage';

  @override
  String get presetTimingBelt => 'Courroie de distribution';

  @override
  String get presetTransmissionFluid => 'Huile de boîte de vitesses';

  @override
  String get presetValveAdjustment => 'Réglage des soupapes';

  @override
  String get presets => 'Modèles';

  @override
  String get quickBackup => 'Sauvegarde rapide';

  @override
  String get quickBackupHint =>
      'Tous les véhicules et l’historique dans un seul fichier';

  @override
  String get refuels => 'Pleins';

  @override
  String get reload => 'Recharger';

  @override
  String get reminderEditHint =>
      'Le rappel arrive à échéance dès que l’un des intervalles est écoulé. Associez-le à une entrée d’entretien pour le réinitialiser.';

  @override
  String get reminderHistoryEmpty => 'Pas encore effectué';

  @override
  String get reminderHistoryHint =>
      'Sélectionnez ce rappel dans une entrée d’entretien pour le réinitialiser';

  @override
  String get reminderName => 'Nom';

  @override
  String get reminderNotFound => 'Rappel introuvable';

  @override
  String get reminderReset => 'Réinitialisé par cet entretien';

  @override
  String get reminders => 'Rappels';

  @override
  String get remindersToReset => 'Rappels à réinitialiser';

  @override
  String get remove => 'Retirer';

  @override
  String get rename => 'Renommer';

  @override
  String get replaceAll => 'Tout remplacer';

  @override
  String get required => 'Obligatoire';

  @override
  String requiredInterval(String value) {
    return 'Requis : tous les $value';
  }

  @override
  String get resetFilter => 'Réinitialiser le filtre';

  @override
  String get resetToDefault => 'Rétablir par défaut';

  @override
  String get restore => 'Restaurer';

  @override
  String get restoreBackupTitle => 'Restaurer la sauvegarde';

  @override
  String get restoreFromBackup => 'Restaurer depuis une sauvegarde';

  @override
  String get restoreFromFile => 'Restaurer depuis un fichier';

  @override
  String get restoreFromFileHint =>
      'Ouvrir un fichier .garage d’un autre appareil';

  @override
  String get restorePointBeforeDelete => 'Avant suppression';

  @override
  String get restorePointBeforeImport => 'Avant import';

  @override
  String get restorePointCreated => 'Point de restauration créé';

  @override
  String get restorePointDaily => 'Quotidien';

  @override
  String get restorePointManual => 'Manuel';

  @override
  String get restorePoints => 'Points de restauration';

  @override
  String get restoreReplaceHint =>
      'Les données actuelles seront remplacées par cet instantané.';

  @override
  String get restoreStrategyHint =>
      'Fusionner ajoute les nouveaux enregistrements et garde la version la plus récente des éléments modifiés. Tout remplacer supprime d’abord les données actuelles.';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveToDevice => 'Enregistrer sur l’appareil';

  @override
  String get serviceCost => 'Entretien';

  @override
  String get serviceStation => 'Garage';

  @override
  String get services => 'Entretiens';

  @override
  String get settings => 'Paramètres';

  @override
  String get share => 'Partager';

  @override
  String get shareFile => 'Partager…';

  @override
  String get shareFileHint =>
      'Envoyer vers un stockage cloud, une messagerie ou par e-mail';

  @override
  String get sincePreviousRefuel => 'Depuis le plein précédent';

  @override
  String sizeKb(int size) {
    return '$size Ko';
  }

  @override
  String get sourceCode => 'Code source';

  @override
  String get sourceCodeHint => 'github.com/nuc134r/garage2';

  @override
  String get statCostPerDistance => 'Coût au km';

  @override
  String get statDistance => 'Distance';

  @override
  String get statEfficiency => 'Consommation';

  @override
  String get statExpenses => 'Dépenses';

  @override
  String get statFuel => 'Carburant';

  @override
  String get statFuelPrice => 'Prix du carburant';

  @override
  String get statFuelVolume => 'Volume de carburant';

  @override
  String get statMileage => 'Kilométrage';

  @override
  String get statistics => 'Statistiques';

  @override
  String statisticsFor(String name) {
    return 'Statistiques · $name';
  }

  @override
  String get status => 'État';

  @override
  String get theme => 'Thème';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get tilePeriod => 'Période';

  @override
  String get tileValue => 'Valeur';

  @override
  String get timeInterval => 'Intervalle de temps';

  @override
  String get today => 'Aujourd’hui';

  @override
  String get totalCost => 'Total';

  @override
  String get trackedPeriod => 'Période suivie';

  @override
  String get unarchive => 'Désarchiver';

  @override
  String get uncategorized => 'Sans catégorie';

  @override
  String get unitDays => 'jours';

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
  String get unitMonths => 'mois';

  @override
  String get unitMonthsShort => 'mois';

  @override
  String get unitMpgUk => 'MPG (UK)';

  @override
  String get unitMpgUs => 'MPG (US)';

  @override
  String get unitPrice => 'Prix';

  @override
  String get unitWeeks => 'semaines';

  @override
  String get unitYears => 'ans';

  @override
  String get unitsAndCurrency => 'Unités et devise';

  @override
  String get upToDate => 'Vous avez la dernière version';

  @override
  String get update => 'Mettre à jour';

  @override
  String updateAvailable(String version) {
    return 'garage $version est disponible';
  }

  @override
  String get updateDownloading => 'Téléchargement de la mise à jour…';

  @override
  String updateFailed(String error) {
    return 'Échec de la mise à jour : $error';
  }

  @override
  String get updateInstalling => 'Ouverture du programme d’installation…';

  @override
  String get updatePermission =>
      'Autorisez garage à installer des applis, puis réessayez';

  @override
  String updateTo(String version) {
    return 'Mettre à jour vers $version';
  }

  @override
  String get updatesAuto => 'Rechercher les mises à jour automatiquement';

  @override
  String get vehicleName => 'Nom';

  @override
  String get vehicleNameHint => 'ex. Hyundai i30 N';

  @override
  String get vehicles => 'Véhicules';

  @override
  String get volume => 'Volume';

  @override
  String get webUpdateAvailable =>
      'Une nouvelle version de garage est disponible';

  @override
  String get welcomeText =>
      'Suivez le carburant, l’entretien et les dépenses de tous vos véhicules. Les données restent sur cet appareil ; transférez-les avec un fichier de sauvegarde.';

  @override
  String get welcomeTitle => 'Bienvenue dans garage';

  @override
  String get whatsNew => 'Nouveautés';

  @override
  String get yes => 'Oui';

  @override
  String get yesterday => 'Hier';
}
