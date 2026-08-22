import '../../domain/repositories/ad_repository.dart';
import '../services/ad_service.dart';

class AdRepositoryImpl implements AdRepository {
  const AdRepositoryImpl(this._service);

  final AdService _service;

  @override
  bool get initialized => _service.initialized;

  @override
  String get bannerId => _service.bannerId;

  @override
  Future<void> initialize() => _service.initializeIfConfigured();
}
