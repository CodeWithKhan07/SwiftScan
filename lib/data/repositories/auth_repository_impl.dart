import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._firebase);
  final AuthService _auth;
  final FirebaseBootstrapService _firebase;

  @override
  String? get userId => _auth.userId;
  @override
  bool get isAnonymous => _auth.isAnonymous;
  @override
  bool get firebaseAvailable => _firebase.available;
  @override
  Future<void> ensureGuestSession() => _auth.ensureGuest();
  @override
  Future<void> signInWithEmail(String email, String password) =>
      _auth.signIn(email, password);
  @override
  Future<void> registerWithEmail(String email, String password) =>
      _auth.register(email, password);
  @override
  Future<void> signOut() => _auth.signOut();
  @override
  Future<void> deleteAccount() => _auth.deleteAccount();
}
