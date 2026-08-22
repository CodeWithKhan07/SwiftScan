import 'package:get_it/get_it.dart';

import '../../data/datasources/firebase_document_data_source.dart';
import '../../data/datasources/local_document_data_source.dart';
import '../../data/datasources/local_key_value_data_source.dart';
import '../../data/local/isar/isar_database.dart';
import '../../data/mappers/document_mapper.dart';
import '../../data/repositories/ad_repository_impl.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/device_action_repository_impl.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../data/repositories/document_tool_repository_impl.dart';
import '../../data/repositories/entitlement_repository_impl.dart';
import '../../data/repositories/invoice_intelligence_repository_impl.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../data/services/ad_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';
import '../../data/services/entitlement_service.dart';
import '../../data/services/file_service.dart';
import '../../data/services/firebase_ai_service.dart';
import '../../data/services/firebase_bootstrap_service.dart';
import '../../data/services/image_enhancement_service.dart';
import '../../data/services/internet_connection_service.dart';
import '../../data/services/mlkit_ocr_service.dart';
import '../../data/services/ocr_complexity_policy.dart';
import '../../data/services/pdf_toolkit_service.dart';
import '../../data/services/remote_config_service.dart';
import '../../data/services/zatca_qr_parser.dart';
import '../../domain/repositories/ad_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_action_repository.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/repositories/document_tool_repository.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../../domain/repositories/invoice_intelligence_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/usecases/ad_usecases.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/device_usecases.dart';
import '../../domain/usecases/document_usecases.dart';
import '../../domain/usecases/entitlement_usecases.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../../domain/usecases/preference_usecases.dart';
import '../../domain/usecases/security_usecases.dart';
import '../../domain/usecases/tool_usecases.dart';
import '../../presentation/controllers/account_controller.dart';
import '../../presentation/controllers/ads_controller.dart';
import '../../presentation/controllers/app_lock_controller.dart';
import '../../presentation/controllers/app_locale_controller.dart';
import '../../presentation/controllers/app_shell_controller.dart';
import '../../presentation/controllers/app_setup_controller.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/conversion_controller.dart';
import '../../presentation/controllers/document_controller.dart';
import '../../presentation/controllers/editor_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/invoice_detail_controller.dart';
import '../../presentation/controllers/invoices_controller.dart';
import '../../presentation/controllers/onboarding_controller.dart';
import '../../presentation/controllers/qr_controller.dart';
import '../../presentation/controllers/scanner_controller.dart';
import '../../presentation/controllers/splash_controller.dart';
import '../../presentation/controllers/subscription_controller.dart';
import '../../presentation/controllers/tools_controller.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<IsarDatabase>()) return;

  final database = await IsarDatabase.open();
  sl.registerSingleton<IsarDatabase>(database);

  final firebase = FirebaseBootstrapService();
  await firebase.initialize();
  sl.registerSingleton<FirebaseBootstrapService>(firebase);

  final remoteConfig = RemoteConfigService(firebase);
  await remoteConfig.initialize();
  sl.registerSingleton<RemoteConfigService>(remoteConfig);

  _registerMappers();
  _registerDataSources();
  _registerServices();
  _registerRepositories();
  _registerUseCases();
  _registerControllers();

  await sl<AppSetupController>().initialize();
  await sl<AppShellController>().initialize();
  await sl<AppLocaleController>().initialize();
  await sl<EntitlementUseCases>().initialize();
  await sl<AuthUseCases>().ensureGuest();
  await sl<AdRepository>().initialize();
}

void _registerMappers() {
  sl.registerLazySingleton<DocumentMapper>(DocumentMapper.new);
}

void _registerDataSources() {
  sl.registerLazySingleton<LocalKeyValueDataSource>(
    () => LocalKeyValueDataSource(sl()),
  );
  sl.registerLazySingleton<LocalDocumentDataSource>(
    () => LocalDocumentDataSource(sl(), sl()),
  );
  sl.registerLazySingleton<FirebaseDocumentDataSource>(
    () => FirebaseDocumentDataSource(sl(), sl(), sl(), sl(), sl()),
  );
}

void _registerServices() {
  sl.registerLazySingleton<FileService>(FileService.new);
  sl.registerLazySingleton<MlKitOcrService>(MlKitOcrService.new);
  sl.registerLazySingleton<InternetConnectionService>(
    InternetConnectionService.new,
  );
  sl.registerLazySingleton<OcrComplexityPolicy>(OcrComplexityPolicy.new);
  sl.registerLazySingleton<BiometricService>(BiometricService.new);
  sl.registerLazySingleton<ZatcaQrParser>(ZatcaQrParser.new);
  sl.registerLazySingleton<AdService>(AdService.new);
  sl.registerLazySingleton<AuthService>(() => AuthService(sl()));
  sl.registerLazySingleton<FirebaseAiService>(
    () => FirebaseAiService(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<ImageEnhancementService>(
    () => ImageEnhancementService(sl()),
  );
  sl.registerLazySingleton<PdfToolkitService>(() => PdfToolkitService(sl()));
  sl.registerLazySingleton<EntitlementService>(
    () => EntitlementService(sl(), sl()),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<AiRepository>(() => AiRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<DeviceActionRepository>(
    DeviceActionRepositoryImpl.new,
  );
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AdRepository>(() => AdRepositoryImpl(sl()));
  sl.registerLazySingleton<EntitlementRepository>(
    () => EntitlementRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<DocumentToolRepository>(
    () => DocumentToolRepositoryImpl(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton<InvoiceIntelligenceRepository>(
    () => InvoiceIntelligenceRepositoryImpl(sl(), sl(), sl()),
  );
}

void _registerUseCases() {
  sl.registerLazySingleton<DocumentUseCases>(() => DocumentUseCases(sl()));
  sl.registerLazySingleton<ToolUseCases>(() => ToolUseCases(sl()));
  sl.registerLazySingleton<AiUseCases>(() => AiUseCases(sl(), sl()));
  sl.registerLazySingleton<InvoiceUseCases>(() => InvoiceUseCases(sl()));
  sl.registerLazySingleton<AuthUseCases>(() => AuthUseCases(sl()));
  sl.registerLazySingleton<EntitlementUseCases>(
    () => EntitlementUseCases(sl()),
  );
  sl.registerLazySingleton<PreferenceUseCases>(() => PreferenceUseCases(sl()));
  sl.registerLazySingleton<SecurityUseCases>(() => SecurityUseCases(sl()));
  sl.registerLazySingleton<AdUseCases>(() => AdUseCases(sl()));
  sl.registerLazySingleton<DeviceActionsUseCase>(
    () => DeviceActionsUseCase(sl()),
  );
}

void _registerControllers() {
  sl.registerLazySingleton<AppSetupController>(() => AppSetupController(sl()));
  sl.registerLazySingleton<AppShellController>(() => AppShellController(sl()));
  sl.registerLazySingleton<AppLockController>(
    () => AppLockController(sl(), sl()),
  );
  sl.registerLazySingleton<AppLocaleController>(
    () => AppLocaleController(sl()),
  );
  sl.registerLazySingleton<AdsController>(() => AdsController(sl(), sl()));

  sl.registerFactory<SplashController>(SplashController.new);
  sl.registerFactory<OnboardingController>(
    () => OnboardingController(sl(), sl()),
  );
  sl.registerFactory<HomeController>(() => HomeController(sl(), sl()));
  sl.registerFactory<InvoicesController>(() => InvoicesController(sl()));
  sl.registerFactory<ToolsController>(() => ToolsController(sl()));
  sl.registerFactory<AccountController>(
    () => AccountController(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<ScannerController>(ScannerController.new);
  sl.registerFactory<EditorController>(
    () => EditorController(sl(), sl(), sl()),
  );
  sl.registerFactory<DocumentController>(
    () => DocumentController(sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<InvoiceDetailController>(
    () => InvoiceDetailController(sl(), sl(), sl()),
  );
  sl.registerFactory<QrController>(() => QrController(sl()));
  sl.registerFactory<ConversionController>(
    () => ConversionController(sl(), sl(), sl()),
  );
  sl.registerFactory<AuthController>(() => AuthController(sl()));
  sl.registerFactory<SubscriptionController>(
    () => SubscriptionController(sl()),
  );
}
