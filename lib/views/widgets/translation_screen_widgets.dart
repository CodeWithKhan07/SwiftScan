import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/resources/theme/app_theme.dart';
import '../translation/translation_controller.dart';

class TranslationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TranslationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textHeader,
          size: 20,
        ),
        onPressed: Get.back,
      ),
      title: Text(
        'Translate',
        style: textTheme.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
}

class LanguageSelectorRow extends GetView<TranslationController> {
  const LanguageSelectorRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: LanguageDropdown(
              label: 'From',
              selectedCode: controller.sourceCode.value,
              onSelected: controller.setSource,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: controller.swapLanguages,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: LanguageDropdown(
              label: 'To',
              selectedCode: controller.targetCode.value,
              onSelected: controller.setTarget,
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageDropdown extends GetView<TranslationController> {
  const LanguageDropdown({
    super.key,
    required this.label,
    required this.selectedCode,
    required this.onSelected,
  });

  final String label;
  final String selectedCode;
  final Future<void> Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.07),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: AppColors.textBody.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.labelFor(selectedCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textBody.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguagePickerSheet(
        title: 'Select $label Language',
        selectedCode: selectedCode,
        onSelected: (code) {
          onSelected(code);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({
    super.key,
    required this.title,
    required this.selectedCode,
    required this.onSelected,
  });

  final String title;
  final String selectedCode;
  final void Function(String code) onSelected;

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  String _query = '';

  List<({String code, String label})> get _filtered => kTranslationLanguages
      .where(
        (l) =>
            l.label.toLowerCase().contains(_query.toLowerCase()) ||
            l.code.toLowerCase().contains(_query.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search language…',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textBody.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.textBody.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 8),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final lang = _filtered[i];
                final isSelected = lang.code == widget.selectedCode;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    lang.label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textHeader,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () => widget.onSelected(lang.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ModelStatusBanner extends GetView<TranslationController> {
  const ModelStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final status = controller.modelStatus.value;
      final msg = controller.statusMessage.value;

      if (status == ModelStatus.ready || msg.isEmpty) {
        return const SizedBox.shrink();
      }

      final isError = status == ModelStatus.failed;
      final isLoading = status == ModelStatus.downloading;
      final color = isError ? AppColors.error : AppColors.primary;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              )
            else
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                size: 16,
                color: color,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isLoading)
              TextButton(
                onPressed: controller.downloadModel,
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isError ? 'Retry' : 'Download',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class InputCard extends StatefulWidget {
  const InputCard({super.key});

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> {
  late final TranslationController controller;
  late final TextEditingController textController;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TranslationController>();
    textController = TextEditingController(text: controller.inputText.value);
    _worker = ever(controller.inputText, (val) {
      if (textController.text != val) textController.text = val;
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Obx(
              () => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.labelFor(controller.sourceCode.value),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (controller.inputText.value.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        textController.clear();
                        controller.clearAll();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textBody.withValues(alpha: 0.4),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: textController,
              onChanged: (v) => controller.inputText.value = v,
              maxLines: 6,
              minLines: 4,
              style: textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Enter text to translate…',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.textBody.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(
              () => Text(
                '${controller.inputText.value.length} characters',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.textBody.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TranslateButton extends GetView<TranslationController> {
  const TranslateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: controller.isTranslating.value
              ? null
              : controller.translate,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: controller.isTranslating.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.g_translate_rounded, size: 18),
          label: Text(
            controller.isTranslating.value ? 'Translating…' : 'Translate',
            style: textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class OutputCard extends GetView<TranslationController> {
  const OutputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final text = controller.translatedText.value;

      return AnimatedOpacity(
        opacity: text.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: text.isEmpty
            ? const SizedBox.shrink()
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.labelFor(
                                    controller.targetCode.value,
                                  ),
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconAction(
                            icon: Icons.copy_rounded,
                            tooltip: 'Copy',
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: text),
                              );
                              Get.snackbar(
                                '',
                                '',
                                titleText: const SizedBox.shrink(),
                                messageText: Text(
                                  'Translation copied',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: SelectableText(
                        text,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: AppColors.textBody.withValues(alpha: 0.5),
      ),
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}
