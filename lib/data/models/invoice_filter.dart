enum InvoiceFilter { all, month, review, favorites }

class InvoiceFilterOption {
  const InvoiceFilterOption(this.value, this.ar, this.en);

  final InvoiceFilter value;
  final String ar;
  final String en;
}

abstract final class InvoiceFilters {
  static const all = <InvoiceFilterOption>[
    InvoiceFilterOption(InvoiceFilter.all, 'الكل', 'All'),
    InvoiceFilterOption(InvoiceFilter.month, 'هذا الشهر', 'This Month'),
    InvoiceFilterOption(InvoiceFilter.review, 'تحتاج مراجعة', 'Needs Review'),
    InvoiceFilterOption(InvoiceFilter.favorites, 'المفضلة', 'Favorites'),
  ];
}
