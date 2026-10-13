import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';

import '../../backup/data/backup_service.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/release.dart';

const releasesRepo = 'nuc134r/garage2';

/// In-app updates install APKs, so they exist on Android only (the web build is always current).
bool get updatesSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// The latest published release, or null if there is none.
  Future<Release?> latest() async {
    final response = await _client.get(
      Uri.https('api.github.com', '/repos/$releasesRepo/releases/latest'),
      headers: const {'Accept': 'application/vnd.github+json'},
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw http.ClientException('GitHub answered ${response.statusCode}');
    return Release.fromGitHub(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Downloads the APK for this device and opens the system installer.
  Future<Stream<OtaEvent>> install(Release release) async {
    final ota = OtaUpdate();
    String? abi;
    try {
      abi = await ota.getAbi();
    } catch (_) {}
    final url = release.apkFor(abi);
    if (url == null) throw StateError('No APK in release ${release.version}');
    return ota.execute(url, destinationFilename: 'garage-${release.version}.apk');
  }
}

final updateServiceProvider = Provider((ref) => UpdateService());

/// The installed version without the build number, e.g. "1.2.0".
Future<String> installedVersion(Ref ref) async => (await ref.watch(appVersionProvider.future)).split('+').first;

/// A newer release than the installed one, or null.
Future<Release?> checkForUpdate(Ref ref) async {
  final release = await ref.read(updateServiceProvider).latest();
  if (release == null) return null;
  return compareVersions(release.version, await installedVersion(ref)) > 0 ? release : null;
}

/// Checked once per app start in release builds on Android, unless turned off or dismissed for that version.
final availableUpdateProvider = FutureProvider<Release?>((ref) async {
  if (!updatesSupported || !kReleaseMode) return null;
  final settings = await ref.watch(appSettingsProvider.selectAsync((s) => (s.autoUpdateCheck, s.dismissedUpdate)));
  if (!settings.$1) return null;
  try {
    final release = await checkForUpdate(ref);
    return release == null || release.version == settings.$2 ? null : release;
  } catch (_) {
    return null; // Offline or rate-limited: try again next start.
  }
});
