enum SubscriptionTier { free, pro, business }

class Entitlement {
  const Entitlement({
    this.tier = SubscriptionTier.free,
    this.aiCreditsRemaining = 0,
    this.cloudStorageGb = 0,
    this.adsEnabled = true,
  });

  final SubscriptionTier tier;
  final int aiCreditsRemaining;
  final int cloudStorageGb;
  final bool adsEnabled;

  bool get isPremium => tier != SubscriptionTier.free;
  bool get isBusiness => tier == SubscriptionTier.business;
}
