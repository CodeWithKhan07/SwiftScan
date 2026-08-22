import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_snackbar.dart';
import 'base/entitlement_controller.dart';

class SubscriptionController extends EntitlementController {
  SubscriptionController(super.entitlements);

  final isWorking = false.obs;

  Future<void> buyProMonthly() => _buy(AppConstants.proMonthlyId);
  Future<void> buyProAnnual() => _buy(AppConstants.proAnnualId);
  Future<void> buyBusinessMonthly() => _buy(AppConstants.businessMonthlyId);
  Future<void> buyBusinessAnnual() => _buy(AppConstants.businessAnnualId);

  Future<void> _buy(String id) async {
    if (isWorking.value) return;

    isWorking.value = true;
    try {
      await entitlements.buy(id);
    } catch (error) {
      AppSnackbar.error('Store product unavailable / المنتج غير متاح: $error');
    } finally {
      isWorking.value = false;
    }
  }

  Future<void> restore() async {
    try {
      await entitlements.restore();
      AppSnackbar.success('Restore requested / تم طلب الاستعادة');
    } catch (error) {
      AppSnackbar.error('Restore failed / تعذرت الاستعادة: $error');
    }
  }
}
