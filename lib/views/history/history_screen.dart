import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import '../widgets/history_screen_widgets.dart';
import 'history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HistoryAppBar(),
      body: Column(
        children: [
          const HistorySearch(),
          Expanded(
            child: Obx(() {
              if (controller.groupedScans.isEmpty) {
                return const EmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.groupedScans.length,
                itemBuilder: (context, index) {
                  final label = controller.groupedScans.keys.elementAt(index);
                  final items = controller.groupedScans[label]!;
                  return ScanGroup(label: label, items: items);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
