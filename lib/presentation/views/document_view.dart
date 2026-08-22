import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/app_document.dart';
import '../controllers/document_controller.dart';
import '../widgets/app_animations.dart';
import '../widgets/app_components.dart';

class DocumentView extends GetView<DocumentController> {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final document = controller.document.value;
      return Scaffold(
        appBar: AppBar(
          title: BilingualAppBarTitle(document?.title ?? 'المستند', 'Document'),
          actions: [
            IconButton(
              onPressed: controller.toggleFavorite,
              icon: Icon(
                document?.isFavorite == true
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: document?.isFavorite == true ? AppColors.warning : null,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: controller.onMenuSelected,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('حذف  Delete')),
              ],
            ),
          ],
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : document == null
            ? const AppEmptyState(
                icon: Icons.error_outline_rounded,
                ar: 'المستند غير موجود',
                en: 'Document not found',
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.image_outlined),
                          label: Text('المستند  Document'),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.text_snippet_outlined),
                          label: Text('النص  Text'),
                        ),
                      ],
                      selected: {controller.showImage.value},
                      onSelectionChanged: (values) =>
                          controller.toggleView(values.first),
                    ),
                  ),
                  Expanded(
                    child: controller.showImage.value
                        ? _DocumentPages(document: document)
                        : _TextPane(controller: controller),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Action(
                              icon: Icons.copy_rounded,
                              label: 'Copy',
                              onTap: controller.copyText,
                            ),
                          ),
                          Expanded(
                            child: _Action(
                              icon: Icons.auto_fix_high_rounded,
                              label: 'Clean',
                              onTap: controller.clean,
                            ),
                          ),
                          Expanded(
                            child: _Action(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'PDF',
                              onTap: controller.exportPdf,
                            ),
                          ),
                          Expanded(
                            child: _Action(
                              icon: Icons.share_outlined,
                              label: 'Share',
                              onTap: controller.shareDisplayedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class _DocumentPages extends StatelessWidget {
  const _DocumentPages({required this.document});
  final AppDocument document;
  @override
  Widget build(BuildContext context) => PageView.builder(
    itemCount: document.pages.length,
    itemBuilder: (_, index) {
      final page = document.pages[index];
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Hero(
          tag: index == 0
              ? 'document-${document.id}'
              : 'document-${document.id}-$index',
          child: AppSurfaceCard(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: AppFileImage(path: page.displayPath, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    },
  );
}

class _TextPane extends StatelessWidget {
  const _TextPane({required this.controller});
  final DocumentController controller;
  @override
  Widget build(BuildContext context) {
    final text = controller.displayText;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (controller.isShowingCleanedText)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.accentSurface(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'النص المنظف  •  Cleaned Text',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.onAccentSurface(context),
              ),
            ),
          ),
        AppSurfaceCard(
          child: SelectableText(
            text.isEmpty ? 'No text detected / لم يتم اكتشاف نص' : text,
            // OCR text can differ from the selected app locale.
            textDirection: _directionForText(text),
            style: const TextStyle(height: 1.65, fontSize: 16),
          ),
        ),
        const SizedBox(height: 18),
        const AppSectionTitle(ar: 'اسأل المستند', en: 'Ask Document'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.questionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اكتب سؤالك  •  Ask about this document',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: controller.isWorking.value ? null : controller.ask,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('اسأل المستند   Ask Document'),
        ),
        if (controller.aiAnswer.value.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: SelectableText(
              controller.aiAnswer.value,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ],
    );
  }

  TextDirection _directionForText(String text) {
    final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    final latinCount = RegExp(r'[A-Za-z]').allMatches(text).length;
    return arabicCount > latinCount ? TextDirection.rtl : TextDirection.ltr;
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppPressScale(
    pressedScale: .94,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 23, color: AppColors.accent(context)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
