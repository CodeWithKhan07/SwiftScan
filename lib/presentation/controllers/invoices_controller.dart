import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/extensions/document_collection_extensions.dart';
import '../../data/models/invoice_filter.dart';
import '../../domain/entities/app_document.dart';
import 'base/document_list_controller.dart';
import 'base/search_state_mixin.dart';

class InvoicesController extends DocumentListController with SearchStateMixin {
  InvoicesController(super.documentsUseCases);

  final filter = InvoiceFilter.all.obs;

  List<InvoiceFilterOption> get filterOptions => InvoiceFilters.all;

  List<AppDocument> get visible {
    final search = query.value.trim().toLowerCase();
    final now = DateTime.now();

    return documents
        .where((document) {
          final invoice = document.invoice;
          if (invoice == null) return false;

          final passesFilter = switch (filter.value) {
            InvoiceFilter.month =>
              document.createdAt.year == now.year &&
                  document.createdAt.month == now.month,
            InvoiceFilter.review => invoice.needsReview,
            InvoiceFilter.favorites => document.isFavorite,
            InvoiceFilter.all => true,
          };

          if (!passesFilter) return false;
          if (search.isEmpty) return true;

          return '${document.title} ${invoice.sellerName} '
                  '${invoice.sellerNameAr} ${invoice.invoiceNumber} '
                  '${invoice.vatNumber} ${document.extractedText}'
              .toLowerCase()
              .contains(search);
        })
        .toList(growable: false);
  }

  double get totalExpenses => visible.invoiceTotal;
  double get totalVat => visible.vatTotal;

  bool isSelected(InvoiceFilter value) => filter.value == value;

  void setFilter(InvoiceFilter value) => filter.value = value;
  void open(AppDocument document) =>
      Get.toNamed(AppRoutes.invoice, arguments: document.id);
  void scan() => Get.toNamed(AppRoutes.scanner, arguments: {'mode': 'invoice'});
}
