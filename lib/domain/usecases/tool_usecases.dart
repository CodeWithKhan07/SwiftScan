import '../entities/app_document.dart';
import '../repositories/document_tool_repository.dart';

class ToolUseCases {
  const ToolUseCases(this._repository);

  final DocumentToolRepository _repository;

  Future<String> persistImage(String path, {List<int>? bytes}) =>
      _repository.persistImage(path, bytes: bytes);

  Future<String> extractImageText(
    String path, {
    bool allowCloudArabic = true,
    bool preferHighAccuracy = false,
  }) => _repository.extractTextFromImage(
    path,
    allowCloudArabic: allowCloudArabic,
    preferHighAccuracy: preferHighAccuracy,
  );

  Future<String> enhanceImage(String path, String preset) =>
      _repository.enhanceImage(path, preset);

  Future<String> rotateImage(String path) => _repository.rotateImage(path);

  Future<String> createPdf(AppDocument document, {bool searchable = true}) =>
      _repository.createPdf(document, searchable: searchable);

  Future<String> imagesToPdf(List<String> paths) =>
      _repository.imagesToPdf(paths);

  Future<String> mergePdfs(List<String> paths) => _repository.mergePdfs(paths);

  Future<List<String>> splitPdf(String path, {int every = 1}) =>
      _repository.splitPdf(path, every: every);

  Future<String> compressPdf(String path, {int quality = 70}) =>
      _repository.compressPdf(path, quality: quality);

  Future<String> reorderPdf(String path, List<int> order) =>
      _repository.reorderPdf(path, order);

  Future<List<String>> pdfToImages(String path) =>
      _repository.pdfToImages(path);

  Future<String> extractPdfText(String path) =>
      _repository.extractTextFromPdf(path);

  Future<String> pdfToDocx(String path) => _repository.pdfToDocx(path);
  Future<String> pdfToXlsx(String path) => _repository.pdfToXlsx(path);
  Future<String> pdfToPptx(String path) => _repository.pdfToPptx(path);
  Future<String> docxToPdf(String path) => _repository.docxToPdf(path);
  Future<String> xlsxToPdf(String path) => _repository.xlsxToPdf(path);
  Future<String> pptxToPdf(String path) => _repository.pptxToPdf(path);
}
