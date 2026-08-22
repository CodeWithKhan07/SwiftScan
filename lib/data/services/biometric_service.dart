import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUse() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'فتح FatoraLens / Unlock FatoraLens',
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
