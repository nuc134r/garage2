import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// CI build number baked into the web build (`--dart-define=APP_BUILD=…`); empty for local builds.
const appBuild = String.fromEnvironment('APP_BUILD');

/// Build number of the deployed web app, read from version.json past every cache.
Future<int?> deployedBuild(http.Client client) async {
  final url = Uri.base.resolve('version.json').replace(queryParameters: {'t': '${clock.now().millisecondsSinceEpoch}'});
  final response = await client.get(url, headers: const {'Cache-Control': 'no-cache'});
  if (response.statusCode != 200) return null;
  return int.tryParse('${(jsonDecode(response.body) as Map<String, dynamic>)['build_number']}');
}

/// True once a newer web build than the running one is deployed. Checked at start, every
/// 10 minutes and whenever the tab comes back to the foreground.
final webUpdateProvider = StreamProvider<bool>((ref) {
  final running = int.tryParse(appBuild);
  if (!kIsWeb || running == null) return Stream.value(false);
  final client = http.Client();
  final controller = StreamController<bool>();
  Future<void> check() async {
    try {
      final deployed = await deployedBuild(client);
      if (deployed != null && deployed > running) controller.add(true);
    } catch (_) {
      // Offline: try again later.
    }
  }

  final timer = Timer.periodic(const Duration(minutes: 10), (_) => check());
  final lifecycle = AppLifecycleListener(onResume: check);
  controller.add(false);
  check();
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
    client.close();
    controller.close();
  });
  return controller.stream;
});
