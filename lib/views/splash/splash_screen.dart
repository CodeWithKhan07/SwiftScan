import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDFDFD), Color(0xFFF5F7FA)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 64,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "SwiftScan",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThickProgressBar(),
                  const SizedBox(height: 20),
                  Text(
                    "INITIALIZING",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      letterSpacing: 4.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThickProgressBar() {
    return Container(
      width: 200,
      height: 12,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: const LinearProgressIndicator(
          backgroundColor: Color(0xFFF1F5F9),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          minHeight: 12,
        ),
      ),
    );
  }
}
