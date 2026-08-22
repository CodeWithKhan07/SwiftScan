import '../../domain/entities/entitlement.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../services/entitlement_service.dart';

class EntitlementRepositoryImpl implements EntitlementRepository {
  EntitlementRepositoryImpl(this._service);
  final EntitlementService _service;

  @override
  Entitlement get current => _service.current;
  @override
  Stream<Entitlement> watch() => _service.stream;
  @override
  Future<void> initialize() => _service.initialize();
  @override
  Future<void> buy(String productId) => _service.buy(productId);
  @override
  Future<void> restore() => _service.restore();
  @override
  Future<bool> consumeAiCredit() => _service.consumeAiCredit();

  @override
  Future<void> refundAiCredit() => _service.refundAiCredit();
}
