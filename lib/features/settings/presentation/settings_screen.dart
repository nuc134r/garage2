import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../data/settings_repository.dart';

final repositoryUrl = Uri.parse('https://github.com/nuc134r/garage2');
const feedbackEmail = 'garage@nuc134r.io';

/// "2.5.1" for display: without the build number and the commit suffix of CI builds ("-3-g1a2b3c4").
String? displayVersion(String? version) =>
    version?.split('+').first.replaceFirst(RegExp(r'-\d+-g[0-9a-f]+$'), '');

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
    final languageLabels = {
      '': l10n.languageSystem,
      'en': 'English',
      'es': 'Español',
      'de': 'Deutsch',
      'fr': 'Français',
      'ru': 'Русский',
    };
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
                leading: const Icon(Icons.dark_mode),
                title: Text(l10n.theme),
                subtitle: Text(themeLabels[settings.themeMode]!),
                onTap: () async {
                  final mode = await chooseOption(context, l10n.theme, themeLabels, settings.themeMode);
                  if (mode != null) await repo.set(SettingKeys.themeMode, mode.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(languageLabels[currentLanguage] ?? currentLanguage),
                onTap: () async {
                  final code = await chooseOption(context, l10n.language, languageLabels, currentLanguage);
                  if (code != null) await repo.set(SettingKeys.locale, code.isEmpty ? null : code);
                },
              ),
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                SwitchListTile(
                  secondary: const Icon(Icons.swipe_left),
                  title: Text(l10n.predictiveBack),
                  value: settings.predictiveBack,
                  onChanged: (v) => repo.set(SettingKeys.predictiveBack, '$v'),
                ),
            ],
          ),
          Island(
            title: l10n.notifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: Text(l10n.notifReminders),
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
                subtitle: Text(leadLabel(l10n, settings.notifyLeadDays)),
                onTap: () async {
                  final days = await chooseOption(
                    context,
                    l10n.notifLead,
                    {for (final d in const [0, 3, 7, 14, 30]) d: leadLabel(l10n, d)},
                    settings.notifyLeadDays,
                  );
                  if (days != null) await repo.set(SettingKeys.notifyLeadDays, '$days');
                },
              ),
              ListTile(
                enabled: settings.notificationsEnabled,
                leading: const Icon(Icons.directions_car),
                title: Text(l10n.notifByVehicle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.vehicleNotifications),
              ),
            ],
          ),
          Island(
            title: l10n.data,
            children: [
              ListTile(
                leading: const Icon(Icons.garage),
                title: Text(l10n.garage),
                onTap: () => context.push(Routes.garage),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_customize),
                title: Text(l10n.homeTiles),
                onTap: () => context.push(Routes.homeTiles),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: Text(l10n.dictionaries),
                onTap: () => context.push(Routes.dictionaries),
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: Text(l10n.backupAndRestore),
                onTap: () => context.push(Routes.backup),
              ),
            ],
          ),
          Island(
            title: l10n.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(l10n.appVersion),
                subtitle: Text(displayVersion(ref.watch(appVersionProvider).value) ?? '…'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.version),
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: Text(l10n.feedback),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final opened = await launchUrl(Uri(scheme: 'mailto', path: feedbackEmail, query: 'subject=garage'));
                  if (!opened && context.mounted) {
                    // No mail app: hand over the address instead.
                    await Clipboard.setData(const ClipboardData(text: feedbackEmail));
                    if (context.mounted) showSnack(context, l10n.feedbackCopied(feedbackEmail));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(l10n.sourceCode),
                subtitle: Text(l10n.sourceCodeHint),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(repositoryUrl, mode: LaunchMode.externalApplication),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(l10n.licenses),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: displayVersion(ref.read(appVersionProvider).value),
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
                  leading: const Icon(Icons.science),
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
}

/// "7 days before", or "Only on the due day" for 0.
String leadLabel(AppLocalizations l10n, int days) =>
    days == 0 ? l10n.notifLeadNone : l10n.notifLeadDays(formatDays(l10n, days));

/// A dialog listing [options] with a check at [current]; returns the picked key.
Future<T?> chooseOption<T>(BuildContext context, String title, Map<T, String> options, T current) {
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
