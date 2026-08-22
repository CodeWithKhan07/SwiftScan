import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../data/models/invoice_filter.dart';
import '../controllers/invoices_controller.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/app_components.dart';

class InvoicesView extends GetView<InvoicesController> {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context) => AppPageBody(
    child: Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: AppScreenTitle('الفواتير', 'Invoices')),
              IconButton.filled(
                onPressed: controller.scan,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSearchField(
            controller: controller.searchController,
            onChanged: controller.onSearch,
            hintText: 'بحث في الفواتير  •  Search invoices',
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.filterOptions
                  .map(
                    (option) => _FilterChip(
                      option: option,
                      selected: controller.isSelected(option.value),
                      onSelected: () => controller.setFilter(option.value),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.visible.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    ar: 'المصروفات',
                    en: 'Expenses',
                    value: AppFormatters.money(
                      controller.totalExpenses,
                      digits: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    ar: 'الضريبة',
                    en: 'VAT',
                    value: AppFormatters.money(controller.totalVat, digits: 0),
                  ),
                ),
              ],
            ),
          const AdBannerSlot(),
          const SizedBox(height: 6),
          Expanded(
            child: controller.visible.isEmpty
                ? AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    ar: 'لا توجد فواتير',
                    en: 'No invoices found',
                    actionAr: 'مسح فاتورة',
                    actionEn: 'Scan Invoice',
                    onAction: controller.scan,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: controller.visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final document = controller.visible[index];
                      return DocumentListTile(
                        document: document,
                        onTap: () => controller.open(document),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final InvoiceFilterOption option;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      label: Text(
        '${option.ar}  ${option.en}',
        style: const TextStyle(fontSize: 14),
      ),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      side: BorderSide(
        color: selected ? AppColors.primary : Theme.of(context).dividerColor,
      ),
    ),
  );
}
