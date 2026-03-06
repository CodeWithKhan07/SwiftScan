import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../settings/settings_controller.dart';
import '../widgets/settings_screen_widgets.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          AppearanceGroup(),
          OcrLanguagesGroup(),
          TranslationGroup(),
          PrivacyGroup(),
          DangerGroup(),
        ],
      ),
    );
  }
}
