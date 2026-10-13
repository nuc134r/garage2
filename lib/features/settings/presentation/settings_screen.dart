import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../backup/data/backup_service.dart';
import '../../backup/domain/backup_data.dart';
import '../../backup/domain/sample_data.dart';
import '../../reminders/data/reminder_notifications.dart';
import '../../updates/data/update_service.dart';
import '../../updates/presentation/update_ui.dart';
import '../data/settings_repository.dart';

final repositoryUrl = Uri.parse('https://github.com/nuc134r/garage2');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettingsState({});
    final repo = ref.read(settingsRepositoryProvider);

    final themeLabels = {
      ThemeMode.system: l10n.themeSystem,
      ThemeMode.light: l10n.themeLight,
      ThemeMode.dark: l10n.themeDark,
    };
    final languageLabels = {'': l10n.languageSystem, 'en': 'English', 'ru': 'Русский'};
    final currentLanguage = settings.locale?.languageCode ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Island(
            title: l10n.appearance,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.theme),
                subtitle: Text(themeLabels[settings.themeMode]!),
                onTap: () async {
                  final mode = await _choose(context, l10n.theme, themeLabels, settings.themeMode);
                  if (mode != null) await repo.set(SettingKeys.themeMode, mode.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(languageLabels[currentLanguage] ?? currentLanguage),
                onTap: () async {
                  final code = await _choose(context, l10n.language, languageLabels, currentLanguage);
                  if (code != null) await repo.set(SettingKeys.locale, code.isEmpty ? null : code);
                },
              ),
            ],
          ),
          Island(
            title: l10n.notifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.notifReminders),
                subtitle: Text(kIsWeb ? l10n.notifRemindersHintWeb : l10n.notifRemindersHint),
                value: settings.notificationsEnabled,
                onChanged: (on) async {
                  if (on && !await ref.read(reminderNotificationsProvider).requestPermission()) {
                    if (context.mounted) showSnack(context, l10n.notifPermissionDenied);
                    return;
                  }
                  await repo.set(SettingKeys.notifications, '$on');
                },
              ),
              ListTile(
                enabled: settings.notificationsEnabled,
                leading: const Icon(Icons.schedule),
                title: Text(l10n.notifLead),
                subtitle: Text(_leadLabel(l10n, settings.notifyLeadDays)),
                onTap: () async {
                  final days = await _choose(
                    context,
                    l10n.notifLead,
                    {for (final d in const [0, 3, 7, 14, 30]) d: _leadLabel(l10n, d)},
                    settings.notifyLeadDays,
                  );
                  if (days != null) await repo.set(SettingKeys.notifyLeadDays, '$days');
                },
              ),
            ],
          ),
          Island(
            title: l10n.data,
            children: [
              ListTile(
                leading: const Icon(Icons.garage_outlined),
                title: Text(l10n.garage),
                subtitle: Text(l10n.garageHint),
                onTap: () => context.push(Routes.garage),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined),
                title: Text(l10n.homeTiles),
                subtitle: Text(l10n.homeTilesHint),
                onTap: () => context.push(Routes.homeTiles),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: Text(l10n.dictionaries),
                subtitle: Text(l10n.dictionariesHint),
                onTap: () => context.push(Routes.dictionaries),
              ),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(l10n.backupAndRestore),
                subtitle: Text(l10n.backupHint),
                onTap: () => context.push(Routes.backup),
              ),
            ],
          ),
          Island(
            title: l10n.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appVersion),
                subtitle: Text(ref.watch(appVersionProvider).value ?? '…'),
              ),
              if (updatesSupported) ...[
                SwitchListTile(
                  secondary: const Icon(Icons.update),
                  title: Text(l10n.updatesAuto),
                  subtitle: Text(l10n.updatesAutoHint),
                  value: settings.autoUpdateCheck,
                  onChanged: (v) => repo.set(SettingKeys.autoUpdateCheck, '$v'),
                ),
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: Text(l10n.checkForUpdates),
                  onTap: () => checkForUpdatesNow(context, ref),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(l10n.sourceCode),
                subtitle: Text(l10n.sourceCodeHint),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(repositoryUrl, mode: LaunchMode.externalApplication),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.licenses),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: ref.read(appVersionProvider).value,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/app_icon.png', width: 64, height: 64),
                    ),
                  ),
                ),
              ),
              if (kDebugMode || sampleDataEnabled)
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('Load sample data'),
                  subtitle: const Text('Debug only'),
                  onTap: () async {
                    await ref.read(backupServiceProvider).import(buildSampleData(), ImportStrategy.merge);
                    if (context.mounted) context.go(Routes.launch);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _leadLabel(AppLocalizations l10n, int days) =>
      days == 0 ? l10n.notifLeadNone : l10n.notifLeadDays(formatDays(l10n, days));

  Future<T?> _choose<T>(BuildContext context, String title, Map<T, String> options, T current) {
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final o in options.entries)
            ListTile(
              title: Text(o.value),
              trailing: o.key == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, o.key),
            ),
        ],
      ),
    );
  }
}
