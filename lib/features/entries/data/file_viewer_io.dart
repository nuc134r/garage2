import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Opens [bytes] in the app the system uses to view [mimeType] (on Android e.g. Google Drive's PDF
/// viewer). Returns false when no app can show it; throws when opening fails otherwise.
Future<bool> viewFile(Uint8List bytes, String name, String mimeType) async {
  final dir = Directory('${(await getTemporaryDirectory()).path}/attachments');
  await dir.create(recursive: true);
  final safeName = name.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
  final file = await File('${dir.path}/$safeName').writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: mimeType);
  return switch (result.type) {
    ResultType.done => true,
    ResultType.noAppToOpen => false,
    _ => throw Exception(result.message),
  };
}
