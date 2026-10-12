import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../data/backup_service.dart';
import '../domain/backup_data.dart';
import 'backup_actions.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettingsState({});
    final points = ref.watch(restorePointsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Island(
            title: l10n.exportSection,
            children: [
              ListTile(
                leading: const Icon(Icons.bolt),
                title: Text(l10n.quickBackup),
                subtitle: Text(l10n.quickBackupHint),
                onTap: () => exportBackup(context, ref, BackupMode.quick),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(l10n.fullBackup),
                subtitle: Text(l10n.fullBackupHint),
                onTap: () => exportBackup(context, ref, BackupMode.full),
              ),
            ],
          ),
          Island(
            title: l10n.importSection,
            children: [
              ListTile(
                leading: const Icon(Icons.file_open_outlined),
                title: Text(l10n.restoreFromFile),
                subtitle: Text(l10n.restoreFromFileHint),
                onTap: () => importBackupFromFile(context, ref),
              ),
            ],
          ),
          Island(
            title: l10n.restorePoints,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.history),
                title: Text(l10n.autoRestorePoints),
                subtitle: Text(l10n.autoRestorePointsHint(BackupService.maxRestorePoints)),
                value: settings.restorePointsEnabled,
                onChanged: (v) => ref.read(settingsRepositoryProvider).set(SettingKeys.restorePoints, '$v'),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(l10n.createRestorePoint),
                onTap: () async {
                  await ref.read(backupServiceProvider).createRestorePoint('manual');
                  if (context.mounted) showSnack(context, l10n.restorePointCreated);
                },
              ),
              for (final p in points) _RestorePointTile(point: p),
            ],
          ),
          Island(
            title: l10n.dangerZone,
            children: [
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
                title: Text(l10n.deleteAllData, style: TextStyle(color: scheme.error)),
                onTap: () async {
                  final ok = await confirm(
                    context,
                    title: l10n.deleteAllDataTitle,
                    message: l10n.deleteAllDataMessage,
                    action: l10n.delete,
                    destructive: true,
                  );
                  if (!ok) return;
                  await safetyRestorePoint(ref, 'beforeDelete');
                  await ref.read(backupServiceProvider).deleteAllData();
                  if (context.mounted) showSnack(context, l10n.allDataDeleted);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestorePointTile extends ConsumerWidget {
  const _RestorePointTile({required this.point});

  final RestorePoint point;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reason = switch (point.reason) {
      'daily' => l10n.restorePointDaily,
      'beforeImport' => l10n.restorePointBeforeImport,
      'beforeDelete' => l10n.restorePointBeforeDelete,
      _ => l10n.restorePointManual,
    };
    final sizeKb = (point.data.length / 1024).ceil();
    return ListTile(
      leading: const SizedBox(),
      title: Text(DateFormat.yMMMd(l10n.localeName).add_Hm().format(point.createdAt)),
      subtitle: Text('$reason · ${l10n.sizeKb(sizeKb)}'),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          final service = ref.read(backupServiceProvider);
          switch (action) {
            case 'restore':
              await importBackupData(context, ref, service.readRestorePoint(point), replaceOnly: true);
            case 'export':
              await saveBackupData(context, service.readRestorePoint(point));
            case 'delete':
              await service.deleteRestorePoint(point.id);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'restore', child: Text(l10n.restore)),
          PopupMenuItem(value: 'export', child: Text(l10n.exportFile)),
          PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
        ],
      ),
    );
  }
}
