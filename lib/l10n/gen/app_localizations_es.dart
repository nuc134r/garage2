// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get add => 'Añadir';

  @override
  String get addFirstVehicle => 'Añade tu primer vehículo';

  @override
  String get addTile => 'Añadir mosaico';

  @override
  String get addVehicle => 'Añadir vehículo';

  @override
  String get allDataDeleted => 'Se han borrado todos los datos';

  @override
  String get allReminders => 'Todos los recordatorios';

  @override
  String get allStats => 'Todas las estadísticas';

  @override
  String get appTitle => 'garage';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get appearance => 'Apariencia';

  @override
  String get archive => 'Archivar';

  @override
  String get archived => 'Archivados';

  @override
  String get attach => 'Adjuntar';

  @override
  String get attachChooseFile => 'Elegir archivo';

  @override
  String get attachChooseFileHint => 'PDF, imágenes y otros documentos';

  @override
  String get attachChoosePhotos => 'Elegir fotos';

  @override
  String get attachTakePhoto => 'Hacer foto';

  @override
  String attachmentTooLarge(String name, int max) {
    return '$name ocupa más de $max MB';
  }

  @override
  String get attachments => 'Adjuntos';

  @override
  String get autoRestorePoints => 'Puntos de restauración automáticos';

  @override
  String autoRestorePointsHint(int count) {
    return 'A diario y antes de cada importación o borrado. Se guardan los últimos $count en este dispositivo.';
  }

  @override
  String get average => 'media';

  @override
  String get avgDaily => 'Media diaria';

  @override
  String get avgDistanceBetweenRefuels => 'Distancia entre repostajes';

  @override
  String get avgDistanceBetweenServices => 'Distancia entre servicios';

  @override
  String get avgFuelPrice => 'Precio medio del combustible';

  @override
  String get avgMonthly => 'Media mensual';

  @override
  String get avgTimeBetweenRefuels => 'Tiempo entre repostajes';

  @override
  String get avgTimeBetweenServices => 'Tiempo entre servicios';

  @override
  String get avgYearly => 'Media anual';

  @override
  String get backupAndRestore => 'Copia de seguridad';

  @override
  String backupContents(int vehicles, int entries, int reminders) {
    return '$vehicles vehículos, $entries registros, $reminders recordatorios';
  }

  @override
  String backupExportedAt(String date) {
    return 'Creada el $date';
  }

  @override
  String get backupIncludesSettings => 'Incluye los ajustes de la app';

  @override
  String backupInvalid(String message) {
    return 'No se puede leer la copia: $message';
  }

  @override
  String get backupRestored => 'Copia restaurada';

  @override
  String get backupSaved => 'Copia guardada';

  @override
  String get bodyCoupe => 'Cupé';

  @override
  String get bodyHatchback => 'Hatchback';

  @override
  String get bodyNone => 'Inicial';

  @override
  String get bodyPickup => 'Pickup';

  @override
  String get bodySedan => 'Sedán';

  @override
  String get bodySuv => 'SUV';

  @override
  String get bodyType => 'Carrocería';

  @override
  String get bodyVan => 'Furgoneta';

  @override
  String get bodyWagon => 'Familiar';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get byDistance => 'Por kilometraje';

  @override
  String get byTime => 'Por tiempo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get changelog => 'Novedades';

  @override
  String get changelogOffline =>
      'No se puede acceder a GitHub; se muestran las novedades de esta versión.';

  @override
  String get chartEfficiency => 'Evolución del consumo';

  @override
  String get chartFuelPrice => 'Evolución del precio del combustible';

  @override
  String get chartMonthlyCosts => 'Gastos por mes';

  @override
  String get chartOdometer => 'Cuentakilómetros';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get clear => 'Borrar';

  @override
  String get color => 'Color';

  @override
  String costPerDistance(String unit) {
    return 'Coste por distancia, $unit';
  }

  @override
  String get createReminder => 'Crear un recordatorio';

  @override
  String get createReminderHint => 'Cambio de aceite, ITV, seguro…';

  @override
  String get createRestorePoint => 'Crear punto de restauración ahora';

  @override
  String get currency => 'Moneda';

  @override
  String get customizeTiles => 'Personalizar mosaicos';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get data => 'Datos';

  @override
  String get date => 'Fecha';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace $count día',
    );
    return '$_temp0';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAllData => 'Borrar todos los datos';

  @override
  String get deleteAllDataMessage =>
      'Se borrarán de este dispositivo todos los vehículos, registros y recordatorios. Si está activado, antes se crea un punto de restauración.';

  @override
  String get deleteAllDataTitle => '¿Borrar todos los datos?';

  @override
  String get deleteAttachmentTitle => '¿Eliminar el adjunto?';

  @override
  String get deleteEntryTitle => '¿Eliminar este registro?';

  @override
  String get deleteItemMessage =>
      'Los registros que lo usan conservarán sus datos, pero perderán esta etiqueta.';

  @override
  String deleteItemTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String deleteReminderTitle(String name) {
    return '¿Eliminar el recordatorio «$name»?';
  }

  @override
  String deleteVehicleMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminarán sus $count registros y todos los recordatorios.',
      one: 'Se eliminarán su $count registro y todos los recordatorios.',
      zero: 'Este vehículo no tiene registros.',
    );
    return '$_temp0';
  }

  @override
  String deleteVehicleTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get dictExpenseCategories => 'Categorías de gastos';

  @override
  String get dictFuelStations => 'Gasolineras';

  @override
  String get dictFuelTypes => 'Tipos de combustible';

  @override
  String get dictServiceStations => 'Talleres';

  @override
  String get dictionaries => 'Listas';

  @override
  String get distanceInterval => 'Intervalo de kilometraje';

  @override
  String dueIn(String value) {
    return 'en $value';
  }

  @override
  String get dueToday => 'vence hoy';

  @override
  String get edit => 'Editar';

  @override
  String get editEntry => 'Editar registro';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get editTile => 'Mosaico';

  @override
  String get editVehicle => 'Editar vehículo';

  @override
  String get efficiencyUnit => 'Unidad de consumo';

  @override
  String get energy => 'Energía';

  @override
  String get entries => 'Registros';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '$count registro',
      zero: 'sin registros',
    );
    return '$_temp0';
  }

  @override
  String entriesCountFiltered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontrados',
      zero: 'ninguno encontrado',
    );
    return '$_temp0';
  }

  @override
  String get entryNotFound => 'Registro no encontrado';

  @override
  String get entryTypeExpense => 'Gasto';

  @override
  String get entryTypeFuel => 'Combustible';

  @override
  String get entryTypeOdometer => 'Kilometraje';

  @override
  String get entryTypeService => 'Servicio';

  @override
  String errorGeneric(String error) {
    return 'Algo ha fallado: $error';
  }

  @override
  String get every => 'cada';

  @override
  String everyInterval(String value) {
    return 'cada $value';
  }

  @override
  String get expenseCategory => 'Categoría';

  @override
  String get exportFile => 'Exportar archivo';

  @override
  String get exportSection => 'Exportar';

  @override
  String get feedback => 'Comentarios';

  @override
  String feedbackCopied(String email) {
    return '$email copiado';
  }

  @override
  String get firstRecord => 'Primer registro';

  @override
  String get fuelCost => 'Combustible';

  @override
  String get fuelStation => 'Gasolinera';

  @override
  String get fuelType => 'Tipo de combustible';

  @override
  String get fuelVolumeTotal => 'Combustible usado';

  @override
  String get fullBackup => 'Copia completa';

  @override
  String get fullBackupHint =>
      'Todo lo anterior más los ajustes de la app y los adjuntos';

  @override
  String get fullCharge => 'Carga completa';

  @override
  String get fullChargeHint => 'Necesario para calcular el consumo';

  @override
  String get fullTank => 'Depósito lleno';

  @override
  String get fullTankHint => 'Necesario para calcular el consumo';

  @override
  String get garage => 'Garaje';

  @override
  String get general => 'General';

  @override
  String get history => 'Historial';

  @override
  String get homeTiles => 'Mosaicos de inicio';

  @override
  String get homeTilesEmpty =>
      'No hay mosaicos. La pantalla de inicio solo mostrará el botón de estadísticas.';

  @override
  String get importSection => 'Importar';

  @override
  String get initialOdometer => 'Kilometraje inicial';

  @override
  String get intervalRequired =>
      'Indica un intervalo de kilometraje o de tiempo';

  @override
  String get intervals => 'Intervalos';

  @override
  String get intervalsNeedTwo =>
      'El gráfico aparecerá tras el segundo servicio que reinicie este recordatorio';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get lastDoneHint =>
      'Si ya se hizo antes, se empieza a contar desde aquí en lugar de hoy';

  @override
  String get lastDoneOptional => 'Última vez (opcional)';

  @override
  String lastValue(String value) {
    return 'Último: $value';
  }

  @override
  String get later => 'Más tarde';

  @override
  String get licenses => 'Licencias';

  @override
  String get manageGarage => 'Gestionar garaje';

  @override
  String get merge => 'Combinar';

  @override
  String get mileageRecorded => 'Kilometraje registrado';

  @override
  String nDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String nMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '$count mes',
    );
    return '$_temp0';
  }

  @override
  String nWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '$count semana',
    );
    return '$_temp0';
  }

  @override
  String nYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '$count año',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'Nuevo registro';

  @override
  String get newReminder => 'Nuevo recordatorio';

  @override
  String get newVehicle => 'Nuevo vehículo';

  @override
  String get no => 'No';

  @override
  String get noDataForPeriod => 'No hay registros en este periodo';

  @override
  String get noEntriesFound => 'Ningún registro coincide con el filtro';

  @override
  String get noEntriesYet =>
      'Aún no hay registros. Añade tu primer repostaje o lectura del cuentakilómetros.';

  @override
  String get noInterval => 'Sin intervalo';

  @override
  String get noReminders => 'Aún no hay recordatorios';

  @override
  String get noServicesForPeriod => 'No hay servicios en este periodo';

  @override
  String get noVehicles => 'Aún no hay vehículos';

  @override
  String get notSet => 'Sin definir';

  @override
  String get note => 'Nota';

  @override
  String notifAttentionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios requieren atención',
      one: '$count recordatorio requiere atención',
    );
    return '$_temp0';
  }

  @override
  String get notifChannelName => 'Recordatorios de mantenimiento';

  @override
  String get notifDueToday => 'Vence hoy';

  @override
  String get notifLead => 'Avisar con antelación';

  @override
  String notifLeadDays(String value) {
    return '$value antes';
  }

  @override
  String get notifLeadNone => 'Solo el día del vencimiento';

  @override
  String get notifPermissionDenied =>
      'Las notificaciones están bloqueadas. Permítelas en los ajustes del sistema o del navegador.';

  @override
  String get notifReminders => 'Recordatorios de mantenimiento';

  @override
  String notifTitle(String name, String vehicle) {
    return '$name · $vehicle';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get odometer => 'Cuentakilómetros';

  @override
  String odometerTooHigh(String value) {
    return 'No puede superar $value (un registro posterior)';
  }

  @override
  String odometerTooLow(String value) {
    return 'Debe ser al menos $value (un registro anterior)';
  }

  @override
  String get openReleasePage => 'Abrir página de la versión';

  @override
  String get otherCost => 'Otros gastos';

  @override
  String overdueBy(String value) {
    return 'vencido hace $value';
  }

  @override
  String get ownedSince => 'En propiedad desde';

  @override
  String get period1y => '1a';

  @override
  String get period30d => '30d';

  @override
  String get period7d => '7d';

  @override
  String get periodAllTime => 'Todo';

  @override
  String get periodCustom => 'Personalizado…';

  @override
  String get periodMonth => 'Últimos 30 días';

  @override
  String get periodTotal => 'total';

  @override
  String get periodWeek => 'Últimos 7 días';

  @override
  String get periodYear => 'Último año';

  @override
  String get predictiveBack => 'Gesto atrás predictivo';

  @override
  String get presetBelts => 'Correas auxiliares';

  @override
  String get presetBrakeFluid => 'Líquido de frenos';

  @override
  String get presetCoolant => 'Refrigerante';

  @override
  String get presetEngineOil => 'Aceite de motor';

  @override
  String get presetFuelFilter => 'Filtro de combustible';

  @override
  String get presetPowerSteeringFluid => 'Líquido de dirección';

  @override
  String get presetSparkPlugs => 'Bujías';

  @override
  String get presetTimingBelt => 'Correa de distribución';

  @override
  String get presetTransmissionFluid => 'Aceite de transmisión';

  @override
  String get presetValveAdjustment => 'Reglaje de válvulas';

  @override
  String get presets => 'Plantillas';

  @override
  String get quickBackup => 'Copia rápida';

  @override
  String get quickBackupHint =>
      'Todos los vehículos y el historial en un archivo';

  @override
  String get refuels => 'Repostajes';

  @override
  String get reload => 'Recargar';

  @override
  String get reminderEditHint =>
      'El recordatorio vence cuando se agota cualquiera de los intervalos. Marca un servicio como reinicio para volver a empezar.';

  @override
  String get reminderHistoryEmpty => 'Aún no realizado';

  @override
  String get reminderHistoryHint =>
      'Selecciona este recordatorio en un servicio para reiniciarlo';

  @override
  String get reminderName => 'Nombre';

  @override
  String get reminderNotFound => 'Recordatorio no encontrado';

  @override
  String get reminderReset => 'Reiniciado por este servicio';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get remindersToReset => 'Recordatorios a reiniciar';

  @override
  String get remove => 'Quitar';

  @override
  String get rename => 'Renombrar';

  @override
  String get replaceAll => 'Reemplazar todo';

  @override
  String get required => 'Obligatorio';

  @override
  String requiredInterval(String value) {
    return 'Obligatorio: cada $value';
  }

  @override
  String get resetFilter => 'Restablecer filtro';

  @override
  String get resetToDefault => 'Restablecer';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreBackupTitle => 'Restaurar copia';

  @override
  String get restoreFromBackup => 'Restaurar desde copia';

  @override
  String get restoreFromFile => 'Restaurar desde archivo';

  @override
  String get restoreFromFileHint =>
      'Abre un archivo .garage de otro dispositivo';

  @override
  String get restorePointBeforeDelete => 'Antes del borrado';

  @override
  String get restorePointBeforeImport => 'Antes de importar';

  @override
  String get restorePointCreated => 'Punto de restauración creado';

  @override
  String get restorePointDaily => 'Diario';

  @override
  String get restorePointManual => 'Manual';

  @override
  String get restorePoints => 'Puntos de restauración';

  @override
  String get restoreReplaceHint =>
      'Los datos actuales se sustituirán por esta copia.';

  @override
  String get restoreStrategyHint =>
      'Combinar añade los registros nuevos y conserva la versión más reciente de los modificados. Reemplazar todo borra antes los datos actuales.';

  @override
  String get save => 'Guardar';

  @override
  String get saveToDevice => 'Guardar en el dispositivo';

  @override
  String get serviceCost => 'Servicio';

  @override
  String get serviceStation => 'Taller';

  @override
  String get services => 'Servicios';

  @override
  String get settings => 'Ajustes';

  @override
  String get share => 'Compartir';

  @override
  String get shareFile => 'Compartir…';

  @override
  String get shareFileHint => 'Envíala a la nube, a un mensajero o por correo';

  @override
  String get sincePreviousRefuel => 'Desde el repostaje anterior';

  @override
  String sizeKb(int size) {
    return '$size KB';
  }

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get sourceCodeHint => 'github.com/nuc134r/garage2';

  @override
  String get statCostPerDistance => 'Coste por distancia';

  @override
  String get statDistance => 'Distancia';

  @override
  String get statEfficiency => 'Consumo';

  @override
  String get statExpenses => 'Gastos';

  @override
  String get statFuel => 'Combustible';

  @override
  String get statFuelPrice => 'Precio del combustible';

  @override
  String get statFuelVolume => 'Volumen de combustible';

  @override
  String get statMileage => 'Kilometraje';

  @override
  String get statistics => 'Estadísticas';

  @override
  String statisticsFor(String name) {
    return 'Estadísticas · $name';
  }

  @override
  String get status => 'Estado';

  @override
  String get theme => 'Tema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get tilePeriod => 'Periodo';

  @override
  String get tileValue => 'Valor';

  @override
  String get timeInterval => 'Intervalo de tiempo';

  @override
  String get today => 'Hoy';

  @override
  String get totalCost => 'Total';

  @override
  String get trackedPeriod => 'Periodo registrado';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get unitDays => 'días';

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
  String get unitMonths => 'meses';

  @override
  String get unitMonthsShort => 'm';

  @override
  String get unitMpgUk => 'MPG (UK)';

  @override
  String get unitMpgUs => 'MPG (US)';

  @override
  String get unitPrice => 'Precio';

  @override
  String get unitWeeks => 'semanas';

  @override
  String get unitYears => 'años';

  @override
  String get unitsAndCurrency => 'Unidades y moneda';

  @override
  String get upToDate => 'Tienes la última versión';

  @override
  String get update => 'Actualizar';

  @override
  String updateAvailable(String version) {
    return 'garage $version está disponible';
  }

  @override
  String get updateDownloading => 'Descargando actualización…';

  @override
  String updateFailed(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String get updateInstalling => 'Abriendo el instalador…';

  @override
  String get updatePermission =>
      'Permite que garage instale apps y vuelve a intentarlo';

  @override
  String updateTo(String version) {
    return 'Actualizar a $version';
  }

  @override
  String get updatesAuto => 'Buscar actualizaciones automáticamente';

  @override
  String get vehicleName => 'Nombre';

  @override
  String get vehicleNameHint => 'p. ej., Hyundai i30 N';

  @override
  String get vehicles => 'Vehículos';

  @override
  String get volume => 'Volumen';

  @override
  String get webUpdateAvailable => 'Hay una nueva versión de garage disponible';

  @override
  String get welcomeText =>
      'Controla el combustible, el mantenimiento y los gastos de todos tus vehículos. Los datos se quedan en este dispositivo; muévelos con un archivo de copia de seguridad.';

  @override
  String get welcomeTitle => 'Te damos la bienvenida a garage';

  @override
  String get whatsNew => 'Novedades';

  @override
  String get yes => 'Sí';

  @override
  String get yesterday => 'Ayer';
}
