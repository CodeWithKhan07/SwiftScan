import '../../domain/entities/app_document.dart';
import '../../domain/entities/document_page.dart';
import 'invoice_mapper.dart';
import 'map_value.dart';

class DocumentMapper {
  const DocumentMapper();

  AppDocument fromMap(Map<String, dynamic> map) {
    return AppDocument(
      id: MapValue.string(map['id']),
      title: MapValue.string(map['title'], fallback: 'Document'),
      kind: MapValue.enumValue(
        DocumentKind.values,
        map['kind'],
        DocumentKind.document,
      ),
      createdAt: MapValue.date(map['createdAt']),
      updatedAt: MapValue.date(map['updatedAt']),
      pages: _pages(map['pages']),
      extractedText: MapValue.string(map['extractedText']),
      cleanedText: MapValue.string(map['cleanedText']),
      language: MapValue.string(map['language']),
      tags: MapValue.strings(map['tags']),
      category: MapValue.string(map['category'], fallback: 'General'),
      isFavorite: map['isFavorite'] == true,
      cloudState: MapValue.enumValue(
        CloudState.values,
        map['cloudState'],
        CloudState.local,
      ),
      invoice: map['invoice'] is Map
          ? InvoiceMapper.fromMap(
              Map<String, dynamic>.from(map['invoice'] as Map),
            )
          : null,
      exportedPdfPath: MapValue.nullableString(map['exportedPdfPath']),
    );
  }

  Map<String, dynamic> toMap(AppDocument document) {
    return {
      'id': document.id,
      'title': document.title,
      'kind': document.kind.name,
      'createdAt': document.createdAt.toIso8601String(),
      'updatedAt': document.updatedAt.toIso8601String(),
      'pages': document.pages.map(_pageToMap).toList(growable: false),
      'extractedText': document.extractedText,
      'cleanedText': document.cleanedText,
      'language': document.language,
      'tags': document.tags,
      'category': document.category,
      'isFavorite': document.isFavorite,
      'cloudState': document.cloudState.name,
      'invoice': document.invoice == null
          ? null
          : InvoiceMapper.toMap(document.invoice!),
      'exportedPdfPath': document.exportedPdfPath,
    };
  }

  List<DocumentPage> _pages(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => _pageFromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  DocumentPage _pageFromMap(Map<String, dynamic> map) {
    return DocumentPage(
      id: MapValue.string(map['id']),
      originalPath: MapValue.string(map['originalPath']),
      processedPath: MapValue.nullableString(map['processedPath']),
      ocrText: MapValue.string(map['ocrText']),
      pageNumber: MapValue.integer(map['pageNumber'], fallback: 1),
      rotationQuarterTurns: MapValue.integer(map['rotationQuarterTurns']),
    );
  }

  Map<String, dynamic> _pageToMap(DocumentPage page) {
    return {
      'id': page.id,
      'originalPath': page.originalPath,
      'processedPath': page.processedPath,
      'ocrText': page.ocrText,
      'pageNumber': page.pageNumber,
      'rotationQuarterTurns': page.rotationQuarterTurns,
    };
  }
}
