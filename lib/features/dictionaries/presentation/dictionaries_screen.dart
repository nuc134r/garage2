import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../data/dictionary_repository.dart';

/// Edit fuel types, stations and expense categories.
class DictionariesScreen extends ConsumerWidget {
  const DictionariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dictionaries)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [for (final kind in DictionaryKind.values) _Section(kind: kind)],
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.kind});

  final DictionaryKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(dictionaryProvider(kind)).value ?? const [];
    final repo = ref.read(dictionaryRepositoryProvider);
    return Island(
      title: kind.label(l10n),
      children: [
        for (final item in items)
          ListTile(
            title: Text(item.name),
            onTap: () async {
              final name = await promptText(context, title: l10n.rename, initial: item.name);
              if (name != null) await repo.rename(kind, item.id, name);
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              tooltip: l10n.delete,
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: l10n.deleteItemTitle(item.name),
                  message: l10n.deleteItemMessage,
                  action: l10n.delete,
                  destructive: true,
                );
                if (ok) await repo.delete(kind, item.id);
              },
            ),
          ),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(l10n.add),
          onTap: () async {
            final name = await promptText(context, title: kind.singular(l10n));
            if (name != null) await repo.add(kind, name);
          },
        ),
      ],
    );
  }
}

/// Single-choice chips over a dictionary with an inline "add" chip.
class DictionaryChips extends ConsumerWidget {
  const DictionaryChips({super.key, required this.kind, required this.selectedId, required this.onChanged, this.title});

  final DictionaryKind kind;

  /// Overrides the kind's name above the chips.
  final String? title;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(dictionaryProvider(kind)).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title ?? kind.singular(l10n), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final item in items)
              ChoiceChip(
                label: Text(item.name),
                selected: item.id == selectedId,
                onSelected: (sel) => onChanged(sel ? item.id : null),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(l10n.add),
              onPressed: () async {
                final name = await promptText(context, title: kind.singular(l10n));
                if (name == null) return;
                onChanged(await ref.read(dictionaryRepositoryProvider).add(kind, name));
              },
            ),
          ],
        ),
      ],
    );
  }
}
