import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/config/app_config.dart';
import '../../core/extensions/document_collection_extensions.dart';
import '../../data/models/tool_definition.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/usecases/entitlement_usecases.dart';
import 'base/document_list_controller.dart';

class HomeController extends DocumentListController {
  HomeController(super.documentsUseCases, this._entitlements);

  final EntitlementUseCases _entitlements;

  List<AppDocument> get recent => documents.take(5).toList(growable: false);

  List<AppDocument> get currentMonthInvoices =>
      documents.invoicesForMonth(DateTime.now());

  double get monthlyExpenses => currentMonthInvoices.invoiceTotal;
  double get monthlyVat => currentMonthInvoices.vatTotal;

  void primaryScan() => AppConfig.isKsa ? scanInvoice() : scanDocument();

  void scanInvoice() =>
      Get.toNamed(AppRoutes.scanner, arguments: {'mode': 'invoice'});

  void scanDocument() =>
      Get.toNamed(AppRoutes.scanner, arguments: {'mode': 'document'});

  void scanQr() {
    if (AppConfig.supportsZatca) Get.toNamed(AppRoutes.qr);
  }

  void _openTool(ToolId id) {
    final definition = ToolCatalog.byId(id);

    if (definition.pro && !_entitlements.current.isPremium) {
      Get.toNamed(AppRoutes.subscription);
      return;
    }

    Get.toNamed(AppRoutes.conversion, arguments: {'tool': id.name});
  }

  void openImageToPdf() => _openTool(ToolId.imageToPdf);

  void openEnhanceDocument() => _openTool(ToolId.enhanceDocument);

  void openDocument(AppDocument document) {
    Get.toNamed(
      document.invoice == null ? AppRoutes.document : AppRoutes.invoice,
      arguments: document.id,
    );
  }
}
