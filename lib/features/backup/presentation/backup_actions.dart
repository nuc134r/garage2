import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../data/backup_service.dart';
import '../domain/backup_data.dart';

const _mimeType = 'application/json';

/// Creates a restore point before a destructive action, when restore points are enabled.
Future<void> safetyRestorePoint(WidgetRef ref, String reason) async {
  final settings = ref.read(appSettingsProvider).value;
  if (settings != null && !settings.restorePointsEnabled) return;
  await ref.read(backupServiceProvider).createRestorePoint(reason);
}

/// Exports all data. Web downloads the file; Android offers share or save-to-device.
Future<void> exportBackup(BuildContext context, WidgetRef ref, BackupMode mode) async {
  final data = await ref.read(backupServiceProvider).export(mode);
  if (!context.mounted) return;
  await saveBackupData(context, data);
}

Future<void> saveBackupData(BuildContext context, BackupData data) async {
  final l10n = context.l10n;
  final bytes = data.encodeBytes();
  try {
    if (kIsWeb) {
      await FilePicker.saveFile(fileName: data.fileName, bytes: bytes, mimeType: _mimeType);
      return;
    }
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.shareFile),
              subtitle: Text(l10n.shareFileHint),
              onTap: () => Navigator.pop(context, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(l10n.saveToDevice),
              subtitle: Text(data.fileName),
              onTap: () => Navigator.pop(context, 'save'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'share') {
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, mimeType: _mimeType, name: data.fileName)],
        fileNameOverrides: [data.fileName],
        subject: data.fileName,
      ));
    } else if (choice == 'save') {
      final uri = await FilePicker.saveFile(fileName: data.fileName, bytes: bytes, mimeType: _mimeType);
      if (uri != null && context.mounted) showSnack(context, l10n.backupSaved);
    }
  } catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric(e.toString()));
  }
}

/// Picks a `.garage` file, shows what is inside and imports it with the chosen strategy.
Future<void> importBackupFromFile(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final BackupData data;
  try {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return;
    data = BackupData.decodeBytes(await file.readAsBytes());
  } on BackupFormatException catch (e) {
    if (context.mounted) showSnack(context, l10n.backupInvalid(e.message));
    return;
  } catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric(e.toString()));
    return;
  }
  if (!context.mounted) return;
  await importBackupData(context, ref, data);
}

Future<void> importBackupData(BuildContext context, WidgetRef ref, BackupData data, {bool replaceOnly = false}) async {
  final l10n = context.l10n;
  final strategy = await showDialog<ImportStrategy>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.restore),
      title: Text(l10n.restoreBackupTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backupExportedAt(DateFormat.yMMMd(l10n.localeName).add_Hm().format(data.exportedAt))),
          const SizedBox(height: 4),
          Text(l10n.backupContents(data.vehicles.length, data.entries.length, data.reminders.length)),
          if (data.mode == BackupMode.full) Text(l10n.backupIncludesSettings),
          const SizedBox(height: 16),
          Text(replaceOnly ? l10n.restoreReplaceHint : l10n.restoreStrategyHint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        if (!replaceOnly)
          TextButton(onPressed: () => Navigator.pop(context, ImportStrategy.replace), child: Text(l10n.replaceAll)),
        FilledButton(
          onPressed: () => Navigator.pop(context, replaceOnly ? ImportStrategy.replace : ImportStrategy.merge),
          child: Text(replaceOnly ? l10n.restore : l10n.merge),
        ),
      ],
    ),
  );
  if (strategy == null) return;
  try {
    await safetyRestorePoint(ref, 'beforeImport');
    await ref.read(backupServiceProvider).import(data, strategy);
    if (context.mounted) showSnack(context, l10n.backupRestored);
  } catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric(e.toString()));
  }
}
