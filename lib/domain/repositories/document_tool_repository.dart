import '../entities/app_document.dart';

abstract interface class DocumentToolRepository {
  Future<String> persistImage(String sourcePath, {List<int>? bytes});
  Future<String> extractTextFromImage(
    String imagePath, {
    bool allowCloudArabic = true,
    bool preferHighAccuracy = false,
  });
  Future<String> enhanceImage(String imagePath, String preset);
  Future<String> rotateImage(String imagePath);
  Future<String> createPdf(AppDocument document, {bool searchable = true});
  Future<String> imagesToPdf(List<String> imagePaths);
  Future<String> mergePdfs(List<String> pdfPaths);
  Future<List<String>> splitPdf(String pdfPath, {int every = 1});
  Future<String> compressPdf(String pdfPath, {int quality = 70});
  Future<String> reorderPdf(String pdfPath, List<int> zeroBasedOrder);
  Future<List<String>> pdfToImages(String pdfPath);
  Future<String> extractTextFromPdf(String pdfPath);
  Future<String> pdfToDocx(String pdfPath);
  Future<String> pdfToXlsx(String pdfPath);
  Future<String> pdfToPptx(String pdfPath);
  Future<String> docxToPdf(String documentPath);
  Future<String> xlsxToPdf(String documentPath);
  Future<String> pptxToPdf(String documentPath);
}
