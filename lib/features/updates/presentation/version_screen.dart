import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/simple_markdown.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../backup/data/backup_service.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/presentation/settings_screen.dart' show displayVersion;
import '../data/changelog.dart';
import '../data/update_service.dart';
import '../domain/release.dart';
import 'update_ui.dart';

/// Settings → App version: icon and version, the update controls (Android) and the changelog.
class VersionScreen extends ConsumerStatefulWidget {
  const VersionScreen({super.key});

  @override
  ConsumerState<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends ConsumerState<VersionScreen> {
  bool _checking = false;

  /// A newer release found by the manual check.
  Release? _found;

  Future<void> _check() async {
    final l10n = context.l10n;
    setState(() => _checking = true);
    try {
      final release = await ref.read(updateServiceProvider).latest();
      final installed = (await ref.read(appVersionProvider.future)).split('+').first;
      if (!mounted) return;
      if (release == null || compareVersions(release.version, installed) <= 0) {
        showSnack(context, l10n.upToDate);
      } else {
        setState(() => _found = release);
      }
    } catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettingsState({});
    final version = displayVersion(ref.watch(appVersionProvider).value) ?? '…';
    final update = _found ?? ref.watch(availableUpdateProvider).value;
    final changelog = ref.watch(changelogProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appVersion)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/app_icon.png', width: 112, height: 112),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(l10n.appTitle, style: theme.textTheme.headlineSmall)),
          Center(
            child: Text(version, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          if (updatesSupported) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: update != null
                  ? FilledButton.icon(
                      icon: const Icon(Icons.system_update),
                      label: Text(l10n.updateTo(update.version)),
                      onPressed: () => installUpdate(context, ref, update),
                    )
                  : OutlinedButton.icon(
                      icon: _checking
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh),
                      label: Text(l10n.checkForUpdates),
                      onPressed: _checking ? null : _check,
                    ),
            ),
            const SizedBox(height: 8),
            Island(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.update),
                  title: Text(l10n.updatesAuto),
                  value: settings.autoUpdateCheck,
                  onChanged: (v) => ref.read(settingsRepositoryProvider).set(SettingKeys.autoUpdateCheck, '$v'),
                ),
              ],
            ),
          ],
          Island(
            title: l10n.changelog,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: switch (changelog) {
                  AsyncData(:final value) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!value.fromGitHub)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              l10n.changelogOffline,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        SimpleMarkdown(parseMarkdown(value.markdown)),
                      ],
                    ),
                  AsyncError(:final error) => Text(l10n.errorGeneric('$error')),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
