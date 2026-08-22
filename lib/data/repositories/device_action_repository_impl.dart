import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/repositories/device_action_repository.dart';

class DeviceActionRepositoryImpl implements DeviceActionRepository {
  @override
  Future<void> copyText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  @override
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: paths.map(XFile.new).toList(),
        text: text,
        subject: subject,
      ),
    );
  }
}
