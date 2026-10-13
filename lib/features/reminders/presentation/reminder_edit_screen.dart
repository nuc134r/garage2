import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../l10n/l10n.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_status.dart';

enum _TimeUnit {
  day(1),
  week(7),
  month(30),
  year(365);

  const _TimeUnit(this.days);

  final int days;
}

class ReminderEditScreen extends ConsumerStatefulWidget {
  const ReminderEditScreen({super.key, required this.vehicleId, this.reminderId});

  final String vehicleId;
  final String? reminderId;

  @override
  ConsumerState<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends ConsumerState<ReminderEditScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _distance = TextEditingController();
  final _time = TextEditingController();
  final _lastOdometer = TextEditingController();
  _TimeUnit _unit = _TimeUnit.month;
  DateTime? _lastDate;
  Reminder? _existing;

  bool get _isNew => widget.reminderId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      ref.read(remindersProvider(widget.vehicleId).future).then((list) {
        final r = list.where((r) => r.id == widget.reminderId).firstOrNull;
        if (r == null || !mounted) return;
        setState(() {
          _existing = r;
          _name.text = r.name;
          _distance.text = r.intervalDistance?.toString() ?? '';
          _lastDate = r.lastDoneDate;
          _lastOdometer.text = r.lastDoneOdometer?.toString() ?? '';
          if (r.intervalDays != null) {
            _unit = _TimeUnit.values.reversed.firstWhere((u) => r.intervalDays! % u.days == 0);
            _time.text = '${r.intervalDays! ~/ _unit.days}';
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _distance.dispose();
    _time.dispose();
    _lastOdometer.dispose();
    super.dispose();
  }

  void _applyPreset(ReminderPreset p) {
    setState(() {
      _name.text = reminderPresetName(context.l10n, p.key);
      _distance.text = '${p.distance}';
      _unit = p.months % 12 == 0 ? _TimeUnit.year : _TimeUnit.month;
      _time.text = '${_unit == _TimeUnit.year ? p.months ~/ 12 : p.months}';
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final time = int.tryParse(_time.text);
    final id = await ref.read(reminderRepositoryProvider).save(RemindersCompanion(
          id: _isNew ? const Value.absent() : Value(widget.reminderId!),
          vehicleId: Value(widget.vehicleId),
          name: Value(_name.text.trim()),
          intervalDistance: Value(int.tryParse(_distance.text)),
          intervalDays: Value(time == null || time == 0 ? null : time * _unit.days),
          lastDoneDate: Value(_lastDate),
          lastDoneOdometer: Value(int.tryParse(_lastOdometer.text)),
          createdAt: _existing == null ? const Value.absent() : Value(_existing!.createdAt),
        ));
    if (mounted) context.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehicleProvider(widget.vehicleId)).value;
    final unitLabels = {
      _TimeUnit.day: l10n.unitDays,
      _TimeUnit.week: l10n.unitWeeks,
      _TimeUnit.month: l10n.unitMonths,
      _TimeUnit.year: l10n.unitYears,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.newReminder : l10n.editReminder),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: _isNew,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.reminderName,
                suffixIcon: PopupMenuButton<ReminderPreset>(
                  icon: const Icon(Icons.lightbulb_outline),
                  tooltip: l10n.presets,
                  onSelected: _applyPreset,
                  itemBuilder: (_) => [
                    for (final p in ReminderPreset.all) PopupMenuItem(value: p, child: Text(reminderPresetName(l10n, p.key))),
                  ],
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _distance,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.distanceInterval,
                prefixText: '${l10n.every} ',
                suffixText: vehicle?.distanceUnit.label(l10n),
              ),
              validator: (_) => _distance.text.isEmpty && _time.text.isEmpty ? l10n.intervalRequired : null,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _time,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l10n.timeInterval, prefixText: '${l10n.every} '),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<_TimeUnit>(
                    initialValue: _unit,
                    key: ValueKey(_unit),
                    items: [for (final u in _TimeUnit.values) DropdownMenuItem(value: u, child: Text(unitLabels[u]!))],
                    onChanged: (u) => setState(() => _unit = u!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.reminderEditHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 28),
            Text(l10n.lastDoneOptional, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.lastDoneHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _lastDate ?? DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _lastDate = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.date,
                        prefixIcon: const Icon(Icons.event),
                        suffixIcon: _lastDate == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: l10n.clear,
                                onPressed: () => setState(() => _lastDate = null),
                              ),
                      ),
                      child: Text(
                        _lastDate == null ? l10n.notSet : DateFormat.yMMMd(l10n.localeName).format(_lastDate!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastOdometer,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l10n.odometer, suffixText: vehicle?.distanceUnit.label(l10n)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
