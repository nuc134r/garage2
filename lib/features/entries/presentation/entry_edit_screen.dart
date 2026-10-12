import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/model/enums.dart';
import '../../../l10n/l10n.dart';
import '../../dictionaries/data/dictionary_repository.dart';
import '../../dictionaries/presentation/dictionaries_screen.dart';
import '../../reminders/data/reminder_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/entry_repository.dart';

final _decimalInput = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

/// Creates or edits an entry of any type.
class EntryEditScreen extends ConsumerStatefulWidget {
  const EntryEditScreen({super.key, required this.vehicleId, this.entryId, this.initialType});

  final String vehicleId;
  final String? entryId;
  final EntryType? initialType;

  @override
  ConsumerState<EntryEditScreen> createState() => _EntryEditScreenState();
}

enum _FuelField { volume, price, total }

class _EntryEditScreenState extends ConsumerState<EntryEditScreen> {
  final _form = GlobalKey<FormState>();
  final _odometer = TextEditingController();
  final _volume = TextEditingController();
  final _price = TextEditingController();
  final _total = TextEditingController();
  final _note = TextEditingController();

  late EntryType _type = widget.initialType ?? EntryType.fuel;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  bool _fullTank = true;
  String? _fuelTypeId;
  String? _fuelStationId;
  String? _serviceStationId;
  String? _categoryId;
  Set<String> _resetReminderIds = {};
  DateTime? _createdAt;
  bool _loaded = false;

  /// The last two fuel fields the user typed into; the third one is computed.
  final List<_FuelField> _fuelEdits = [];

  bool get _isNew => widget.entryId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicle = await ref.read(vehicleRepositoryProvider).get(widget.vehicleId);
    if (vehicle == null) return;
    final fmt = mounted ? VehicleFormat.of(context, vehicle) : null;
    if (_isNew) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    final entry = await ref.read(entryRepositoryProvider).get(widget.entryId!);
    final resets = await ref.read(reminderResetsProvider(widget.vehicleId).future);
    if (entry == null || !mounted || fmt == null) return;
    setState(() {
      _type = entry.type;
      _date = entry.date;
      _createdAt = entry.createdAt;
      _odometer.text = '${entry.odometer}';
      _note.text = entry.note;
      _total.text = entry.totalCost == 0 ? '' : fmt.moneyInput(entry.totalCost);
      _fullTank = entry.fullTank;
      _fuelTypeId = entry.fuelTypeId;
      _categoryId = entry.expenseCategoryId;
      if (entry.type == EntryType.fuel) _fuelStationId = entry.placeId;
      if (entry.type == EntryType.service) _serviceStationId = entry.placeId;
      if (entry.volume != null) {
        _volume.text = formatDecimalInput(entry.volume!);
        if (entry.volume! > 0) _price.text = fmt.moneyInput((entry.totalCost / entry.volume!).round());
      }
      _resetReminderIds = {for (final r in resets) if (r.entryId == entry.id) r.reminderId};
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_odometer, _volume, _price, _total, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFuelEdited(_FuelField field, VehicleFormat fmt) {
    _fuelEdits
      ..remove(field)
      ..add(field);
    if (_fuelEdits.length > 2) _fuelEdits.removeAt(0);
    final volume = parseDecimal(_volume.text);
    final price = parseDecimal(_price.text);
    final total = parseDecimal(_total.text);
    final computed = _fuelEdits.length == 2
        ? _FuelField.values.firstWhere((f) => !_fuelEdits.contains(f))
        : (field == _FuelField.total ? _FuelField.price : _FuelField.total);
    switch (computed) {
      case _FuelField.total when volume != null && price != null:
        _total.text = formatDecimalInput(volume * price, digits: fmt.currencyDigits);
      case _FuelField.price when volume != null && total != null && volume > 0:
        _price.text = formatDecimalInput(total / volume, digits: fmt.currencyDigits);
      case _FuelField.volume when price != null && total != null && price > 0:
        _volume.text = formatDecimalInput(total / price);
      default:
        break;
    }
  }

  /// Odometer bounds from neighbouring entries by date (excluding this one).
  (int? min, int? max) _odometerBounds(List<Entry> entries) {
    int? min, max;
    for (final e in entries) {
      if (e.id == widget.entryId) continue;
      final before = !DateUtils.dateOnly(e.date).isAfter(_date);
      if (before) {
        if (min == null || e.odometer > min) min = e.odometer;
      } else {
        if (max == null || e.odometer < max) max = e.odometer;
      }
    }
    return (min, max);
  }

  Future<void> _save(Vehicle vehicle) async {
    if (!_form.currentState!.validate()) return;
    final fmt = VehicleFormat.of(context, vehicle);
    final isFuel = _type == EntryType.fuel;
    final placeId = switch (_type) {
      EntryType.fuel => _fuelStationId,
      EntryType.service => _serviceStationId,
      _ => null,
    };
    final data = EntriesCompanion(
      id: _isNew ? const Value.absent() : Value(widget.entryId!),
      vehicleId: Value(widget.vehicleId),
      type: Value(_type),
      date: Value(_date),
      odometer: Value(int.parse(_odometer.text)),
      note: Value(_note.text.trim()),
      totalCost: Value(_type == EntryType.odometer ? 0 : (fmt.parseMoney(_total.text) ?? 0)),
      volume: Value(isFuel ? parseDecimal(_volume.text) : null),
      fullTank: Value(isFuel ? _fullTank : true),
      fuelTypeId: Value(isFuel ? _fuelTypeId : null),
      placeId: Value(placeId),
      expenseCategoryId: Value(_type == EntryType.expense ? _categoryId : null),
      createdAt: _createdAt == null ? const Value.absent() : Value(_createdAt!),
    );
    final id = await ref.read(entryRepositoryProvider).save(
          data,
          resetReminderIds: _type == EntryType.service ? _resetReminderIds : {},
        );
    if (!mounted) return;
    HapticFeedback.lightImpact();
    context.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehicleProvider(widget.vehicleId)).value;
    final entries = ref.watch(entriesProvider(widget.vehicleId)).value;
    if (vehicle == null || entries == null || !_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final fmt = VehicleFormat.of(context, vehicle);
    final (minOdo, maxOdo) = _odometerBounds(entries);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.newEntry : l10n.editEntry),
        actions: [TextButton(onPressed: () => _save(vehicle), child: Text(l10n.save))],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SegmentedButton<EntryType>(
              showSelectedIcon: false,
              segments: [
                for (final t in EntryType.values)
                  ButtonSegment(value: t, icon: Icon(t.icon), tooltip: t.label(l10n), label: t == _type ? Text(t.label(l10n)) : null),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.date, prefixIcon: const Icon(Icons.event)),
                      child: Text(fmt.date(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odometer,
                    autofocus: _isNew,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.odometer,
                      suffixText: fmt.distanceUnit,
                      helperText: minOdo == null ? null : l10n.lastValue(fmt.number(minOdo)),
                    ),
                    validator: (v) {
                      final value = int.tryParse(v ?? '');
                      if (value == null) return l10n.required;
                      if (minOdo != null && value < minOdo) return l10n.odometerTooLow(fmt.number(minOdo));
                      if (maxOdo != null && value > maxOdo) return l10n.odometerTooHigh(fmt.number(maxOdo));
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._typeFields(fmt),
            TextFormField(
              controller: _note,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.note, alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => _save(vehicle), child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }

  List<Widget> _typeFields(VehicleFormat fmt) {
    final l10n = context.l10n;
    const gap = SizedBox(height: 20);
    Widget totalField({bool required = true}) => TextFormField(
          controller: _total,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_decimalInput],
          decoration: InputDecoration(labelText: l10n.totalCost, suffixText: fmt.currencySymbol),
          onChanged: _type == EntryType.fuel ? (_) => _onFuelEdited(_FuelField.total, fmt) : null,
          validator: (v) => required && fmt.parseMoney(v ?? '') == null ? l10n.required : null,
        );

    switch (_type) {
      case EntryType.fuel:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _volume,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalInput],
                  decoration: InputDecoration(labelText: l10n.volume, suffixText: fmt.volumeUnit),
                  onChanged: (_) => _onFuelEdited(_FuelField.volume, fmt),
                  validator: (v) => (parseDecimal(v ?? '') ?? 0) <= 0 ? l10n.required : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalInput],
                  decoration: InputDecoration(labelText: l10n.unitPrice, suffixText: '${fmt.currencySymbol}/${fmt.volumeUnit}'),
                  onChanged: (_) => _onFuelEdited(_FuelField.price, fmt),
                ),
              ),
            ],
          ),
          gap,
          totalField(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fullTank),
            subtitle: Text(l10n.fullTankHint),
            value: _fullTank,
            onChanged: (v) => setState(() => _fullTank = v),
          ),
          gap,
          DictionaryChips(
            kind: DictionaryKind.fuelType,
            selectedId: _fuelTypeId,
            onChanged: (id) => setState(() => _fuelTypeId = id),
          ),
          gap,
          DictionaryChips(
            kind: DictionaryKind.fuelStation,
            selectedId: _fuelStationId,
            onChanged: (id) => setState(() => _fuelStationId = id),
          ),
          gap,
        ];
      case EntryType.service:
        final reminders = ref.watch(remindersProvider(widget.vehicleId)).value ?? const [];
        return [
          totalField(required: false),
          gap,
          DictionaryChips(
            kind: DictionaryKind.serviceStation,
            selectedId: _serviceStationId,
            onChanged: (id) => setState(() => _serviceStationId = id),
          ),
          if (reminders.isNotEmpty) ...[
            gap,
            Text(l10n.remindersToReset, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in reminders)
                  FilterChip(
                    label: Text(r.name),
                    selected: _resetReminderIds.contains(r.id),
                    onSelected: (sel) => setState(() => sel ? _resetReminderIds.add(r.id) : _resetReminderIds.remove(r.id)),
                  ),
              ],
            ),
          ],
          gap,
        ];
      case EntryType.expense:
        return [
          totalField(),
          gap,
          DictionaryChips(
            kind: DictionaryKind.expenseCategory,
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          gap,
        ];
      case EntryType.odometer:
        return const [];
    }
  }
}
