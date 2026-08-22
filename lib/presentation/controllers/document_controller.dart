import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../domain/usecases/ai_usecases.dart';
import 'base/document_action_controller.dart';

class DocumentController extends DocumentActionController {
  DocumentController(super.documents, super.tools, super.device, this._ai);

  final AiUseCases _ai;

  final showImage = true.obs;
  final aiAnswer = ''.obs;
  final questionController = TextEditingController();
  final cleanInstructionController = TextEditingController(
    text:
        'Fix OCR errors, restore paragraphs and punctuation, remove duplicate lines.',
  );

  void toggleView(bool image) => showImage.value = image;

  bool get isShowingCleanedText =>
      document.value?.cleanedText.trim().isNotEmpty == true;

  String get displayText {
    final current = document.value;
    if (current == null) return '';
    return current.cleanedText.trim().isNotEmpty
        ? current.cleanedText
        : current.extractedText;
  }

  Future<void> toggleFavorite() async {
    final current = document.value;
    if (current == null) return;

    final updated = current.copyWith(
      isFavorite: !current.isFavorite,
      updatedAt: DateTime.now(),
    );
    await documents.save(updated);
    document.value = updated;
  }

  Future<void> copyText() async {
    await device.copy(displayText);
    AppSnackbar.success('Copied / تم النسخ');
  }

  Future<void> shareDisplayedText() => shareText(displayText);

  Future<void> clean() async {
    final current = document.value;
    if (current == null ||
        current.extractedText.trim().isEmpty ||
        isWorking.value) {
      return;
    }

    isWorking.value = true;
    try {
      final cleaned = await _ai.cleanText(
        current.extractedText,
        cleanInstructionController.text.trim(),
      );
      if (cleaned == null) {
        AppSnackbar.info('AI credits unavailable / لا توجد أرصدة AI متاحة');
        return;
      }

      final updated = current.copyWith(
        cleanedText: cleaned,
        updatedAt: DateTime.now(),
      );
      await documents.save(updated);
      document.value = updated;
      showImage.value = false;
    } catch (error) {
      AppSnackbar.error('Text cleanup failed / تعذر تنظيف النص: $error');
    } finally {
      isWorking.value = false;
    }
  }

  Future<void> ask() async {
    final question = questionController.text.trim();
    if (document.value == null || question.isEmpty || isWorking.value) return;

    isWorking.value = true;
    try {
      aiAnswer.value =
          await _ai.askDocument(displayText, question) ??
          'AI credits unavailable / لا توجد أرصدة AI متاحة';
    } catch (error) {
      aiAnswer.value = 'Could not answer / تعذر الرد: $error';
    } finally {
      isWorking.value = false;
    }
  }

  void onMenuSelected(String value) {
    if (value == 'delete') delete();
  }

  Future<void> delete() async {
    final current = document.value;
    if (current == null) return;

    await documents.delete(current.id);
    Get.until((route) => route.settings.name == AppRoutes.shell);
    AppSnackbar.success('Deleted / تم الحذف');
  }

  @override
  void onClose() {
    questionController.dispose();
    cleanInstructionController.dispose();
    super.onClose();
  }
}
