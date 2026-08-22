import '../repositories/security_repository.dart';

class SecurityUseCases {
  const SecurityUseCases(this._repository);

  final SecurityRepository _repository;

  Future<bool> authenticate() => _repository.authenticate();
  Future<bool> isSupported() => _repository.isSupported();
}
