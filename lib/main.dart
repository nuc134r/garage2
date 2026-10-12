import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';

void main() {
  // Keep the browser address bar in sync with push/pop navigation.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const ProviderScope(child: GarageApp()));
}
