import 'package:web/web.dart' as web;

/// Reloads the web page; the deploy cache-busts the scripts, so this loads the new build.
void reloadPage() => web.window.location.reload();
