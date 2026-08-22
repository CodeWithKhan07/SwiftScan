import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/entities/entitlement.dart';
import '../datasources/local_key_value_data_source.dart';
import 'remote_config_service.dart';

class EntitlementService {
  EntitlementService(this._config, this._local);

  final RemoteConfigService _config;
  final LocalKeyValueDataSource _local;
  final InAppPurchase _store = InAppPurchase.instance;
  final StreamController<Entitlement> _controller =
      StreamController<Entitlement>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Entitlement _current = const Entitlement();

  Entitlement get current => _current;
  Stream<Entitlement> get stream => _controller.stream;

  Future<void> initialize() async {
    _purchaseSubscription = _store.purchaseStream.listen(_handlePurchases);
    await _refresh();
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    var tier = SubscriptionTier.free;

    for (final purchase in purchases) {
      final validStatus =
          purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored;
      if (!validStatus) continue;

      if (purchase.productID.contains('business')) {
        tier = SubscriptionTier.business;
      } else if (purchase.productID.contains('pro') &&
          tier == SubscriptionTier.free) {
        tier = SubscriptionTier.pro;
      }

      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }

    await _local.write(_tierKey, tier.name);
    await _emit(tier);
  }

  Future<void> _refresh() async {
    final saved = await _local.read<String>(_tierKey);
    final tier = SubscriptionTier.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => SubscriptionTier.free,
    );
    await _emit(tier);
  }

  Future<void> _emit(SubscriptionTier tier) async {
    final remaining = await _remainingCredits(tier);
    final cloudStorageGb = switch (tier) {
      SubscriptionTier.business => _config.businessCloudGb,
      SubscriptionTier.pro => _config.proCloudGb,
      SubscriptionTier.free => 0,
    };

    _current = Entitlement(
      tier: tier,
      aiCreditsRemaining: remaining,
      cloudStorageGb: cloudStorageGb,
      adsEnabled: tier == SubscriptionTier.free && _config.adsEnabled,
    );
    _controller.add(_current);
  }

  Future<bool> consumeAiCredit() async {
    final remaining = await _remainingCredits(_current.tier);
    if (remaining <= 0) return false;

    final key = _usageKey;
    final used = await _local.read<int>(key) ?? 0;
    await _local.write(key, used + 1);
    await _emit(_current.tier);
    return true;
  }

  Future<void> refundAiCredit() async {
    final used = await _local.read<int>(_usageKey) ?? 0;
    if (used <= 0) return;

    // Failed/offline AI calls must not reduce the user's daily allowance.
    await _local.write(_usageKey, used - 1);
    await _emit(_current.tier);
  }

  Future<void> buy(String productId) async {
    if (!await _store.isAvailable()) {
      throw StateError('Store is unavailable.');
    }

    final response = await _store.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      throw StateError('Subscription product is not configured in the store.');
    }

    await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: response.productDetails.first,
      ),
    );
  }

  Future<void> restore() => _store.restorePurchases();

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _controller.close();
  }

  int _dailyLimit(SubscriptionTier tier) {
    return switch (tier) {
      SubscriptionTier.free => _config.freeDailyAiLimit,
      SubscriptionTier.pro => _config.freeDailyAiLimit * 20,
      SubscriptionTier.business => _config.freeDailyAiLimit * 100,
    };
  }

  Future<int> _remainingCredits(SubscriptionTier tier) async {
    final used = await _local.read<int>(_usageKey) ?? 0;
    return (_dailyLimit(tier) - used).clamp(0, 1000000);
  }

  String get _usageKey {
    final now = DateTime.now();
    final day = '${now.year}-${now.month}-${now.day}';
    return 'ai_used_$day';
  }

  static const _tierKey = 'subscription_tier';
}
