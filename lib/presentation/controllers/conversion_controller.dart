import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/models/tool_definition.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../domain/usecases/device_usecases.dart';
import '../../domain/usecases/tool_usecases.dart';

class ConversionController extends GetxController {
  ConversionController(this._tools, this._device, this._ai);

  final ToolUseCases _tools;
  final DeviceActionsUseCase _device;
  final AiUseCases _ai;

  final selectedPaths = <String>[].obs;
  final outputPaths = <String>[].obs;
  final outputText = ''.obs;
  final isWorking = false.obs;
  final progressLabel = ''.obs;
  final quality = 70.0.obs;
  final splitEvery = 1.0.obs;
  final textInputController = TextEditingController();
  final targetLanguageController = TextEditingController(text: 'English');
  final pageOrderController = TextEditingController(text: '1,2,3');
  final ImagePicker _imagePicker = ImagePicker();

  ToolId tool = ToolId.imageToPdf;

  @override
  void onInit() {
    super.onInit();
    final raw = Get.arguments is Map
        ? (Get.arguments as Map)['tool']?.toString()
        : null;
    tool = ToolId.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => ToolId.imageToPdf,
    );
  }

  ToolDefinition get definition => ToolCatalog.byId(tool);

  bool get requiresTextInput =>
      tool == ToolId.cleanText || tool == ToolId.translate;

  bool get usesImages =>
      tool == ToolId.imageToPdf ||
      tool == ToolId.searchablePdf ||
      tool == ToolId.enhanceDocument;

  bool get showQualityControl => tool == ToolId.compressPdf;
  bool get showSplitControl => tool == ToolId.splitPdf;
  bool get showPageOrder => tool == ToolId.reorderPdf;
  bool get showTargetLanguage => tool == ToolId.translate;
  bool get hasResults => outputPaths.isNotEmpty || outputText.value.isNotEmpty;

  Future<void> pickFiles() async {
    if (requiresTextInput) return;

    if (usesImages || tool == ToolId.extractText) {
      final images = await _imagePicker.pickMultiImage(
        limit: tool == ToolId.enhanceDocument ? 1 : 30,
      );
      if (images.isNotEmpty) {
        selectedPaths.assignAll(images.map((image) => image.path));
        return;
      }
      if (tool != ToolId.extractText) return;
    }

    final config = _filePickerConfig();
    final result = await FilePicker.pickFiles(
      allowMultiple: config.$1,
      type: FileType.custom,
      allowedExtensions: config.$2,
    );
    if (result == null) return;
    selectedPaths.assignAll(
      result.files.map((file) => file.path).whereType<String>(),
    );
  }

  (bool, List<String>) _filePickerConfig() => switch (tool) {
    ToolId.mergePdf => (true, const ['pdf']),
    ToolId.docxToPdf => (false, const ['docx']),
    ToolId.xlsxToPdf => (false, const ['xlsx']),
    ToolId.pptxToPdf => (false, const ['pptx']),
    _ => (false, const ['pdf']),
  };

  Future<void> execute() async {
    if (isWorking.value) return;
    if (!requiresTextInput && selectedPaths.isEmpty) {
      AppSnackbar.info('Select a file first / اختر ملفاً أولاً');
      return;
    }

    isWorking.value = true;
    outputPaths.clear();
    outputText.value = '';

    try {
      progressLabel.value = 'Processing / جاري المعالجة';
      await _executeSelectedTool();
      if (outputPaths.isNotEmpty || outputText.isNotEmpty) {
        AppSnackbar.success('Completed / اكتملت العملية');
      }
    } catch (error) {
      AppSnackbar.error('Operation failed / تعذرت العملية: $error');
    } finally {
      isWorking.value = false;
      progressLabel.value = '';
    }
  }

  Future<void> _executeSelectedTool() async {
    switch (tool) {
      case ToolId.imageToPdf:
        outputPaths.add(await _tools.imagesToPdf(selectedPaths));
        break;
      case ToolId.mergePdf:
        outputPaths.add(await _tools.mergePdfs(selectedPaths));
        break;
      case ToolId.splitPdf:
        outputPaths.addAll(
          await _tools.splitPdf(
            selectedPaths.first,
            every: splitEvery.value.round().clamp(1, 100),
          ),
        );
        break;
      case ToolId.compressPdf:
        outputPaths.add(
          await _tools.compressPdf(
            selectedPaths.first,
            quality: quality.value.round(),
          ),
        );
        break;
      case ToolId.reorderPdf:
        outputPaths.add(
          await _tools.reorderPdf(selectedPaths.first, _parseOrder()),
        );
        break;
      case ToolId.pdfToImages:
        outputPaths.addAll(await _tools.pdfToImages(selectedPaths.first));
        break;
      case ToolId.pdfToDocx:
        outputPaths.add(await _tools.pdfToDocx(selectedPaths.first));
        break;
      case ToolId.pdfToXlsx:
        outputPaths.add(await _tools.pdfToXlsx(selectedPaths.first));
        break;
      case ToolId.pdfToPptx:
        outputPaths.add(await _tools.pdfToPptx(selectedPaths.first));
        break;
      case ToolId.docxToPdf:
        outputPaths.add(await _tools.docxToPdf(selectedPaths.first));
        break;
      case ToolId.xlsxToPdf:
        outputPaths.add(await _tools.xlsxToPdf(selectedPaths.first));
        break;
      case ToolId.pptxToPdf:
        outputPaths.add(await _tools.pptxToPdf(selectedPaths.first));
        break;
      case ToolId.extractText:
        outputText.value = await _extractSelectedText();
        break;
      case ToolId.enhanceDocument:
        outputPaths.add(
          await _tools.enhanceImage(selectedPaths.first, 'clearText'),
        );
        break;
      case ToolId.searchablePdf:
        outputPaths.add(await _createSearchablePdf());
        break;
      case ToolId.cleanText:
        outputText.value = await _runAiText(
          () => _ai.cleanText(
            textInputController.text,
            'Fix OCR errors, restore paragraphs and punctuation, and remove duplicate lines.',
          ),
        );
        break;
      case ToolId.translate:
        final target = targetLanguageController.text.trim();
        outputText.value = await _runAiText(
          () => _ai.translate(
            textInputController.text,
            target.isEmpty ? 'English' : target,
          ),
        );
        break;
    }
  }

  Future<String> _extractSelectedText() {
    final path = selectedPaths.first;
    return path.toLowerCase().endsWith('.pdf')
        ? _tools.extractPdfText(path)
        : _tools.extractImageText(path);
  }

  Future<String> _runAiText(Future<String?> Function() action) async {
    final value = await action();
    return value ?? 'AI credits unavailable / لا توجد أرصدة AI متاحة';
  }

  Future<String> _createSearchablePdf() async {
    final pages = <DocumentPage>[];
    for (var index = 0; index < selectedPaths.length; index++) {
      final path = selectedPaths[index];
      pages.add(
        DocumentPage(
          id: const Uuid().v4(),
          originalPath: path,
          ocrText: await _tools.extractImageText(path),
          pageNumber: index + 1,
        ),
      );
    }

    final now = DateTime.now();
    return _tools.createPdf(
      AppDocument(
        id: const Uuid().v4(),
        title: 'Searchable_Document',
        kind: DocumentKind.document,
        createdAt: now,
        updatedAt: now,
        pages: pages,
        extractedText: pages.map((page) => page.ocrText).join('\n\n'),
      ),
      searchable: true,
    );
  }

  List<int> _parseOrder() {
    final values = pageOrderController.text
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .map((value) => value - 1)
        .where((value) => value >= 0)
        .toList(growable: false);

    if (values.isEmpty) {
      throw const FormatException('Enter page order like 1,3,2.');
    }
    return values;
  }

  Future<void> shareOutputs() async {
    if (outputPaths.isNotEmpty) {
      await _device.shareFiles(outputPaths, text: definition.en);
      return;
    }
    if (outputText.value.isNotEmpty) {
      await _device.shareText(outputText.value, subject: definition.en);
    }
  }

  Future<void> copyOutput() async {
    if (outputText.value.isEmpty) return;
    await _device.copy(outputText.value);
    AppSnackbar.success('Copied / تم النسخ');
  }

  @override
  void onClose() {
    textInputController.dispose();
    targetLanguageController.dispose();
    pageOrderController.dispose();
    super.onClose();
  }
}
