import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap_service.dart';

class AuthService {
  AuthService(this._firebase);
  final FirebaseBootstrapService _firebase;

  FirebaseAuth? get _auth => _firebase.available ? FirebaseAuth.instance : null;
  String? get userId => _auth?.currentUser?.uid;
  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? true;

  Future<void> ensureGuest() async {
    final auth = _auth;
    if (auth == null || auth.currentUser != null) return;
    await auth.signInAnonymously();
  }

  Future<void> signIn(String email, String password) async {
    final auth = _auth;
    if (auth == null) throw StateError('Firebase is not configured.');
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    final auth = _auth;
    if (auth == null) throw StateError('Firebase is not configured.');
    final current = auth.currentUser;
    if (current?.isAnonymous == true) {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await current!.linkWithCredential(credential);
      return;
    }
    await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;
    await auth.signOut();
    await auth.signInAnonymously();
  }

  Future<void> deleteAccount() async {
    final user = _auth?.currentUser;
    if (user == null) return;
    await user.delete();
    await ensureGuest();
  }
}
