// Web worker hosting the sqlite3 WASM database. Rebuild after upgrading drift/sqlite3:
//   fvm dart compile js -O4 tool/drift_worker.dart -o web/drift_worker.js
// and download the matching sqlite3.wasm (see README).
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
