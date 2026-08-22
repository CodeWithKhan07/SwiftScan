import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_components.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentSurface(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.cloud_done_outlined,
              color: AppColors.onAccentSurface(context),
              size: 30,
            ),
          ),
          const SizedBox(height: 22),
          BilingualText(
            controller.isRegister.value ? 'إنشاء حساب' : 'تسجيل الدخول',
            controller.isRegister.value ? 'Create Account' : 'Sign In',
            arStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            enStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          BilingualText(
            'يمكنك استخدام المسح محلياً بدون حساب.',
            'Keep local scanning without an account. Sign in only for identity and cloud features.',
            arStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
              height: 1.45,
            ),
            enStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني  •  Email',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.password,
            obscureText: controller.obscurePassword.value,
            decoration: InputDecoration(
              labelText: 'كلمة المرور  •  Password',
              suffixIcon: IconButton(
                onPressed: controller.togglePassword,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: controller.isWorking.value ? null : controller.submit,
            child: Text(
              controller.isRegister.value
                  ? 'إنشاء الحساب   Create Account'
                  : 'تسجيل الدخول   Sign In',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.toggleMode,
            child: Text(
              controller.isRegister.value
                  ? 'لديك حساب؟ تسجيل الدخول  •  Already have an account?'
                  : 'إنشاء حساب جديد  •  Create a new account',
            ),
          ),
        ],
      ),
    ),
  );
}
