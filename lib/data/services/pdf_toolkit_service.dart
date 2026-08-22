import 'dart:io';

import 'package:pdf/pdf.dart' as pdf_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_manipulator/io.dart' as pio;
import 'package:pdf_manipulator/pdf_manipulator.dart' as pm;

import '../../domain/entities/app_document.dart';
import 'file_service.dart';

class PdfToolkitService {
  const PdfToolkitService(this._files);

  final FileService _files;

  Future<String> createFromDocument(
    AppDocument document, {
    bool searchable = true,
  }) async {
    final output = pw.Document();
    for (final page in document.pages) {
      final file = File(page.displayPath);
      if (!await file.exists()) continue;

      final image = pw.MemoryImage(await file.readAsBytes());
      output.addPage(
        pw.Page(
          pageFormat: pdf_core.PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
              if (searchable && page.ocrText.trim().isNotEmpty)
                pw.Positioned(
                  left: 8,
                  right: 8,
                  bottom: 4,
                  child: pw.Opacity(
                    opacity: 0.01,
                    child: pw.Text(
                      page.ocrText,
                      style: const pw.TextStyle(fontSize: 5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final path = await _files.createExportPath(document.title, 'pdf');
    await File(path).writeAsBytes(await output.save(), flush: true);
    return path;
  }

  Future<String> imagesToPdf(List<String> imagePaths) => _writeOutput(
    'images',
    'pdf',
    (pdf, sink) => pdf.imagesToPdf(
      imagePaths.map((path) => pio.FileSource(File(path))).toList(),
      sink,
    ),
  );

  Future<String> merge(List<String> inputs) {
    if (inputs.length < 2) {
      throw ArgumentError('Select at least two PDF files.');
    }
    return _writeOutput(
      'merged',
      'pdf',
      (pdf, sink) => pdf.merge(
        inputs.map((path) => pio.FileSource(File(path))).toList(),
        sink,
      ),
    );
  }

  Future<List<String>> splitByPageCount(String input, int every) async {
    if (every < 1) throw ArgumentError.value(every, 'every');

    final pdf = pm.Pdf();
    final source = pio.FileSource(File(input));
    final document = await pdf.open(source);
    try {
      final outputs = <String>[];
      for (var start = 0; start < document.pageCount; start += every) {
        final end = (start + every).clamp(0, document.pageCount);
        final pages = [for (var page = start; page < end; page++) page];
        final path = await _files.createExportPath(
          'split_${start + 1}_$end',
          'pdf',
        );
        final sink = await pio.FileSink.create(File(path));
        try {
          await pdf.extractPages(source, sink, pages: pages);
        } finally {
          await sink.close();
        }
        outputs.add(path);
      }
      return outputs;
    } finally {
      await document.dispose();
      await pdf.dispose();
    }
  }

  Future<String> compress(String input, {int quality = 70}) => _writeOutput(
    'compressed',
    'pdf',
    (pdf, sink) => pdf.compress(
      pio.FileSource(File(input)),
      sink,
      imageQuality: quality.clamp(20, 100).toInt(),
    ),
  );

  Future<String> reorder(String input, List<int> zeroBasedOrder) =>
      _writeOutput(
        'reordered',
        'pdf',
        (pdf, sink) => pdf.reorderPages(
          pio.FileSource(File(input)),
          sink,
          order: zeroBasedOrder,
        ),
      );

  Future<List<String>> pdfToImages(String input) =>
      _withDocument(input, (document) async {
        final output = <String>[];
        await for (final page in document.render(
          pages: const pm.PdfPages.all(),
          size: const pm.PdfRenderSize.thumbnail(1600),
        )) {
          final path = await _files.createExportPath(
            'pdf_page_${output.length + 1}',
            'png',
          );
          await File(path).writeAsBytes(page.data, flush: true);
          output.add(path);
        }
        return output;
      });

  Future<String> extractText(String input) => _withDocument(
    input,
    (document) async => await document.extract(pages: const pm.PdfPages.all()),
  );

  Future<String> pdfToDocx(String input) =>
      _convertPdf(input, pm.PdfDocumentFormat.docx, 'docx');

  Future<String> pdfToXlsx(String input) =>
      _convertPdf(input, pm.PdfDocumentFormat.xlsx, 'xlsx');

  Future<String> pdfToPptx(String input) =>
      _convertPdf(input, pm.PdfDocumentFormat.pptx, 'pptx');

  Future<String> _convertPdf(
    String input,
    pm.PdfDocumentFormat format,
    String extension,
  ) => _writeOutput(
    'converted',
    extension,
    (pdf, sink) =>
        pdf.convertTo(pio.FileSource(File(input)), sink, format: format),
  );

  Future<String> officeToPdf(String input, pm.PdfDocumentFormat format) =>
      _writeOutput(
        'converted',
        'pdf',
        (pdf, sink) =>
            pdf.convertToPdf(pio.FileSource(File(input)), sink, format: format),
      );

  Future<String> _writeOutput(
    String name,
    String extension,
    Future<void> Function(pm.Pdf pdf, pio.FileSink sink) operation,
  ) async {
    final pdf = pm.Pdf();
    final path = await _files.createExportPath(name, extension);
    final sink = await pio.FileSink.create(File(path));
    try {
      await operation(pdf, sink);
      return path;
    } finally {
      await sink.close();
      await pdf.dispose();
    }
  }

  Future<T> _withDocument<T>(
    String input,
    Future<T> Function(pm.PdfDoc document) operation,
  ) async {
    final pdf = pm.Pdf();
    final document = await pdf.open(pio.FileSource(File(input)));
    try {
      return await operation(document);
    } finally {
      await document.dispose();
      await pdf.dispose();
    }
  }
}
