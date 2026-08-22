import 'package:fatoralens/domain/entities/entitlement.dart';
import 'package:fatoralens/domain/entities/invoice_data.dart';
import 'package:fatoralens/domain/repositories/ai_repository.dart';
import 'package:fatoralens/domain/repositories/entitlement_repository.dart';
import 'package:fatoralens/domain/usecases/ai_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline AI attempts do not consume credits', () async {
    // Confirmed offline state stops before entitlement mutation or AI work.
    final ai = _FakeAiRepository(online: false);
    final entitlements = _FakeEntitlementRepository();
    final useCases = AiUseCases(ai, entitlements);

    await expectLater(
      useCases.cleanText('text', 'clean'),
      throwsA(isA<AiOfflineException>()),
    );
    expect(entitlements.consumed, 0);
    expect(entitlements.refunded, 0);
    expect(ai.calls, 0);
  });

  test('failed AI requests restore the consumed credit', () async {
    // App Check, model, timeout, and server failures follow the same refund path.
    final ai = _FakeAiRepository(online: true, fail: true);
    final entitlements = _FakeEntitlementRepository();
    final useCases = AiUseCases(ai, entitlements);

    await expectLater(
      useCases.cleanText('text', 'clean'),
      throwsA(isA<StateError>()),
    );
    expect(entitlements.consumed, 1);
    expect(entitlements.refunded, 1);
  });

  test('successful AI requests keep the consumed credit', () async {
    // A completed result is returned and charged exactly once.
    final ai = _FakeAiRepository(online: true);
    final entitlements = _FakeEntitlementRepository();
    final useCases = AiUseCases(ai, entitlements);

    expect(await useCases.cleanText('text', 'clean'), 'clean result');
    expect(entitlements.consumed, 1);
    expect(entitlements.refunded, 0);
  });

  test('every exposed AI feature reaches the online repository path', () async {
    // Invoice, cleanup, Q&A, summary, and translation share one guarded flow.
    final ai = _FakeAiRepository(online: true);
    final entitlements = _FakeEntitlementRepository();
    final useCases = AiUseCases(ai, entitlements);

    expect(
      (await useCases.extractInvoice('invoice.jpg', 'fallback'))?.sellerName,
      'seller',
    );
    expect(await useCases.cleanText('text', 'clean'), 'clean result');
    expect(await useCases.askDocument('document', 'question'), 'answer');
    expect(await useCases.summarize('document'), 'summary');
    expect(await useCases.translate('text', 'Arabic'), 'translation');
    expect(ai.calls, 5);
    expect(entitlements.consumed, 5);
    expect(entitlements.refunded, 0);
  });
}

class _FakeAiRepository implements AiRepository {
  _FakeAiRepository({required this.online, this.fail = false});

  final bool online;
  final bool fail;
  int calls = 0;

  @override
  bool get available => true;

  @override
  Future<bool> canUseAi() async => online;

  @override
  Future<String> cleanText(String text, {required String instruction}) async {
    calls++;
    if (fail) throw StateError('AI failed');
    return 'clean result';
  }

  @override
  Future<String> askDocument(String documentText, String question) async {
    calls++;
    return 'answer';
  }

  @override
  Future<String> extractBilingualText(String imagePath) async => '';

  @override
  Future<InvoiceData> extractInvoice(
    String imagePath,
    String fallbackText,
  ) async {
    calls++;
    return const InvoiceData(sellerName: 'seller');
  }

  @override
  Future<String> summarize(String documentText) async {
    calls++;
    return 'summary';
  }

  @override
  Future<String> translate(
    String text, {
    required String targetLanguage,
  }) async {
    calls++;
    return 'translation';
  }
}

class _FakeEntitlementRepository implements EntitlementRepository {
  int consumed = 0;
  int refunded = 0;

  @override
  Entitlement get current => const Entitlement(aiCreditsRemaining: 5);

  @override
  Future<bool> consumeAiCredit() async {
    consumed++;
    return true;
  }

  @override
  Future<void> refundAiCredit() async => refunded++;

  @override
  Future<void> buy(String productId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> restore() async {}

  @override
  Stream<Entitlement> watch() => const Stream.empty();
}
