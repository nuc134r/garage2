import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'update_service.dart';

/// The changelog to show: the latest from GitHub, or the copy bundled with this build when offline.
class Changelog {
  const Changelog(this.markdown, {required this.fromGitHub});

  /// From the first version heading on (the file's developer note is skipped).
  final String markdown;
  final bool fromGitHub;
}

String _versionsOnly(String source) {
  final i = source.indexOf(RegExp(r'^## ', multiLine: true));
  return i < 0 ? source : source.substring(i);
}

final changelogProvider = FutureProvider.autoDispose<Changelog>((ref) async {
  try {
    final response = await http
        .get(Uri.https('raw.githubusercontent.com', '/$releasesRepo/main/CHANGELOG.md'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return Changelog(_versionsOnly(response.body), fromGitHub: true);
    }
  } catch (_) {
    // Offline: fall back to the bundled copy.
  }
  return Changelog(_versionsOnly(await rootBundle.loadString('CHANGELOG.md')), fromGitHub: false);
});
