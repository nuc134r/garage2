import 'package:flutter_test/flutter_test.dart';
import 'package:garage/features/settings/presentation/settings_screen.dart';
import 'package:garage/features/updates/domain/release.dart';

void main() {
  test('version comparison', () {
    expect(compareVersions('1.2.0', '1.10.0'), lessThan(0));
    expect(compareVersions('1.3', '1.3.0'), 0);
    expect(compareVersions('1.0.0+7', '1.0.0+1'), 0, reason: 'build numbers are ignored');
    expect(compareVersions('1.3.0-beta', '1.3.0'), lessThan(0));
    expect(compareVersions('2.0.0', '1.9.9'), greaterThan(0));
    // CI builds between releases (tool/version.sh).
    expect(compareVersions('1.3.0-5-g1a2b3c4', '1.3.0'), greaterThan(0));
    expect(compareVersions('1.3.0-5-g1a2b3c4', '1.3.1'), lessThan(0));
    expect(compareVersions('1.3.0-5-g1a2b3c4', '1.3.0-12-gdeadbee'), lessThan(0));
  });

  Map<String, dynamic> json({bool prerelease = false, List<String> assets = const ['garage-1.3.0.apk', 'garage-1.3.0-arm64-v8a.apk']}) => {
        'tag_name': 'v1.3.0',
        'html_url': 'https://github.com/nuc134r/garage2/releases/tag/v1.3.0',
        'body': 'Notes',
        'draft': false,
        'prerelease': prerelease,
        'assets': [for (final a in assets) {'name': a, 'browser_download_url': 'https://dl/$a'}],
      };

  test('parses a GitHub release and picks the APK for the device', () {
    final r = Release.fromGitHub(json())!;
    expect(r.version, '1.3.0');
    expect(r.apkFor('arm64-v8a'), 'https://dl/garage-1.3.0-arm64-v8a.apk');
    expect(r.apkFor('x86_64'), 'https://dl/garage-1.3.0.apk', reason: 'falls back to the universal APK');
    expect(r.apkFor(null), 'https://dl/garage-1.3.0.apk');
  });

  test('ignores pre-releases and releases without APKs', () {
    expect(Release.fromGitHub(json(prerelease: true)), isNull);
    expect(Release.fromGitHub(json(assets: ['notes.txt'])), isNull);
  });

  test('displayed version drops the build number and CI commit suffix', () {
    expect(displayVersion('2.5.1+42'), '2.5.1');
    expect(displayVersion('2.5.1-4-gabc1234+99'), '2.5.1');
    expect(displayVersion('2.6.0-beta.1+7'), '2.6.0-beta.1');
    expect(displayVersion(null), isNull);
  });
}
