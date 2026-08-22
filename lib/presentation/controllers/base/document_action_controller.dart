import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../domain/entities/app_document.dart';
import '../../../domain/usecases/device_usecases.dart';
import '../../../domain/usecases/document_usecases.dart';
import '../../../domain/usecases/tool_usecases.dart';

abstract class DocumentActionController extends GetxController {
  DocumentActionController(this.documents, this.tools, this.device);

  final DocumentUseCases documents;
  final ToolUseCases tools;
  final DeviceActionsUseCase device;

  final document = Rxn<AppDocument>();
  final isLoading = true.obs;
  final isWorking = false.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    isLoading.value = true;
    try {
      final loaded = await documents.getById(Get.arguments?.toString() ?? '');
      document.value = loaded;
      await onDocumentLoaded(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onDocumentLoaded(AppDocument? value) async {}

  Future<void> shareText(String text) async {
    final current = document.value;
    if (current == null || text.trim().isEmpty) return;
    await device.shareText(text, subject: current.title);
  }

  Future<void> exportPdf({bool persistPath = true}) async {
    final current = document.value;
    if (current == null || isWorking.value) return;

    isWorking.value = true;
    try {
      final path = await tools.createPdf(current, searchable: true);
      if (persistPath) {
        final updated = current.copyWith(
          exportedPdfPath: path,
          updatedAt: DateTime.now(),
        );
        await documents.save(updated);
        document.value = updated;
      }
      await device.shareFiles([path], subject: current.title);
    } catch (error) {
      AppSnackbar.error('PDF export failed / تعذر تصدير PDF: $error');
    } finally {
      isWorking.value = false;
    }
  }
}
