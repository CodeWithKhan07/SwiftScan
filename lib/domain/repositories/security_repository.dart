abstract interface class SecurityRepository {
  Future<bool> authenticate();
  Future<bool> isSupported();
}
