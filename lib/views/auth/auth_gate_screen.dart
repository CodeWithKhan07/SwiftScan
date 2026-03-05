import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/resources/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_lock_service.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  Future<void> _authenticate() async {
    final lockService = Get.find<AppLockService>();
    final ok = await lockService.authenticate();
    if (ok) {
      final args = Get.arguments;
      if (args != null && args is Map && args['fromSplash'] == true) {
        Get.offAllNamed(RouteNames.main);
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'SwiftScan is Locked',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticate to continue',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: _authenticate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.fingerprint_rounded, size: 22),
              label: Text(
                'Unlock',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
