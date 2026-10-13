/// A published GitHub release of the app.
class Release {
  const Release({required this.version, required this.pageUrl, required this.apks, this.notes = ''});

  /// "1.3.0" (the tag without its leading "v").
  final String version;
  final String pageUrl;
  final String notes;

  /// APK assets by file name → download URL.
  final Map<String, String> apks;

  /// The APK for [abi] ("arm64-v8a", …) if published, else the universal one.
  String? apkFor(String? abi) {
    if (abi != null) {
      for (final e in apks.entries) {
        if (e.key.endsWith('-$abi.apk')) return e.value;
      }
    }
    const abis = ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'];
    for (final e in apks.entries) {
      if (!abis.any((a) => e.key.endsWith('-$a.apk'))) return e.value;
    }
    return apks.values.firstOrNull;
  }

  /// Parses a GitHub `releases/latest` response; null for drafts, pre-releases or releases without APKs.
  static Release? fromGitHub(Map<String, dynamic> json) {
    if (json['draft'] == true || json['prerelease'] == true) return null;
    final tag = json['tag_name'] as String?;
    if (tag == null) return null;
    final apks = <String, String>{
      for (final a in (json['assets'] as List? ?? const []).cast<Map<String, dynamic>>())
        if ((a['name'] as String? ?? '').endsWith('.apk')) a['name'] as String: a['browser_download_url'] as String,
    };
    if (apks.isEmpty) return null;
    return Release(
      version: tag.startsWith('v') ? tag.substring(1) : tag,
      pageUrl: json['html_url'] as String? ?? '',
      notes: json['body'] as String? ?? '',
      apks: apks,
    );
  }
}

/// Compares "1.2.10" with "1.3" numerically; build metadata (+N) is ignored and a
/// pre-release ("1.3.0-beta") sorts before its release.
int compareVersions(String a, String b) {
  (List<int>, bool) parse(String v) {
    final core = v.split('+').first;
    final pre = core.contains('-');
    final nums = core.split('-').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    return (nums, pre);
  }

  final (na, preA) = parse(a);
  final (nb, preB) = parse(b);
  for (var i = 0; i < (na.length > nb.length ? na.length : nb.length); i++) {
    final x = i < na.length ? na[i] : 0, y = i < nb.length ? nb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  if (preA != preB) return preA ? -1 : 1;
  return 0;
}
