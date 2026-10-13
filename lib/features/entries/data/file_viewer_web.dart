import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Opens [bytes] in a new browser tab (browsers show PDFs and images themselves).
Future<bool> viewFile(Uint8List bytes, String name, String mimeType) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final tab = web.window.open(url, '_blank');
  return tab != null;
}
