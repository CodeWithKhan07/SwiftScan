import 'package:flutter/material.dart';

enum ToolId {
  imageToPdf,
  mergePdf,
  splitPdf,
  compressPdf,
  reorderPdf,
  pdfToImages,
  extractText,
  searchablePdf,
  enhanceDocument,
  cleanText,
  translate,
  pdfToDocx,
  pdfToXlsx,
  pdfToPptx,
  docxToPdf,
  xlsxToPdf,
  pptxToPdf,
}

class ToolDefinition {
  const ToolDefinition(
    this.id,
    this.ar,
    this.en,
    this.icon, {
    this.pro = false,
    this.description = '',
  });

  final ToolId id;
  final String ar;
  final String en;
  final IconData icon;
  final bool pro;
  final String description;
}

class ToolSectionDefinition {
  const ToolSectionDefinition({
    required this.ar,
    required this.en,
    required this.ids,
  });

  final String ar;
  final String en;
  final Set<ToolId> ids;
}

class ToolSectionModel {
  const ToolSectionModel({
    required this.ar,
    required this.en,
    required this.items,
  });

  final String ar;
  final String en;
  final List<ToolDefinition> items;
}

abstract final class ToolCatalog {
  static const all = <ToolDefinition>[
    ToolDefinition(
      ToolId.imageToPdf,
      'صورة إلى PDF',
      'Image to PDF',
      Icons.picture_as_pdf_outlined,
      description: 'Create a PDF from one or more images',
    ),
    ToolDefinition(
      ToolId.mergePdf,
      'دمج PDF',
      'Merge PDF',
      Icons.merge_type_rounded,
    ),
    ToolDefinition(
      ToolId.splitPdf,
      'تقسيم PDF',
      'Split PDF',
      Icons.call_split_rounded,
    ),
    ToolDefinition(
      ToolId.compressPdf,
      'ضغط PDF',
      'Compress PDF',
      Icons.compress_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.reorderPdf,
      'ترتيب الصفحات',
      'Reorder Pages',
      Icons.reorder_rounded,
    ),
    ToolDefinition(
      ToolId.pdfToImages,
      'PDF إلى صور',
      'PDF to Images',
      Icons.image_outlined,
    ),
    ToolDefinition(
      ToolId.extractText,
      'استخراج النص',
      'Extract Text',
      Icons.text_snippet_outlined,
    ),
    ToolDefinition(
      ToolId.searchablePdf,
      'PDF قابل للبحث',
      'Searchable PDF',
      Icons.manage_search_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.enhanceDocument,
      'تحسين مستند',
      'Enhance Document',
      Icons.auto_fix_high_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.cleanText,
      'تنظيف النص',
      'Clean Text',
      Icons.format_clear_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.translate,
      'ترجمة',
      'Translate',
      Icons.translate_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.pdfToDocx,
      'PDF إلى Word',
      'PDF to Word',
      Icons.description_outlined,
      pro: true,
    ),
    ToolDefinition(
      ToolId.pdfToXlsx,
      'PDF إلى Excel',
      'PDF to Excel',
      Icons.table_chart_outlined,
      pro: true,
    ),
    ToolDefinition(
      ToolId.pdfToPptx,
      'PDF إلى PowerPoint',
      'PDF to PowerPoint',
      Icons.slideshow_outlined,
      pro: true,
    ),
    ToolDefinition(
      ToolId.docxToPdf,
      'Word إلى PDF',
      'Word to PDF',
      Icons.picture_as_pdf_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.xlsxToPdf,
      'Excel إلى PDF',
      'Excel to PDF',
      Icons.picture_as_pdf_rounded,
      pro: true,
    ),
    ToolDefinition(
      ToolId.pptxToPdf,
      'PowerPoint إلى PDF',
      'PowerPoint to PDF',
      Icons.picture_as_pdf_rounded,
      pro: true,
    ),
  ];

  static ToolDefinition byId(ToolId id) =>
      all.firstWhere((tool) => tool.id == id);

  static const sections = <ToolSectionDefinition>[
    ToolSectionDefinition(
      ar: 'أدوات PDF',
      en: 'PDF Tools',
      ids: <ToolId>{
        ToolId.imageToPdf,
        ToolId.mergePdf,
        ToolId.splitPdf,
        ToolId.compressPdf,
        ToolId.reorderPdf,
        ToolId.pdfToImages,
        ToolId.searchablePdf,
      },
    ),
    ToolSectionDefinition(
      ar: 'النص والمستندات',
      en: 'Text & Documents',
      ids: <ToolId>{
        ToolId.extractText,
        ToolId.cleanText,
        ToolId.translate,
        ToolId.enhanceDocument,
      },
    ),
    ToolSectionDefinition(
      ar: 'التحويل',
      en: 'Conversion',
      ids: <ToolId>{
        ToolId.pdfToDocx,
        ToolId.pdfToXlsx,
        ToolId.pdfToPptx,
        ToolId.docxToPdf,
        ToolId.xlsxToPdf,
        ToolId.pptxToPdf,
      },
    ),
  ];

  static const popularIds = <ToolId>[
    ToolId.imageToPdf,
    ToolId.extractText,
    ToolId.enhanceDocument,
  ];
}
