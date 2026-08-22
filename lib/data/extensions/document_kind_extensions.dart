import '../../domain/entities/app_document.dart';

extension DocumentKindPresentation on DocumentKind {
  String get bilingualLabel => switch (this) {
    DocumentKind.invoice => 'فاتورة • Invoice',
    DocumentKind.receipt => 'إيصال • Receipt',
    DocumentKind.pdf => 'PDF',
    DocumentKind.image => 'صورة • Image',
    DocumentKind.document => 'مستند • Document',
  };
}
