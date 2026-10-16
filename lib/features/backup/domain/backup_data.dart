import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

enum BackupMode { quick, full }

enum ImportStrategy { merge, replace }

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// The portable `.garage` file: plain UTF-8 JSON, identical on Android and web.
class BackupData {
  const BackupData({
    required this.mode,
    required this.exportedAt,
    this.appVersion,
    this.vehicles = const [],
    this.entries = const [],
    this.reminders = const [],
    this.reminderResets = const [],
    this.fuelTypes = const [],
    this.places = const [],
    this.expenseCategories = const [],
    this.settings = const {},
    this.attachments = const [],
    this.attachmentsIncluded = false,
    this.tombstones = const [],
  });

  static const format = 'garage-backup';
  static const schema = 1;
  static const fileExtension = 'garage';

  static const _serializer = ValueSerializer.defaults(serializeDateTimeValuesAsString: true);

  final BackupMode mode;
  final DateTime exportedAt;
  final String? appVersion;
  final List<Vehicle> vehicles;
  final List<Entry> entries;
  final List<Reminder> reminders;
  final List<ReminderReset> reminderResets;
  final List<FuelType> fuelTypes;
  final List<Place> places;
  final List<ExpenseCategory> expenseCategories;

  /// Only present in full backups.
  final Map<String, String> settings;

  /// Entry attachments with base64 content; only present in full backups.
  final List<Attachment> attachments;

  /// Whether the file carries attachments at all. Restoring a file without them keeps the existing ones.
  final bool attachmentsIncluded;

  /// Rows deleted on the exporting device; a merge deletes them unless edited since.
  final List<Tombstone> tombstones;

  String get fileName {
    String two(int v) => v.toString().padLeft(2, '0');
    final d = exportedAt;
    return 'garage-${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}.$fileExtension';
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> rows(List<DataClass> list) => [for (final r in list) r.toJson(serializer: _serializer)];
    return {
      'format': format,
      'schema': schema,
      'mode': mode.name,
      'app': appVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'vehicles': rows(vehicles),
      'entries': rows(entries),
      'reminders': rows(reminders),
      'reminderResets': rows(reminderResets),
      'fuelTypes': rows(fuelTypes),
      'places': rows(places),
      'expenseCategories': rows(expenseCategories),
      'deleted': rows(tombstones),
      if (mode == BackupMode.full) 'settings': settings,
      if (attachmentsIncluded) 'attachments': [for (final a in attachments) _attachmentToJson(a)],
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) throw const BackupFormatException('Not a garage backup file');
    final fileSchema = json['schema'];
    if (fileSchema is! int || fileSchema > schema) {
      throw BackupFormatException('Unsupported backup version: $fileSchema');
    }
    List<T> rows<T>(String key, T Function(Map<String, dynamic>, {ValueSerializer? serializer}) parse) => [
          for (final r in (json[key] as List? ?? const []).cast<Map<String, dynamic>>()) parse(r, serializer: _serializer),
        ];
    return BackupData(
      mode: BackupMode.values.asNameMap()[json['mode']] ?? BackupMode.quick,
      exportedAt: DateTime.tryParse(json['exportedAt'] as String? ?? '')?.toLocal() ?? clock.now(),
      appVersion: json['app'] as String?,
      vehicles: rows('vehicles', Vehicle.fromJson),
      entries: rows('entries', Entry.fromJson),
      reminders: rows('reminders', Reminder.fromJson),
      reminderResets: rows('reminderResets', ReminderReset.fromJson),
      fuelTypes: rows('fuelTypes', FuelType.fromJson),
      places: rows('places', Place.fromJson),
      expenseCategories: rows('expenseCategories', ExpenseCategory.fromJson),
      tombstones: rows('deleted', Tombstone.fromJson),
      settings: (json['settings'] as Map?)?.cast<String, String>() ?? const {},
      attachments: [
        for (final a in (json['attachments'] as List? ?? const []).cast<Map<String, dynamic>>()) _attachmentFromJson(a),
      ],
      attachmentsIncluded: json['attachments'] is List,
    );
  }

  // Drift would write blobs as a list of numbers; base64 is ~3x smaller.
  static Map<String, dynamic> _attachmentToJson(Attachment a) =>
      a.copyWith(data: Uint8List(0)).toJson(serializer: _serializer)..['data'] = base64Encode(a.data);

  static Attachment _attachmentFromJson(Map<String, dynamic> json) {
    final Uint8List data;
    try {
      data = base64Decode(json['data'] as String? ?? '');
    } on FormatException {
      throw const BackupFormatException('Broken attachment content');
    }
    return Attachment.fromJson({...json, 'data': <int>[]}, serializer: _serializer).copyWith(data: data, size: data.length);
  }

  String encode({bool pretty = false}) =>
      pretty ? const JsonEncoder.withIndent(' ').convert(toJson()) : jsonEncode(toJson());

  Uint8List encodeBytes() => utf8.encode(encode(pretty: true));

  static BackupData decode(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      throw const BackupFormatException('File is not valid JSON');
    }
    if (json is! Map<String, dynamic>) throw const BackupFormatException('Not a garage backup file');
    return BackupData.fromJson(json);
  }

  static BackupData decodeBytes(List<int> bytes) => decode(utf8.decode(bytes, allowMalformed: true));
}
