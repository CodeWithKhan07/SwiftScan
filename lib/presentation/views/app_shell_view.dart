import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_shell_controller.dart';
import '../widgets/app_animations.dart';
import '../widgets/app_components.dart';
import 'account_view.dart';
import 'home_view.dart';
import 'invoices_view.dart';
import 'tools_view.dart';

class AppShellView extends GetView<AppShellController> {
  const AppShellView({super.key});

  static const _pages = [
    HomeView(),
    InvoicesView(),
    ToolsView(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = controller.currentIndex.value;
    // The shell is the single full-screen owner of page body and bottom nav.
    return SizedBox.expand(
      child: Scaffold(
        body: AppAnimatedIndexedStack(index: selected, children: _pages),
        bottomNavigationBar: _BottomBar(controller: controller),
      ),
    );
  });
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final AppShellController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.currentIndex.value;
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final accessibilityHeight =
        104.0 + ((textScale - 1).clamp(0.0, 1.0) * 36.0);
    return SizedBox(
      // The Android activity already excludes the system navigation region.
      // A fixed bar prevents an incorrect bottom MediaQuery padding value from
      // consuming the lower half of the Scaffold and collapsing its page body.
      height: accessibilityHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: BilingualIconAction(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  ar: 'الرئيسية',
                  en: 'Home',
                  selected: selected == 0,
                  horizontalPadding: 2,
                  onTap: () => controller.selectTab(0),
                ),
              ),
              Expanded(
                child: BilingualIconAction(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  ar: 'الفواتير',
                  en: 'Invoices',
                  selected: selected == 1,
                  horizontalPadding: 2,
                  onTap: () => controller.selectTab(1),
                ),
              ),
              Expanded(
                child: Center(
                  child: Semantics(
                    label: 'Scan / مسح',
                    button: true,
                    child: AppPressScale(
                      child: InkWell(
                        onTap: controller.openScanner,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .24),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.document_scanner_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 29,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BilingualIconAction(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  ar: 'الأدوات',
                  en: 'Tools',
                  selected: selected == 2,
                  horizontalPadding: 2,
                  onTap: () => controller.selectTab(2),
                ),
              ),
              Expanded(
                child: BilingualIconAction(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  ar: 'الحساب',
                  en: 'Account',
                  selected: selected == 3,
                  horizontalPadding: 2,
                  onTap: () => controller.selectTab(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
