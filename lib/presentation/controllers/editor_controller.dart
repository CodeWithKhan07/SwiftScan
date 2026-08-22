import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/app_snackbar.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/usecases/document_usecases.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../../domain/usecases/tool_usecases.dart';

class EditorController extends GetxController {
  EditorController(this._tools, this._invoices, this._documents);

  final ToolUseCases _tools;
  final InvoiceUseCases _invoices;
  final DocumentUseCases _documents;

  final paths = <String>[].obs;
  final currentIndex = 0.obs;
  final currentBytes = Rxn<Uint8List>();
  final loadError = RxnString();
  final cropMode = false.obs;
  final cropReady = false.obs;
  final isProcessing = false.obs;
  final processMessage = 'Preparing / تجهيز'.obs;
  final selectedPreset = 'auto'.obs;
  final croppedBytes = <int, Uint8List>{}.obs;

  final cropController = CropController();
  String kind = 'document';
  int _loadGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments is Map ? Get.arguments as Map : const {};
    paths.assignAll(
      ((args['paths'] as List?) ?? const []).map((value) => value.toString()),
    );
    kind = args['kind']?.toString() ?? 'document';
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final generation = ++_loadGeneration;
    if (paths.isEmpty) {
      currentBytes.value = null;
      loadError.value = 'No pages to preview / لا توجد صفحات للمعاينة';
      return;
    }
    final index = currentIndex.value.clamp(0, paths.length - 1);
    final path = paths[index];
    loadError.value = null;
    currentBytes.value = null;
    try {
      final bytes = croppedBytes[index] ?? await File(path).readAsBytes();
      // Ignore a slow read if the user selected another page meanwhile.
      if (generation == _loadGeneration && currentIndex.value == index) {
        currentBytes.value = bytes;
      }
    } catch (error) {
      if (generation == _loadGeneration) {
        loadError.value =
            'Could not load this page / تعذر تحميل الصفحة: $error';
      }
    }
  }

  Future<void> retryLoadCurrent() => _loadCurrent();

  Future<void> selectPage(int index) async {
    if (index < 0 || index >= paths.length) return;
    currentIndex.value = index;
    cropMode.value = false;
    await _loadCurrent();
  }

  void startCrop() {
    cropReady.value = false;
    cropMode.value = true;
  }

  void cancelCrop() => cropMode.value = false;
  void commitCrop() => cropController.crop();
  void onCropStatus(Object? _) => cropReady.value = true;

  void onCropResult(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        croppedBytes[currentIndex.value] = croppedImage;
        currentBytes.value = croppedImage;
        cropMode.value = false;
      case CropFailure(:final cause):
        AppSnackbar.error('Crop failed / تعذر القص: $cause');
        cropMode.value = false;
    }
  }

  Future<void> applyPreset(String preset) async {
    await _processCurrentImage(
      message: 'Enhancing document / تحسين المستند',
      operation: (source) => _tools.enhanceImage(source, preset),
      before: () => selectedPreset.value = preset,
    );
  }

  Future<void> rotateCurrent() async {
    await _processCurrentImage(
      message: 'Rotating / جاري التدوير',
      operation: _tools.rotateImage,
    );
  }

  Future<void> _processCurrentImage({
    required String message,
    required Future<String> Function(String source) operation,
    void Function()? before,
  }) async {
    if (paths.isEmpty || isProcessing.value) return;

    isProcessing.value = true;
    processMessage.value = message;
    before?.call();

    try {
      var source = paths[currentIndex.value];
      final crop = croppedBytes[currentIndex.value];

      if (crop != null) {
        source = await _tools.persistImage(source, bytes: crop);
        croppedBytes.remove(currentIndex.value);
      }

      paths[currentIndex.value] = await operation(source);
      await _loadCurrent();
    } catch (error) {
      AppSnackbar.error('Image operation failed / تعذرت معالجة الصورة: $error');
    } finally {
      isProcessing.value = false;
    }
  }

  void removeCurrentPage() {
    if (paths.length <= 1) {
      AppSnackbar.info(
        'A document needs at least one page / يجب أن يحتوي المستند على صفحة واحدة',
      );
      return;
    }

    final removedIndex = currentIndex.value;
    paths.removeAt(removedIndex);
    // Reindex pending crops so they continue to match shifted page indexes.
    final reindexed = <int, Uint8List>{};
    for (final entry in croppedBytes.entries) {
      if (entry.key == removedIndex) continue;
      reindexed[entry.key > removedIndex ? entry.key - 1 : entry.key] =
          entry.value;
    }
    croppedBytes.assignAll(reindexed);
    currentIndex.value = currentIndex.value.clamp(0, paths.length - 1).toInt();
    _loadCurrent();
  }

  Future<void> process() async {
    if (paths.isEmpty || isProcessing.value) return;

    isProcessing.value = true;
    try {
      final pages = <DocumentPage>[];
      final texts = <String>[];

      for (var index = 0; index < paths.length; index++) {
        processMessage.value =
            'Reading page ${index + 1}/${paths.length} / قراءة الصفحة ${index + 1}';

        final permanent = await _tools.persistImage(
          paths[index],
          bytes: croppedBytes[index],
        );
        final text = await _tools.extractImageText(
          permanent,
          allowCloudArabic: true,
          // Invoices contain dense bilingual fields where accuracy is critical.
          preferHighAccuracy: kind == 'invoice',
        );

        texts.add(text);
        pages.add(
          DocumentPage(
            id: const Uuid().v4(),
            originalPath: permanent,
            ocrText: text,
            pageNumber: index + 1,
          ),
        );
      }

      final combined = texts
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n--- PAGE ---\n\n');
      final now = DateTime.now();
      final isInvoice = kind == 'invoice';
      final invoice = isInvoice
          ? await _invoices.extract(pages.first.originalPath, combined)
          : null;

      final title = isInvoice
          ? _invoiceTitle(invoice!.sellerNameAr, invoice.sellerName)
          : 'مستند ${now.day}-${now.month} / Document';

      final document = AppDocument(
        id: const Uuid().v4(),
        title: title,
        kind: isInvoice ? DocumentKind.invoice : DocumentKind.document,
        createdAt: now,
        updatedAt: now,
        pages: pages,
        extractedText: combined,
        invoice: invoice,
      );

      await _documents.save(document);
      Get.offNamed(
        isInvoice ? AppRoutes.invoice : AppRoutes.document,
        arguments: document.id,
      );
      AppSnackbar.success('Saved successfully / تم الحفظ بنجاح');
    } catch (error) {
      AppSnackbar.error('Processing failed / تعذرت المعالجة: $error');
    } finally {
      isProcessing.value = false;
    }
  }

  String _invoiceTitle(String arabic, String english) {
    if (arabic.trim().isNotEmpty) return arabic.trim();
    if (english.trim().isNotEmpty) return english.trim();
    return 'فاتورة / Invoice';
  }
}
