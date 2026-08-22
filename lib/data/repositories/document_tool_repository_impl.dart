import 'dart:typed_data';

import 'package:pdf_manipulator/pdf_manipulator.dart' as pm;

import '../../domain/entities/app_document.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/document_tool_repository.dart';
import '../../domain/repositories/entitlement_repository.dart';
import '../services/file_service.dart';
import '../services/image_enhancement_service.dart';
import '../services/mlkit_ocr_service.dart';
import '../services/ocr_complexity_policy.dart';
import '../services/pdf_toolkit_service.dart';

class DocumentToolRepositoryImpl implements DocumentToolRepository {
  DocumentToolRepositoryImpl(
    this._files,
    this._ocr,
    this._ai,
    this._entitlements,
    this._enhancement,
    this._pdf,
    this._ocrComplexity,
  );

  final FileService _files;
  final MlKitOcrService _ocr;
  final AiRepository _ai;
  final EntitlementRepository _entitlements;
  final ImageEnhancementService _enhancement;
  final PdfToolkitService _pdf;
  final OcrComplexityPolicy _ocrComplexity;

  @override
  Future<String> persistImage(String sourcePath, {List<int>? bytes}) =>
      _files.persistImage(
        sourcePath,
        bytes: bytes == null ? null : Uint8List.fromList(bytes),
      );

  @override
  Future<String> extractTextFromImage(
    String imagePath, {
    bool allowCloudArabic = true,
    bool preferHighAccuracy = false,
  }) async {
    final local = await _ocr.extractLatinText(imagePath);
    if (!allowCloudArabic || !_ai.available) return local;
    final requiresCloud = _ocrComplexity.requiresCloud(
      local,
      preferHighAccuracy: preferHighAccuracy,
    );
    if (!requiresCloud || !await _ai.canUseAi()) return local;
    if (!await _entitlements.consumeAiCredit()) return local;
    try {
      // Cloud vision is reserved for complex pages and confirmed connectivity.
      final cloud = await _ai.extractBilingualText(imagePath);
      return cloud.trim().isEmpty ? local : cloud;
    } catch (_) {
      // Local OCR remains available and the failed cloud attempt costs nothing.
      await _entitlements.refundAiCredit();
      return local;
    }
  }

  @override
  Future<String> enhanceImage(String imagePath, String preset) {
    final selected = EnhancementPreset.values.firstWhere(
      (e) => e.name == preset,
      orElse: () => EnhancementPreset.auto,
    );
    return _enhancement.enhance(imagePath, selected);
  }

  @override
  Future<String> rotateImage(String imagePath) =>
      _enhancement.rotateQuarterTurn(imagePath);

  @override
  Future<String> createPdf(AppDocument document, {bool searchable = true}) =>
      _pdf.createFromDocument(document, searchable: searchable);
  @override
  Future<String> imagesToPdf(List<String> imagePaths) =>
      _pdf.imagesToPdf(imagePaths);
  @override
  Future<String> mergePdfs(List<String> pdfPaths) => _pdf.merge(pdfPaths);
  @override
  Future<List<String>> splitPdf(String pdfPath, {int every = 1}) =>
      _pdf.splitByPageCount(pdfPath, every);
  @override
  Future<String> compressPdf(String pdfPath, {int quality = 70}) =>
      _pdf.compress(pdfPath, quality: quality);
  @override
  Future<String> reorderPdf(String pdfPath, List<int> zeroBasedOrder) =>
      _pdf.reorder(pdfPath, zeroBasedOrder);
  @override
  Future<List<String>> pdfToImages(String pdfPath) => _pdf.pdfToImages(pdfPath);
  @override
  Future<String> extractTextFromPdf(String pdfPath) =>
      _pdf.extractText(pdfPath);
  @override
  Future<String> pdfToDocx(String pdfPath) => _pdf.pdfToDocx(pdfPath);
  @override
  Future<String> pdfToXlsx(String pdfPath) => _pdf.pdfToXlsx(pdfPath);
  @override
  Future<String> pdfToPptx(String pdfPath) => _pdf.pdfToPptx(pdfPath);
  @override
  Future<String> docxToPdf(String documentPath) =>
      _pdf.officeToPdf(documentPath, pm.PdfDocumentFormat.docx);
  @override
  Future<String> xlsxToPdf(String documentPath) =>
      _pdf.officeToPdf(documentPath, pm.PdfDocumentFormat.xlsx);
  @override
  Future<String> pptxToPdf(String documentPath) =>
      _pdf.officeToPdf(documentPath, pm.PdfDocumentFormat.pptx);
}
