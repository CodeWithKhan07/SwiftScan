import '../entities/entitlement.dart';

abstract interface class EntitlementRepository {
  Stream<Entitlement> watch();
  Entitlement get current;
  Future<void> initialize();
  Future<void> buy(String productId);
  Future<void> restore();
  Future<bool> consumeAiCredit();
  Future<void> refundAiCredit();
}
