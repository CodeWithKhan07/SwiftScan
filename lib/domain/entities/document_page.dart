class DocumentPage {
  const DocumentPage({
    required this.id,
    required this.originalPath,
    this.processedPath,
    this.ocrText = '',
    this.pageNumber = 1,
    this.rotationQuarterTurns = 0,
  });

  final String id;
  final String originalPath;
  final String? processedPath;
  final String ocrText;
  final int pageNumber;
  final int rotationQuarterTurns;

  String get displayPath => processedPath ?? originalPath;

  DocumentPage copyWith({
    String? id,
    String? originalPath,
    String? processedPath,
    String? ocrText,
    int? pageNumber,
    int? rotationQuarterTurns,
    bool clearProcessedPath = false,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      processedPath: clearProcessedPath
          ? null
          : processedPath ?? this.processedPath,
      ocrText: ocrText ?? this.ocrText,
      pageNumber: pageNumber ?? this.pageNumber,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
    );
  }
}
