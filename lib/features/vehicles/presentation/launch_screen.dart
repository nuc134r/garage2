import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/l10n.dart';
import '../../backup/data/backup_service.dart';
import '../../backup/domain/backup_data.dart';
import '../../backup/domain/sample_data.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../reminders/data/reminder_notifications.dart';
import '../../settings/data/settings_repository.dart';
import '../data/vehicle_repository.dart';

/// Opens the last used vehicle, or shows a welcome page when the garage is empty.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  static bool _dailyRestorePointChecked = false;

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);
    final settings = ref.watch(appSettingsProvider);

    if (vehicles case AsyncData(value: final list) when list.isNotEmpty) {
      if (settings case AsyncData(value: final s)) {
        final target = launchVehicleId(list, s.lastVehicleId)!;
        final launchRoute = ref.read(reminderNotificationsProvider).takeLaunchRoute();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go(Routes.home(target));
          if (launchRoute != null) context.push(launchRoute);
        });
        if (!_dailyRestorePointChecked) {
          _dailyRestorePointChecked = true;
          ref.read(backupServiceProvider).createDailyRestorePointIfDue(s);
        }
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (vehicles case AsyncData()) return const _Welcome();
    if (vehicles case AsyncError(:final error)) {
      return Scaffold(body: Center(child: Text(context.l10n.errorGeneric('$error'), textAlign: TextAlign.center)));
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _Welcome extends ConsumerWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(icon: const Icon(Icons.settings), tooltip: l10n.settings, onPressed: () => context.push(Routes.settings))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('assets/app_icon.png', width: 96, height: 96, filterQuality: FilterQuality.medium),
                ),
                const SizedBox(height: 16),
                Text(l10n.welcomeTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeText,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addFirstVehicle),
                    onPressed: () => context.push(Routes.newVehicle),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.restoreFromBackup),
                    onPressed: () => importBackupFromFile(context, ref),
                  ),
                ),
                const SizedBox(height: 8),
                // Fills the garage with sample vehicles; the launch screen then opens one.
                TextButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.tryDemoData),
                  onPressed: () => ref.read(backupServiceProvider).import(buildSampleData(), ImportStrategy.merge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
