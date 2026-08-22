import 'document_page.dart';
import 'invoice_data.dart';

enum DocumentKind { invoice, receipt, document, pdf, image }

enum CloudState { local, syncing, synced, failed }

class AppDocument {
  const AppDocument({
    required this.id,
    required this.title,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    this.pages = const [],
    this.extractedText = '',
    this.cleanedText = '',
    this.language = '',
    this.tags = const [],
    this.category = 'General',
    this.isFavorite = false,
    this.cloudState = CloudState.local,
    this.invoice,
    this.exportedPdfPath,
  });

  final String id;
  final String title;
  final DocumentKind kind;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DocumentPage> pages;
  final String extractedText;
  final String cleanedText;
  final String language;
  final List<String> tags;
  final String category;
  final bool isFavorite;
  final CloudState cloudState;
  final InvoiceData? invoice;
  final String? exportedPdfPath;

  String? get thumbnailPath => pages.isEmpty ? null : pages.first.displayPath;

  AppDocument copyWith({
    String? id,
    String? title,
    DocumentKind? kind,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DocumentPage>? pages,
    String? extractedText,
    String? cleanedText,
    String? language,
    List<String>? tags,
    String? category,
    bool? isFavorite,
    CloudState? cloudState,
    InvoiceData? invoice,
    String? exportedPdfPath,
    bool clearInvoice = false,
    bool clearExportedPdfPath = false,
  }) {
    return AppDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pages: pages ?? this.pages,
      extractedText: extractedText ?? this.extractedText,
      cleanedText: cleanedText ?? this.cleanedText,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      cloudState: cloudState ?? this.cloudState,
      invoice: clearInvoice ? null : invoice ?? this.invoice,
      exportedPdfPath: clearExportedPdfPath
          ? null
          : exportedPdfPath ?? this.exportedPdfPath,
    );
  }
}
