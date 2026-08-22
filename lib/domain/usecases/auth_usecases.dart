import '../repositories/auth_repository.dart';

class AuthUseCases {
  const AuthUseCases(this._repository);

  final AuthRepository _repository;

  String? get userId => _repository.userId;
  bool get isAnonymous => _repository.isAnonymous;
  bool get firebaseAvailable => _repository.firebaseAvailable;

  Future<void> ensureGuest() => _repository.ensureGuestSession();
  Future<void> signIn(String email, String password) =>
      _repository.signInWithEmail(email, password);
  Future<void> register(String email, String password) =>
      _repository.registerWithEmail(email, password);
  Future<void> signOut() => _repository.signOut();
  Future<void> deleteAccount() => _repository.deleteAccount();
}
