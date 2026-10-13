import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../data/vehicle_repository.dart';

const vehicleColors = [
  0xFF607D8B, 0xFF1E88E5, 0xFF00897B, 0xFF43A047, 0xFFFDD835, //
  0xFFFB8C00, 0xFFE53935, 0xFFD81B60, 0xFF8E24AA, 0xFF5D4037,
];

const commonCurrencies = ['RUB', 'USD', 'EUR', 'GBP', 'GEL', 'KZT', 'UAH', 'BYN', 'AMD', 'AZN', 'TRY', 'PLN', 'CZK', 'CHF', 'CNY', 'JPY', 'INR', 'CAD', 'AUD'];

class VehicleEditScreen extends ConsumerStatefulWidget {
  const VehicleEditScreen({super.key, this.vehicleId});

  final String? vehicleId;

  @override
  ConsumerState<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends ConsumerState<VehicleEditScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _odometer = TextEditingController();
  int _color = vehicleColors.first;
  BodyType? _body = BodyType.sedan;
  DateTime? _purchaseDate;
  DistanceUnit _distance = DistanceUnit.km;
  VolumeUnit _volume = VolumeUnit.liter;
  EfficiencyUnit _efficiency = EfficiencyUnit.litersPer100Km;
  String _currency = 'USD';
  bool _loaded = false;

  bool get _isNew => widget.vehicleId == null;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    if (_isNew) {
      _loaded = true;
      // Guess a sensible currency from the platform locale.
      final guess = NumberFormat.simpleCurrency(locale: Intl.getCurrentLocale()).currencyName;
      if (guess != null && guess.length == 3) _currency = guess;
    } else {
      ref.read(vehicleRepositoryProvider).get(widget.vehicleId!).then((v) {
        if (v == null || !mounted) return;
        setState(() {
          _name.text = v.name;
          _odometer.text = v.initialOdometer == 0 ? '' : '${v.initialOdometer}';
          _color = v.color;
          _body = v.bodyType;
          _purchaseDate = v.purchaseDate;
          _distance = v.distanceUnit;
          _volume = v.volumeUnit;
          _efficiency = v.efficiencyUnit;
          _currency = v.currencyCode;
          _loaded = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _odometer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final data = VehiclesCompanion(
      name: Value(_name.text.trim()),
      color: Value(_color),
      bodyType: Value(_body),
      purchaseDate: Value(_purchaseDate),
      initialOdometer: Value(int.tryParse(_odometer.text) ?? 0),
      distanceUnit: Value(_distance),
      volumeUnit: Value(_volume),
      efficiencyUnit: Value(_efficiency),
      currencyCode: Value(_currency),
    );
    final repo = ref.read(vehicleRepositoryProvider);
    if (_isNew) {
      final id = await repo.create(data);
      if (mounted) context.go(Routes.home(id));
    } else {
      await repo.update(widget.vehicleId!, data);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currencies = {...commonCurrencies, _currency}.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.newVehicle : l10n.editVehicle),
        actions: [TextButton(onPressed: _loaded ? _save : null, child: Text(l10n.save))],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(child: VehicleBadge(name: _name.text, color: _color, bodyType: _body, radius: 52)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    autofocus: _isNew,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l10n.vehicleName, hintText: l10n.vehicleNameHint),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.color, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in vehicleColors)
                        InkResponse(
                          onTap: () => setState(() => _color = c),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(c),
                            child: c == _color ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.bodyType, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final b in BodyType.values)
                        _BodyOption(
                          selected: _body == b,
                          label: b.label(l10n),
                          onTap: () => setState(() => _body = b),
                          child: CarDrawing(
                            body: b,
                            color: Color(_color),
                            width: 64,
                            background: _body == b ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainer,
                          ),
                        ),
                      _BodyOption(
                        selected: _body == null,
                        label: l10n.bodyNone,
                        onTap: () => setState(() => _body = null),
                        child: VehicleBadge(name: _name.text, color: _color, radius: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _odometer,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: l10n.initialOdometer, suffixText: _distance.label(l10n)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _purchaseDate ?? DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => _purchaseDate = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.ownedSince),
                            child: Text(_purchaseDate == null ? '—' : DateFormat.yMMMd(l10n.localeName).format(_purchaseDate!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.unitsAndCurrency, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 12),
                  SegmentedButton<DistanceUnit>(
                    segments: [for (final u in DistanceUnit.values) ButtonSegment(value: u, label: Text(u.label(l10n)))],
                    selected: {_distance},
                    onSelectionChanged: (s) => setState(() {
                      _distance = s.first;
                      if (_distance == DistanceUnit.mi && _efficiency == EfficiencyUnit.litersPer100Km) {
                        _efficiency = EfficiencyUnit.mpgUs;
                        _volume = VolumeUnit.galUs;
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<VolumeUnit>(
                    segments: [for (final u in VolumeUnit.values) ButtonSegment(value: u, label: Text(u.label(l10n)))],
                    selected: {_volume},
                    onSelectionChanged: (s) => setState(() => _volume = s.first),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EfficiencyUnit>(
                    initialValue: _efficiency,
                    decoration: InputDecoration(labelText: l10n.efficiencyUnit),
                    items: [for (final u in EfficiencyUnit.values) DropdownMenuItem(value: u, child: Text(u.label(l10n)))],
                    onChanged: (u) => setState(() => _efficiency = u!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: InputDecoration(labelText: l10n.currency),
                    items: [
                      for (final c in currencies)
                        DropdownMenuItem(
                          value: c,
                          child: Text('$c  ${NumberFormat.simpleCurrency(locale: l10n.localeName, name: c).currencySymbol}'),
                        ),
                    ],
                    onChanged: (c) => setState(() => _currency = c!),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(onPressed: _save, child: Text(l10n.save)),
                ],
              ),
            ),
    );
  }
}

/// A selectable body type tile: the drawing above its name.
class _BodyOption extends StatelessWidget {
  const _BodyOption({required this.selected, required this.label, required this.onTap, required this.child});

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? scheme.secondary : Colors.transparent, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 84,
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30, child: Center(child: child)),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
