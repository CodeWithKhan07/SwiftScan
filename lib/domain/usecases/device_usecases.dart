import '../repositories/device_action_repository.dart';

class DeviceActionsUseCase {
  const DeviceActionsUseCase(this._repository);
  final DeviceActionRepository _repository;
  Future<void> copy(String text) => _repository.copyText(text);
  Future<void> shareText(String text, {String? subject}) =>
      _repository.shareText(text, subject: subject);
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    String? subject,
  }) => _repository.shareFiles(paths, text: text, subject: subject);
}
