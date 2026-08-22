import '../repositories/ad_repository.dart';

class AdUseCases {
  const AdUseCases(this._repository);

  final AdRepository _repository;

  bool get initialized => _repository.initialized;
  String get bannerId => _repository.bannerId;
}
