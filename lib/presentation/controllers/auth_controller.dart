import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthController extends GetxController {
  AuthController(this._auth);

  final AuthUseCases _auth;

  final email = TextEditingController();
  final password = TextEditingController();
  final isRegister = false.obs;
  final isWorking = false.obs;
  final obscurePassword = true.obs;

  void toggleMode() => isRegister.toggle();
  void togglePassword() => obscurePassword.toggle();

  Future<void> submit() async {
    if (isWorking.value) return;

    final mail = email.text.trim();
    final pass = password.text;
    if (!mail.contains('@') || pass.length < 6) {
      AppSnackbar.info(
        'Enter a valid email and 6+ character password / أدخل بريداً صحيحاً وكلمة مرور من 6 أحرف',
      );
      return;
    }

    isWorking.value = true;
    try {
      if (isRegister.value) {
        await _auth.register(mail, pass);
      } else {
        await _auth.signIn(mail, pass);
      }
      Get.back();
      AppSnackbar.success('Account ready / الحساب جاهز');
    } catch (error) {
      AppSnackbar.error('Authentication failed / تعذر تسجيل الدخول: $error');
    } finally {
      isWorking.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
