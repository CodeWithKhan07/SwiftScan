abstract interface class DeviceActionRepository {
  Future<void> copyText(String text);
  Future<void> shareText(String text, {String? subject});
  Future<void> shareFiles(List<String> paths, {String? text, String? subject});
}
