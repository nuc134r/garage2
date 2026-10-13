import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../backup/data/backup_service.dart';
import '../../settings/data/settings_repository.dart';
import '../data/update_service.dart';
import '../domain/release.dart';

/// Home screen card shown when a newer release is out.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(availableUpdateProvider).value;
    if (release == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.system_update, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.updateAvailable(release.version),
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () =>
                        ref.read(settingsRepositoryProvider).set(SettingKeys.dismissedUpdate, release.version),
                    child: Text(l10n.later),
                  ),
                  TextButton(onPressed: () => showReleaseDialog(context, ref, release), child: Text(l10n.whatsNew)),
                  FilledButton(onPressed: () => installUpdate(context, ref, release), child: Text(l10n.update)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings → About: manual check.
Future<void> checkForUpdatesNow(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  try {
    final release = await ref.read(updateServiceProvider).latest();
    final installed = (await ref.read(appVersionProvider.future)).split('+').first;
    if (!context.mounted) return;
    if (release == null || compareVersions(release.version, installed) <= 0) {
      showSnack(context, l10n.upToDate);
    } else {
      await showReleaseDialog(context, ref, release);
    }
  } catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric('$e'));
  }
}

Future<void> showReleaseDialog(BuildContext context, WidgetRef ref, Release release) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.system_update),
      title: Text(l10n.updateAvailable(release.version)),
      content: release.notes.trim().isEmpty
          ? null
          : SingleChildScrollView(child: SelectableText(release.notes.trim())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.later)),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            installUpdate(context, ref, release);
          },
          child: Text(l10n.update),
        ),
      ],
    ),
  );
}

/// Downloads the release APK with a progress dialog and hands it to the system installer.
Future<void> installUpdate(BuildContext context, WidgetRef ref, Release release) async {
  final l10n = context.l10n;
  final Stream<OtaEvent> events;
  try {
    events = await ref.read(updateServiceProvider).install(release);
  } catch (e) {
    if (context.mounted) _failed(context, release, '$e');
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StreamBuilder<OtaEvent>(
      stream: events,
      builder: (context, snapshot) {
        final event = snapshot.data;
        final status = event?.status;
        final done = status != null && status != OtaStatus.DOWNLOADING;
        if (done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (status != OtaStatus.INSTALLING && status != OtaStatus.INSTALLATION_DONE) {
              _failed(
                context,
                release,
                status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR ? l10n.updatePermission : event?.value ?? status.name,
              );
            }
          });
        }
        final percent = double.tryParse(event?.value ?? '');
        return AlertDialog(
          title: Text(status == OtaStatus.INSTALLING ? l10n.updateInstalling : l10n.updateDownloading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: status == OtaStatus.DOWNLOADING && percent != null ? percent / 100 : null),
              const SizedBox(height: 8),
              Text(percent == null ? '' : '${percent.round()}%', textAlign: TextAlign.end),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                OtaUpdate().cancel();
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    ),
  );
}

void _failed(BuildContext context, Release release, String error) {
  final l10n = context.l10n;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(l10n.updateFailed(error)),
    action: release.pageUrl.isEmpty
        ? null
        : SnackBarAction(
            label: l10n.openReleasePage,
            onPressed: () => launchUrl(Uri.parse(release.pageUrl), mode: LaunchMode.externalApplication),
          ),
  ));
}
