import '../entities/entitlement.dart';
import '../repositories/entitlement_repository.dart';

class EntitlementUseCases {
  const EntitlementUseCases(this._repository);

  final EntitlementRepository _repository;

  Entitlement get current => _repository.current;
  Stream<Entitlement> watch() => _repository.watch();
  Future<void> initialize() => _repository.initialize();
  Future<void> buy(String productId) => _repository.buy(productId);
  Future<void> restore() => _repository.restore();
}
