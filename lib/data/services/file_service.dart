import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

class FileService {
  const FileService();

  Future<Directory> _folder(String relative) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, relative));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> persistImage(String sourcePath, {Uint8List? bytes}) async {
    final dir = await _folder(AppConstants.scanFolder);
    final ext = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath);
    final target = p.join(dir.path, '${const Uuid().v4()}$ext');
    if (bytes != null) {
      await File(target).writeAsBytes(bytes, flush: true);
    } else {
      await File(sourcePath).copy(target);
    }
    return target;
  }

  Future<String> createExportPath(String name, String extension) async {
    final dir = await _folder(AppConstants.exportFolder);
    final safe = name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]+'), '_');
    return p.join(
      dir.path,
      '${safe}_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
