import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftscan/views/scandetails/scandetail_controller.dart';

import '../widgets/scan_detail_widgets.dart';

class ScanDetailScreen extends GetView<ScanDetailController> {
  const ScanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScanDetailAppBar(controller: controller),
      body: Obx(
        () => controller.showImage.value
            ? ImageView(controller: controller)
            : TextView(controller: controller),
      ),
      bottomNavigationBar: ActionBar(controller: controller),
    );
  }
}
