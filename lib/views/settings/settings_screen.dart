import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../settings/settings_controller.dart';
import '../widgets/settings_screen_widgets.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          OcrLanguagesGroup(),
          TranslationGroup(),
          PrivacyGroup(),
          DangerGroup(),
        ],
      ),
    );
  }
}
