import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../core/constants/app_constants.dart';
import 'firebase_bootstrap_service.dart';

class RemoteConfigService {
  RemoteConfigService(this._firebase);
  final FirebaseBootstrapService _firebase;
  FirebaseRemoteConfig? _config;

  Future<void> initialize() async {
    if (!_firebase.available) return;
    final config = FirebaseRemoteConfig.instance;
    await config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await config.setDefaults(const {
      AppConstants.remoteAiModelKey: AppConstants.defaultAiModel,
      AppConstants.remoteAiMasterPromptKey: AppConstants.defaultAiMasterPrompt,
      AppConstants.remoteDailyAiLimitKey: AppConstants.defaultFreeDailyAiLimit,
      AppConstants.remoteCloudEnabledKey: false,
      AppConstants.remoteAdsEnabledKey: false,
      AppConstants.remoteProCloudGbKey: AppConstants.defaultProCloudGb,
      AppConstants.remoteBusinessCloudGbKey:
          AppConstants.defaultBusinessCloudGb,
    });
    try {
      await config.fetchAndActivate();
    } catch (_) {}
    _config = config;
  }

  String get aiModel {
    final value =
        _config?.getString(AppConstants.remoteAiModelKey).trim() ?? '';
    return value.isEmpty ? AppConstants.defaultAiModel : value;
  }

  String get aiMasterPrompt {
    final value =
        _config?.getString(AppConstants.remoteAiMasterPromptKey).trim() ?? '';
    return value.isEmpty ? AppConstants.defaultAiMasterPrompt : value;
  }

  int get freeDailyAiLimit =>
      _config?.getInt(AppConstants.remoteDailyAiLimitKey) ??
      AppConstants.defaultFreeDailyAiLimit;
  bool get cloudEnabled =>
      _config?.getBool(AppConstants.remoteCloudEnabledKey) ?? false;
  bool get adsEnabled =>
      _config?.getBool(AppConstants.remoteAdsEnabledKey) ?? false;
  int get proCloudGb =>
      _config?.getInt(AppConstants.remoteProCloudGbKey) ??
      AppConstants.defaultProCloudGb;
  int get businessCloudGb =>
      _config?.getInt(AppConstants.remoteBusinessCloudGbKey) ??
      AppConstants.defaultBusinessCloudGb;
}
