import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/tool_definition.dart';
import '../controllers/tools_controller.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/app_components.dart';

class ToolsView extends GetView<ToolsController> {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageBody(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppScreenTitle('الأدوات', 'Tools'),
            const SizedBox(height: 16),
            AppSearchField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              hintText: 'ابحث عن أداة  •  Search tools',
            ),
            const SizedBox(height: 8),
            const AdBannerSlot(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  if (controller.query.value.isEmpty)
                    _PopularTools(items: controller.popular),
                  ...controller.sections.map(
                    (section) => _ToolSection(section: section),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularTools extends GetView<ToolsController> {
  const _PopularTools({required this.items});

  final List<ToolDefinition> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSectionTitle(ar: 'أدوات شائعة', en: 'Popular Tools'),
      const SizedBox(height: 10),
      SizedBox(
        // Allow both language lines and the icon to fit at accessible scales.
        height: 148,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, index) => _FeaturedTool(items[index]),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class _FeaturedTool extends GetView<ToolsController> {
  const _FeaturedTool(this.definition);

  final ToolDefinition definition;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 158,
    child: AppSurfaceCard(
      onTap: () => controller.open(definition.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(definition.icon, size: 38, iconSize: 20),
          const Spacer(),
          BilingualText(
            definition.ar,
            definition.en,
            arStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            enStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

class _ToolSection extends GetView<ToolsController> {
  const _ToolSection({required this.section});

  final ToolSectionModel section;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSectionTitle(ar: section.ar, en: section.en),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.28,
        ),
        itemCount: section.items.length,
        itemBuilder: (_, index) => _ToolCard(section.items[index]),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class _ToolCard extends GetView<ToolsController> {
  const _ToolCard(this.definition);

  final ToolDefinition definition;

  @override
  Widget build(BuildContext context) => AppSurfaceCard(
    onTap: () => controller.open(definition.id),
    padding: const EdgeInsets.all(13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIconBox(definition.icon, size: 36, iconSize: 19),
            const Spacer(),
            if (definition.pro) const AppProBadge(),
          ],
        ),
        const Spacer(),
        BilingualText(
          definition.ar,
          definition.en,
          arStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          enStyle: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    ),
  );
}
