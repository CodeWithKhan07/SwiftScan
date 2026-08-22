import '../../domain/repositories/security_repository.dart';
import '../services/biometric_service.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  const SecurityRepositoryImpl(this._biometric);

  final BiometricService _biometric;

  @override
  Future<bool> authenticate() => _biometric.authenticate();

  @override
  Future<bool> isSupported() => _biometric.canUse();
}
