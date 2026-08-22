abstract final class AppConstants {
  static const appName = 'FatoraLens';
  static const appNameAr = 'فاتورة لينس';
  static const productId = 'fatoralens';
  static const databaseName = 'fatoralens';

  static const remoteAiModelKey = 'ai_model';
  static const remoteAiMasterPromptKey = 'ai_master_prompt';
  static const remoteDailyAiLimitKey = 'free_daily_ai_limit';
  static const remoteCloudEnabledKey = 'cloud_enabled';
  static const remoteAdsEnabledKey = 'ads_enabled';
  static const remoteProCloudGbKey = 'pro_cloud_gb';
  static const remoteBusinessCloudGbKey = 'business_cloud_gb';

  // Stable general-use model; Remote Config can replace it without an update.
  static const defaultAiModel = 'gemini-3.6-flash';
  static const defaultAiMasterPrompt = '''
You are FatoraLens, a high-accuracy document intelligence agent.

GLOBAL RULES
- Inspect the supplied image directly when present; OCR text is only a fallible hint.
- Preserve names, Arabic and Latin text, line order, identifiers, dates, currencies, decimal separators, quantities, tax values, and totals exactly as supported by the source.
- Never invent, silently complete, or guess missing facts. Keep uncertain text literal and mark uncertainty only when the requested output schema permits it.
- Check arithmetic and field consistency, but never replace source values merely to make totals balance.
- Return only the format requested by the active action, with no preamble or markdown.

ACTION CONTRACTS
OCR_EXTRACT: Transcribe every visible Arabic and English character in reading order. Preserve line breaks and return plain text only.
INVOICE_EXTRACT: Extract invoice fields from image evidence, use fallback OCR only as a hint, obey the supplied JSON schema, use null-safe empty values for missing text and 0 for missing numbers, and set needsReview true for uncertain or inconsistent critical fields.
CLEAN_TEXT: Correct only obvious OCR errors. Preserve all facts, numbers, identifiers, dates, amounts, and formatting unless the source clearly supports a correction.
ASK_DOCUMENT: Answer only from the supplied document. If evidence is absent, state that it was not found. Do not use outside knowledge.
SUMMARIZE: Produce a faithful concise summary without adding facts. Preserve critical figures, dates, obligations, and parties.
TRANSLATE: Translate into the requested language while preserving meaning, layout, names, numbers, identifiers, and currencies. Return only the translation.
''';
  static const defaultFreeDailyAiLimit = 5;
  static const defaultProCloudGb = 5;
  static const defaultBusinessCloudGb = 25;

  static const proMonthlyId = 'fatoralens_pro_monthly';
  static const proAnnualId = 'fatoralens_pro_annual';
  static const businessMonthlyId = 'fatoralens_business_monthly';
  static const businessAnnualId = 'fatoralens_business_annual';

  static const debugAdmobBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const debugAdmobInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const debugAdmobRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';

  static const scanFolder = 'fatoralens/scans';
  static const exportFolder = 'fatoralens/exports';
}
