import 'dart:async';
import 'dart:io';

/// Confirms that the Google AI endpoint is reachable before cloud AI is used.
class InternetConnectionService {
  const InternetConnectionService();

  static final Uri _probeUri = Uri.https(
    'generativelanguage.googleapis.com',
    '/',
  );
  static const Duration _timeout = Duration(seconds: 4);

  Future<bool> hasInternetAccess() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      // Any HTTP response proves DNS, TLS, and the required Google route work.
      final request = await client.getUrl(_probeUri).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      await response.drain<void>().timeout(_timeout);
      return true;
    } on SocketException {
      return false;
    } on HandshakeException {
      return false;
    } on TimeoutException {
      return false;
    } on HttpException {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
