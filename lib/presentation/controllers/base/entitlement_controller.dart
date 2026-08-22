import 'dart:async';

import 'package:get/get.dart';

import '../../../domain/entities/entitlement.dart';
import '../../../domain/usecases/entitlement_usecases.dart';

abstract class EntitlementController extends GetxController {
  EntitlementController(this.entitlements);

  final EntitlementUseCases entitlements;
  final entitlement = const Entitlement().obs;
  StreamSubscription<Entitlement>? _subscription;

  @override
  void onInit() {
    super.onInit();
    entitlement.value = entitlements.current;
    _subscription = entitlements.watch().listen((value) {
      entitlement.value = value;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
