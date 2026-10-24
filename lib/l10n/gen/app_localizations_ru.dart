// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get about => 'О приложении';

  @override
  String get add => 'Добавить';

  @override
  String get addFirstVehicle => 'Добавить первый автомобиль';

  @override
  String get addTile => 'Добавить плитку';

  @override
  String get addVehicle => 'Добавить автомобиль';

  @override
  String get allDataDeleted => 'Все данные удалены';

  @override
  String get allReminders => 'Все напоминания';

  @override
  String get allStats => 'Вся статистика';

  @override
  String get appTitle => 'garage';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get appearance => 'Оформление';

  @override
  String get archive => 'В архив';

  @override
  String get archived => 'В архиве';

  @override
  String get attach => 'Прикрепить';

  @override
  String get attachChooseFile => 'Выбрать файл';

  @override
  String get attachChooseFileHint => 'PDF, изображения и другие документы';

  @override
  String get attachChoosePhotos => 'Выбрать фото';

  @override
  String get attachTakePhoto => 'Сделать фото';

  @override
  String attachmentTooLarge(String name, int max) {
    return '$name больше $max МБ';
  }

  @override
  String get attachments => 'Вложения';

  @override
  String get autoRestorePoints => 'Автоматические точки восстановления';

  @override
  String autoRestorePointsHint(int count) {
    return 'Ежедневно и перед каждым импортом или удалением. На устройстве хранятся последние $count.';
  }

  @override
  String get average => 'сред.';

  @override
  String get avgCharge => 'Средняя зарядка';

  @override
  String get avgDaily => 'В среднем за день';

  @override
  String get avgDistanceBetweenCharges => 'Пробег между зарядками';

  @override
  String get avgDistanceBetweenRefuels => 'Пробег между заправками';

  @override
  String get avgDistanceBetweenServices => 'Пробег между обслуживаниями';

  @override
  String get avgEnergyPrice => 'Средняя цена энергии';

  @override
  String get avgFill => 'Средняя заправка';

  @override
  String get avgFuelPrice => 'Средняя цена топлива';

  @override
  String get avgInPeriod => 'в среднем за период';

  @override
  String get avgMonthly => 'В среднем за месяц';

  @override
  String get avgTimeBetweenCharges => 'Время между зарядками';

  @override
  String get avgTimeBetweenRefuels => 'Время между заправками';

  @override
  String get avgTimeBetweenServices => 'Время между обслуживаниями';

  @override
  String get avgWeekly => 'В среднем за неделю';

  @override
  String get avgYearly => 'В среднем за год';

  @override
  String get backupAndRestore => 'Резервное копирование';

  @override
  String backupContents(int vehicles, int entries, int reminders) {
    return 'Автомобилей: $vehicles, записей: $entries, напоминаний: $reminders';
  }

  @override
  String backupExportedAt(String date) {
    return 'Создана $date';
  }

  @override
  String get backupIncludesSettings => 'Включает настройки приложения';

  @override
  String backupInvalid(String message) {
    return 'Не удалось прочитать копию: $message';
  }

  @override
  String get backupRestored => 'Копия восстановлена';

  @override
  String get backupSaved => 'Копия сохранена';

  @override
  String get bestEfficiency => 'Лучший расход';

  @override
  String get bodyCoupe => 'Купе';

  @override
  String get bodyHatchback => 'Хэтчбек';

  @override
  String get bodyNone => 'Буква';

  @override
  String get bodyPickup => 'Пикап';

  @override
  String get bodySedan => 'Седан';

  @override
  String get bodySuv => 'Внедорожник';

  @override
  String get bodyType => 'Кузов';

  @override
  String get bodyVan => 'Фургон';

  @override
  String get bodyWagon => 'Универсал';

  @override
  String get busiestMonth => 'Самый активный месяц';

  @override
  String get byCategory => 'По категориям';

  @override
  String get byDistance => 'По пробегу';

  @override
  String get byTime => 'По времени';

  @override
  String get cancel => 'Отмена';

  @override
  String get cannotArchiveLast =>
      'Должен остаться хотя бы один активный автомобиль: добавьте другой, прежде чем архивировать этот.';

  @override
  String get changelog => 'История изменений';

  @override
  String get changelogOffline =>
      'GitHub недоступен; показана история изменений этой версии.';

  @override
  String get charges => 'Зарядки';

  @override
  String get chargingStation => 'Зарядная станция';

  @override
  String get chargingStations => 'Зарядные станции';

  @override
  String chartByWeekday(String unit) {
    return 'Средний пробег по дням недели, $unit';
  }

  @override
  String chartCostPerDistance(String unit) {
    return 'Стоимость 1 $unit по месяцам';
  }

  @override
  String chartDistanceByMonth(String unit) {
    return 'Пробег по месяцам, $unit';
  }

  @override
  String get chartEfficiency => 'Динамика расхода';

  @override
  String chartEfficiencyByMonth(String unit) {
    return 'Расход по месяцам, $unit';
  }

  @override
  String chartEfficiencyPerCharge(String unit) {
    return 'Расход по зарядкам, $unit';
  }

  @override
  String chartEfficiencyPerFill(String unit) {
    return 'Расход по заправкам, $unit';
  }

  @override
  String get chartEnergyPrice => 'Динамика цены энергии';

  @override
  String get chartFuelPrice => 'Цена топлива';

  @override
  String get chartMonthlyCosts => 'Расходы по месяцам';

  @override
  String get chartOdometer => 'Одометр';

  @override
  String chartPricePaid(String unit) {
    return 'Цена, $unit';
  }

  @override
  String chartServiceByYear(String currency) {
    return 'Обслуживание по годам, $currency';
  }

  @override
  String get chartSpendingVsPrevious => 'Расходы к прошлому периоду';

  @override
  String get cheapestFill => 'Дешевле всего';

  @override
  String get checkForUpdates => 'Проверить обновления';

  @override
  String get clear => 'Очистить';

  @override
  String get color => 'Цвет';

  @override
  String get compareUnitsDiffer =>
      'Полосы сравнивают только автомобили с одинаковыми единицами и валютой.';

  @override
  String get compareVehicles => 'Сравнение автомобилей';

  @override
  String get costOfOwnership => 'Стоимость владения';

  @override
  String costPerDistance(String unit) {
    return 'Стоимость пробега, $unit';
  }

  @override
  String get costPerDistanceHint => 'все расходы ÷ пробег';

  @override
  String get createReminder => 'Создать напоминание';

  @override
  String get createReminderHint => 'Замена масла, техосмотр, страховка…';

  @override
  String get createRestorePoint => 'Создать точку восстановления';

  @override
  String get currency => 'Валюта';

  @override
  String get customizeTiles => 'Настроить плитки';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get data => 'Данные';

  @override
  String get date => 'Дата';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String get dearestFill => 'Дороже всего';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteAllData => 'Удалить все данные';

  @override
  String get deleteAllDataMessage =>
      'Все автомобили, записи и напоминания будут удалены с этого устройства. Если включено, перед этим создаётся точка восстановления.';

  @override
  String get deleteAllDataTitle => 'Удалить все данные?';

  @override
  String get deleteAttachmentTitle => 'Удалить вложение?';

  @override
  String get deleteEntryTitle => 'Удалить запись?';

  @override
  String get deleteItemMessage => 'Записи сохранятся, но потеряют эту метку.';

  @override
  String deleteItemTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String deleteReminderTitle(String name) {
    return 'Удалить напоминание «$name»?';
  }

  @override
  String deleteVehicleMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будут удалены $count записи и все напоминания.',
      many: 'Будут удалены $count записей и все напоминания.',
      few: 'Будут удалены $count записи и все напоминания.',
      one: 'Будет удалена $count запись и все напоминания.',
      zero: 'У автомобиля нет записей.',
    );
    return '$_temp0';
  }

  @override
  String deleteVehicleTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get dictExpenseCategories => 'Категории расходов';

  @override
  String get dictFuelStations => 'АЗС';

  @override
  String get dictFuelTypes => 'Виды топлива';

  @override
  String get dictServiceStations => 'Автосервисы';

  @override
  String get dictionaries => 'Справочники';

  @override
  String get distanceInterval => 'Интервал по пробегу';

  @override
  String dueIn(String value) {
    return 'через $value';
  }

  @override
  String get dueToday => 'сегодня';

  @override
  String get edit => 'Изменить';

  @override
  String get editEntry => 'Изменить запись';

  @override
  String get editReminder => 'Изменить напоминание';

  @override
  String get editTile => 'Плитка';

  @override
  String get editVehicle => 'Изменить автомобиль';

  @override
  String get efficiencyUnit => 'Единица расхода топлива';

  @override
  String get energy => 'Энергия';

  @override
  String get energyUsed => 'Израсходовано энергии';

  @override
  String get entries => 'Записи';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
      zero: 'нет записей',
    );
    return '$_temp0';
  }

  @override
  String entriesCountFiltered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'найдено $count',
      one: 'найдена $count',
      zero: 'ничего не найдено',
    );
    return '$_temp0';
  }

  @override
  String get entryNotFound => 'Запись не найдена';

  @override
  String get entryTypeCharging => 'Зарядка';

  @override
  String get entryTypeExpense => 'Прочее';

  @override
  String get entryTypeFuel => 'Топливо';

  @override
  String get entryTypeOdometer => 'Пробег';

  @override
  String get entryTypeService => 'Сервис';

  @override
  String errorGeneric(String error) {
    return 'Что-то пошло не так: $error';
  }

  @override
  String get every => 'каждые';

  @override
  String everyInterval(String value) {
    return 'каждые $value';
  }

  @override
  String expectedCost(String value) {
    return '~$value, как в прошлый раз';
  }

  @override
  String expectedService(String value, String name) {
    return '~$value на «$name»';
  }

  @override
  String get expenseCategory => 'Категория';

  @override
  String get exportFile => 'Экспорт в файл';

  @override
  String get exportSection => 'Экспорт';

  @override
  String get feedback => 'Обратная связь';

  @override
  String feedbackCopied(String email) {
    return '$email скопирован';
  }

  @override
  String get firstRecord => 'Первая запись';

  @override
  String get fuelCost => 'Топливо';

  @override
  String get fuelStation => 'АЗС';

  @override
  String get fuelType => 'Вид топлива';

  @override
  String get fuelVolumeTotal => 'Заправлено топлива';

  @override
  String get fullBackup => 'Полная копия';

  @override
  String get fullBackupHint =>
      'Всё то же, плюс настройки приложения и вложения';

  @override
  String get fullCharge => 'Заряжен полностью';

  @override
  String get fullChargeHint => 'Нужно для расчёта расхода';

  @override
  String get fullTank => 'Полный бак';

  @override
  String get fullTankHint => 'Нужно для расчёта расхода топлива';

  @override
  String get garage => 'Гараж';

  @override
  String get general => 'Общее';

  @override
  String get history => 'История';

  @override
  String get homeTiles => 'Плитки на главном экране';

  @override
  String get homeTilesEmpty =>
      'Плиток нет. На главном экране останется только кнопка статистики.';

  @override
  String get importSection => 'Импорт';

  @override
  String get initialOdometer => 'Начальный пробег';

  @override
  String insightBestEfficiency(int count) {
    return 'Последний расход — лучший из последних $count.';
  }

  @override
  String insightCheaperStation(String cheaper, String percent, String dearer) {
    return '$cheaper в среднем дешевле $dearer на $percent %.';
  }

  @override
  String insightCostShare(String what, String percent) {
    return '$what — $percent % всех расходов.';
  }

  @override
  String insightSpentLess(String percent) {
    return 'Расходы снизились на $percent % к прошлому периоду.';
  }

  @override
  String insightSpentMore(String percent) {
    return 'Расходы выросли на $percent % к прошлому периоду.';
  }

  @override
  String insightUpcoming(String name, String when) {
    return '$name: $when.';
  }

  @override
  String insightUpcomingCost(String name, String when, String cost) {
    return '$name: $when, в прошлый раз — $cost.';
  }

  @override
  String insightWorstEfficiency(int count) {
    return 'Последний расход — худший из последних $count.';
  }

  @override
  String get intervalRequired => 'Укажите интервал по пробегу или времени';

  @override
  String get intervals => 'Интервалы';

  @override
  String get intervalsNeedTwo =>
      'График появится после второго обслуживания, сбрасывающего это напоминание';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get lastDoneHint =>
      'Если уже делали раньше, отсчёт начнётся отсюда, а не с сегодняшнего дня';

  @override
  String get lastDoneOptional => 'Последний раз (необязательно)';

  @override
  String lastValue(String value) {
    return 'Последний: $value';
  }

  @override
  String get later => 'Позже';

  @override
  String get licenses => 'Лицензии';

  @override
  String get longestGap => 'Самый долгий перерыв между записями';

  @override
  String get manageGarage => 'Управление гаражом';

  @override
  String get merge => 'Объединить';

  @override
  String get mileageRecorded => 'Записанный пробег';

  @override
  String milestone(String odometer, String date) {
    return '$odometer — примерно $date';
  }

  @override
  String get milestoneHint => 'в темпе последних 3 месяцев';

  @override
  String get monthlyCost => 'Расходы в месяц';

  @override
  String nDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String nMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String nWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели',
      many: '$count недель',
      few: '$count недели',
      one: '$count неделю',
    );
    return '$_temp0';
  }

  @override
  String nYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'Новая запись';

  @override
  String get newReminder => 'Новое напоминание';

  @override
  String get newVehicle => 'Новый автомобиль';

  @override
  String get no => 'Нет';

  @override
  String get noDataForPeriod => 'Нет записей за этот период';

  @override
  String get noEntriesFound => 'Нет записей под фильтр';

  @override
  String get noEntriesYet =>
      'Записей пока нет. Добавьте первую заправку или показания одометра.';

  @override
  String get noFuelType => 'Без вида топлива';

  @override
  String get noInterval => 'Интервал не задан';

  @override
  String get noReminders => 'Напоминаний пока нет';

  @override
  String get noServicesForPeriod => 'Нет обслуживания за этот период';

  @override
  String get noStation => 'Без станции';

  @override
  String get noVehicles => 'Автомобилей пока нет';

  @override
  String get notEnoughData => 'Пока мало данных';

  @override
  String get notSet => 'Не задано';

  @override
  String get note => 'Заметка';

  @override
  String notifAttentionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count напоминания требуют внимания',
      many: '$count напоминаний требуют внимания',
      few: '$count напоминания требуют внимания',
      one: '$count напоминание требует внимания',
    );
    return '$_temp0';
  }

  @override
  String get notifByVehicle => 'По автомобилям';

  @override
  String get notifChannelName => 'Напоминания об обслуживании';

  @override
  String get notifDueToday => 'Пора сделать сегодня';

  @override
  String get notifLead => 'Уведомлять заранее';

  @override
  String notifLeadDays(String value) {
    return 'За $value';
  }

  @override
  String notifLeadDefault(String value) {
    return 'По умолчанию: $value';
  }

  @override
  String get notifLeadNone => 'Только в день срока';

  @override
  String get notifLeadUseDefault => 'Как для всех автомобилей';

  @override
  String get notifPermissionDenied =>
      'Уведомления заблокированы. Разрешите их в настройках системы или браузера.';

  @override
  String get notifReminders => 'Напоминания об обслуживании';

  @override
  String notifTitle(String name, String vehicle) {
    return '$name · $vehicle';
  }

  @override
  String get notifVehicleOff => 'Выключены';

  @override
  String get notifications => 'Уведомления';

  @override
  String get odometer => 'Пробег';

  @override
  String odometerEstimate(String value) {
    return '≈ $value';
  }

  @override
  String odometerTooHigh(String value) {
    return 'Не больше $value (более поздняя запись)';
  }

  @override
  String odometerTooLow(String value) {
    return 'Не меньше $value (более ранняя запись)';
  }

  @override
  String get openReleasePage => 'Открыть страницу релиза';

  @override
  String get otherCost => 'Прочие расходы';

  @override
  String get otherServices => 'Прочее обслуживание';

  @override
  String get outlook => 'Прогноз';

  @override
  String overdueBy(String value) {
    return 'просрочено на $value';
  }

  @override
  String get ownedSince => 'Во владении с';

  @override
  String get partialCharges => 'Неполные зарядки';

  @override
  String get partialFills => 'Неполные заправки';

  @override
  String perDistanceUnit(String unit) {
    return 'За $unit';
  }

  @override
  String perMonthValue(String value) {
    return '$value в месяц';
  }

  @override
  String get period1y => 'год';

  @override
  String get period30d => '30 дн.';

  @override
  String get period6m => '6 мес';

  @override
  String get period7d => '7 дн.';

  @override
  String get periodAllTime => 'Всё время';

  @override
  String get periodCustom => 'Свой период…';

  @override
  String get periodHalfYear => '6 месяцев';

  @override
  String get periodMonth => '30 дней';

  @override
  String get periodTotal => 'всего';

  @override
  String get periodWeek => '7 дней';

  @override
  String get periodYear => '12 месяцев';

  @override
  String get predictiveBack => 'Предиктивный жест «назад»';

  @override
  String get presetBelts => 'Приводные ремни';

  @override
  String get presetBrakeFluid => 'Тормозная жидкость';

  @override
  String get presetCoolant => 'Охлаждающая жидкость';

  @override
  String get presetEngineOil => 'Моторное масло';

  @override
  String get presetFuelFilter => 'Топливный фильтр';

  @override
  String get presetPowerSteeringFluid => 'Жидкость ГУР';

  @override
  String get presetSparkPlugs => 'Свечи зажигания';

  @override
  String get presetTimingBelt => 'Ремень ГРМ';

  @override
  String get presetTransmissionFluid => 'Трансмиссионное масло';

  @override
  String get presetValveAdjustment => 'Регулировка клапанов';

  @override
  String get presets => 'Шаблоны';

  @override
  String get previousPeriod => 'Прошлый';

  @override
  String get priceAverage => 'средняя';

  @override
  String get priceRange => 'мин. – макс.';

  @override
  String projectedYear(String value, String year) {
    return '~$value за $year';
  }

  @override
  String get projectedYearHint => 'в нынешнем темпе';

  @override
  String get quickBackup => 'Быстрая копия';

  @override
  String get quickBackupHint => 'Все автомобили и история в одном файле';

  @override
  String get rangePerCharge => 'Пробег на полном заряде';

  @override
  String get rangePerTank => 'Пробег на полном баке';

  @override
  String get refuels => 'Заправок';

  @override
  String get reload => 'Перезагрузить';

  @override
  String get reminderEditHint =>
      'Напоминание срабатывает по первому истёкшему интервалу. Отметьте его в записи о сервисе, чтобы начать отсчёт заново.';

  @override
  String get reminderHistoryEmpty => 'Ещё не выполнялось';

  @override
  String get reminderHistoryHint =>
      'Выберите это напоминание в записи о сервисе, чтобы сбросить его';

  @override
  String get reminderName => 'Название';

  @override
  String get reminderNotFound => 'Напоминание не найдено';

  @override
  String get reminderReset => 'Сброшено этим обслуживанием';

  @override
  String get reminders => 'Напоминания';

  @override
  String get remindersToReset => 'Сбросить напоминания';

  @override
  String get remove => 'Убрать';

  @override
  String get rename => 'Переименовать';

  @override
  String get replaceAll => 'Заменить всё';

  @override
  String get required => 'Обязательное поле';

  @override
  String requiredInterval(String value) {
    return 'Норма: каждые $value';
  }

  @override
  String get resetFilter => 'Сбросить фильтр';

  @override
  String get resetToDefault => 'Сбросить';

  @override
  String get restore => 'Восстановить';

  @override
  String get restoreBackupTitle => 'Восстановление копии';

  @override
  String get restoreFromBackup => 'Восстановить из копии';

  @override
  String get restoreFromFile => 'Восстановить из файла';

  @override
  String get restoreFromFileHint => 'Открыть файл .garage с другого устройства';

  @override
  String get restorePointBeforeDelete => 'Перед удалением';

  @override
  String get restorePointBeforeImport => 'Перед импортом';

  @override
  String get restorePointCreated => 'Точка восстановления создана';

  @override
  String get restorePointDaily => 'Ежедневная';

  @override
  String get restorePointManual => 'Вручную';

  @override
  String get restorePoints => 'Точки восстановления';

  @override
  String get restoreReplaceHint =>
      'Текущие данные будут заменены этим снимком.';

  @override
  String get restoreStrategyHint =>
      '«Объединить» добавит новые записи и сохранит самые свежие версии изменённых. «Заменить всё» сначала удалит текущие данные.';

  @override
  String get runningTotalHint => 'нарастающим итогом с начала периода';

  @override
  String get save => 'Сохранить';

  @override
  String get saveToDevice => 'Сохранить на устройство';

  @override
  String get serviceCost => 'Обслуживание';

  @override
  String get serviceStation => 'Автосервис';

  @override
  String get serviceTimeline => 'Хронология';

  @override
  String get services => 'Обслуживаний';

  @override
  String get settings => 'Настройки';

  @override
  String get share => 'Поделиться';

  @override
  String get shareFile => 'Поделиться…';

  @override
  String get shareFileHint => 'Отправить в облако, мессенджер или почту';

  @override
  String get sincePreviousCharge => 'С прошлой зарядки';

  @override
  String get sincePreviousRefuel => 'С предыдущей заправки';

  @override
  String sizeKb(int size) {
    return '$size КБ';
  }

  @override
  String get sourceCode => 'Исходный код';

  @override
  String get sourceCodeHint => 'github.com/nuc134r/garage2';

  @override
  String get statCostPerDistance => 'Цена пробега';

  @override
  String get statDistance => 'Проехано';

  @override
  String get statEfficiency => 'Расход';

  @override
  String get statEnergy => 'Энергия';

  @override
  String get statEnergyPrice => 'Цена энергии';

  @override
  String get statExpenses => 'Расходы';

  @override
  String get statFuel => 'Топливо';

  @override
  String get statFuelPrice => 'Цена топлива';

  @override
  String get statFuelVolume => 'Объём топлива';

  @override
  String get statMileage => 'Пробег';

  @override
  String get statistics => 'Статистика';

  @override
  String statisticsFor(String name) {
    return 'Статистика · $name';
  }

  @override
  String get statsTabCosts => 'Расходы';

  @override
  String get statsTabDriving => 'Поездки';

  @override
  String get status => 'Состояние';

  @override
  String get theme => 'Тема';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get thisPeriod => 'Этот период';

  @override
  String get tilePeriod => 'Период';

  @override
  String get tileValue => 'Показатель';

  @override
  String get timeInterval => 'Интервал по времени';

  @override
  String get today => 'Сегодня';

  @override
  String get totalCost => 'Сумма';

  @override
  String get trackedPeriod => 'Период учёта';

  @override
  String get trendLine => 'тренд';

  @override
  String get tryDemoData => 'Попробовать на демо-данных';

  @override
  String get unarchive => 'Вернуть из архива';

  @override
  String get uncategorized => 'Без категории';

  @override
  String get unitDays => 'дней';

  @override
  String get unitGalUk => 'гал (UK)';

  @override
  String get unitGalUs => 'гал (US)';

  @override
  String get unitKm => 'км';

  @override
  String get unitKmPerKwh => 'км/кВт·ч';

  @override
  String get unitKmPerLiter => 'км/л';

  @override
  String get unitKwh => 'кВт·ч';

  @override
  String get unitKwhPer100Km => 'кВт·ч/100 км';

  @override
  String get unitLiter => 'л';

  @override
  String get unitLitersPer100Km => 'л/100 км';

  @override
  String get unitMi => 'миль';

  @override
  String get unitMiPerKwh => 'миль/кВт·ч';

  @override
  String get unitMonths => 'месяцев';

  @override
  String get unitMonthsShort => 'мес.';

  @override
  String get unitMpgUk => 'MPG (UK)';

  @override
  String get unitMpgUs => 'MPG (US)';

  @override
  String get unitPrice => 'Цена';

  @override
  String get unitWeeks => 'недель';

  @override
  String get unitYears => 'лет';

  @override
  String get unitsAndCurrency => 'Единицы и валюта';

  @override
  String get upToDate => 'Установлена последняя версия';

  @override
  String get update => 'Обновить';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия garage $version';
  }

  @override
  String get updateDownloading => 'Загрузка обновления…';

  @override
  String updateFailed(String error) {
    return 'Не удалось обновить: $error';
  }

  @override
  String get updateInstalling => 'Открываем установщик…';

  @override
  String get updatePermission =>
      'Разрешите garage устанавливать приложения и попробуйте снова';

  @override
  String updateTo(String version) {
    return 'Обновить до $version';
  }

  @override
  String get updatesAuto => 'Проверять обновления автоматически';

  @override
  String get useOdometerEstimate =>
      'Подставить расчётный пробег по среднему дневному пробегу';

  @override
  String vehicleDueSoonCount(int count) {
    return 'скоро: $count';
  }

  @override
  String get vehicleName => 'Название';

  @override
  String get vehicleNameHint => 'например, Hyundai i30 N';

  @override
  String vehicleOverdueCount(int count) {
    return 'просрочено: $count';
  }

  @override
  String get vehicles => 'Автомобили';

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count визита',
      many: '$count визитов',
      few: '$count визита',
      one: '$count визит',
    );
    return '$_temp0';
  }

  @override
  String get volume => 'Объём';

  @override
  String get vsPrevious => 'к прошлому периоду';

  @override
  String vsYear(String year) {
    return 'к $year';
  }

  @override
  String get webUpdateAvailable => 'Доступна новая версия garage';

  @override
  String get welcomeText =>
      'Учёт топлива, обслуживания и расходов для всех ваших автомобилей. Данные хранятся на устройстве и переносятся файлом резервной копии.';

  @override
  String get welcomeTitle => 'Добро пожаловать в garage';

  @override
  String get whatsNew => 'Что нового';

  @override
  String get whatsNext => 'Что дальше';

  @override
  String get whereMoneyGoes => 'Куда уходят деньги';

  @override
  String get worstEfficiency => 'Худший расход';

  @override
  String get yes => 'Да';

  @override
  String get yesterday => 'Вчера';
}
