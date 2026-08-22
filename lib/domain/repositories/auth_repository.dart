abstract interface class AuthRepository {
  String? get userId;
  bool get isAnonymous;
  bool get firebaseAvailable;

  Future<void> ensureGuestSession();
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> deleteAccount();
}
