import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/translation_screen_widgets.dart';
import 'translation_controller.dart';

class TranslationScreen extends GetView<TranslationController> {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TranslationAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: const [
            LanguageSelectorRow(),
            SizedBox(height: 16),
            ModelStatusBanner(),
            SizedBox(height: 16),
            InputCard(),
            SizedBox(height: 12),
            TranslateButton(),
            SizedBox(height: 12),
            OutputCard(),
          ],
        ),
      ),
    );
  }
}
