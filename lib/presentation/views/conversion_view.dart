import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/extensions/path_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/conversion_controller.dart';
import '../widgets/app_components.dart';

class ConversionView extends GetView<ConversionController> {
  const ConversionView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final definition = controller.definition;
    return Scaffold(
      appBar: AppBar(title: BilingualAppBarTitle(definition.ar, definition.en)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              AppSurfaceCard(
                child: Row(
                  children: [
                    AppIconBox(definition.icon, size: 48, iconSize: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BilingualText(definition.ar, definition.en),
                    ),
                    if (definition.pro) const AppProBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              controller.requiresTextInput
                  ? _TextInput(controller: controller)
                  : _FileInput(controller: controller),
              if (controller.showQualityControl) ...[
                const SizedBox(height: 16),
                _SliderCard(
                  ar: 'جودة الصور',
                  en: 'Image Quality',
                  value: controller.quality.value,
                  min: 30,
                  max: 95,
                  divisions: 13,
                  label: '${controller.quality.value.round()}%',
                  onChanged: (value) => controller.quality.value = value,
                ),
              ],
              if (controller.showSplitControl) ...[
                const SizedBox(height: 16),
                _SliderCard(
                  ar: 'عدد الصفحات لكل ملف',
                  en: 'Pages per output',
                  value: controller.splitEvery.value,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${controller.splitEvery.value.round()}',
                  onChanged: (value) => controller.splitEvery.value = value,
                ),
              ],
              if (controller.showPageOrder) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: controller.pageOrderController,
                  decoration: const InputDecoration(
                    labelText: 'ترتيب الصفحات  •  Page order',
                    hintText: '1,3,2,4',
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.isWorking.value
                    ? null
                    : controller.execute,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('تشغيل الأداة   Run Tool'),
              ),
              if (controller.hasResults) ...[
                const SizedBox(height: 20),
                const AppSectionTitle(ar: 'النتيجة', en: 'Result'),
                const SizedBox(height: 10),
                if (controller.outputText.value.isNotEmpty)
                  AppSurfaceCard(
                    child: SelectableText(
                      controller.outputText.value,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                ...controller.outputPaths.map(
                  (path) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AppSurfaceCard(
                      child: AppFileRow(
                        name: path.fileName,
                        trailing: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (controller.outputText.value.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.copyOutput,
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('نسخ  Copy'),
                        ),
                      ),
                    if (controller.outputText.value.isNotEmpty)
                      const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.shareOutputs,
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('مشاركة  Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (controller.isWorking.value)
            AppProcessingOverlay(
              label: controller.progressLabel.value,
              detail: '',
            ),
        ],
      ),
    );
  });
}

class _FileInput extends StatelessWidget {
  const _FileInput({required this.controller});

  final ConversionController controller;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BilingualText('الملفات', 'Files'),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: controller.pickFiles,
          icon: const Icon(Icons.add_rounded),
          label: const Text('اختيار الملفات   Select Files'),
        ),
        if (controller.selectedPaths.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...controller.selectedPaths
              .take(10)
              .map(
                (path) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AppFileRow(
                    name: path.fileName,
                    leadingIcon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ),
        ],
      ],
    ),
  );
}

class _TextInput extends StatelessWidget {
  const _TextInput({required this.controller});

  final ConversionController controller;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: controller.textInputController,
        minLines: 8,
        maxLines: 16,
        decoration: const InputDecoration(
          hintText: 'ألصق النص هنا  •  Paste text here',
          alignLabelWithHint: true,
        ),
      ),
      if (controller.showTargetLanguage) ...[
        const SizedBox(height: 10),
        TextField(
          controller: controller.targetLanguageController,
          decoration: const InputDecoration(
            labelText: 'اللغة المستهدفة  •  Target Language',
          ),
        ),
      ],
    ],
  );
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.ar,
    required this.en,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final String ar;
  final String en;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualText(ar, en),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
