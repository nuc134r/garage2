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

/// Compares "1.2.10" with "1.3" numerically; build metadata (+N) is ignored, a pre-release
/// ("1.3.0-beta") sorts before its release and a CI build after a tag ("1.3.0-5-g1a2b3c4",
/// see tool/version.sh) sorts after it, by commit count.
int compareVersions(String a, String b) {
  final afterTag = RegExp(r'^(.*)-(\d+)-g[0-9a-f]+$');
  // (numbers, rank): pre-release -1, release 0, N commits after the tag N.
  (List<int>, int) parse(String v) {
    var core = v.split('+').first;
    var rank = 0;
    final m = afterTag.firstMatch(core);
    if (m != null) {
      core = m.group(1)!;
      rank = int.parse(m.group(2)!);
    } else if (core.contains('-')) {
      rank = -1;
    }
    return (core.split('-').first.split('.').map((p) => int.tryParse(p) ?? 0).toList(), rank);
  }

  final (na, rankA) = parse(a);
  final (nb, rankB) = parse(b);
  for (var i = 0; i < (na.length > nb.length ? na.length : nb.length); i++) {
    final x = i < na.length ? na[i] : 0, y = i < nb.length ? nb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return rankA.compareTo(rankB);
}
