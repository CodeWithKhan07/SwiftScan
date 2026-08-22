import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/models/tool_definition.dart';
import '../../domain/usecases/entitlement_usecases.dart';
import 'base/search_state_mixin.dart';

class ToolsController extends GetxController with SearchStateMixin {
  ToolsController(this._entitlements);

  final EntitlementUseCases _entitlements;

  List<ToolDefinition> get visible {
    final value = query.value.trim().toLowerCase();
    if (value.isEmpty) return ToolCatalog.all;

    return ToolCatalog.all
        .where(
          (tool) => '${tool.ar} ${tool.en} ${tool.description}'
              .toLowerCase()
              .contains(value),
        )
        .toList(growable: false);
  }

  List<ToolDefinition> get popular =>
      ToolCatalog.popularIds.map(ToolCatalog.byId).toList(growable: false);

  List<ToolSectionModel> get sections => ToolCatalog.sections
      .map(
        (section) => ToolSectionModel(
          ar: section.ar,
          en: section.en,
          items: visible
              .where((tool) => section.ids.contains(tool.id))
              .toList(growable: false),
        ),
      )
      .where((section) => section.items.isNotEmpty)
      .toList(growable: false);

  void open(ToolId id) {
    final definition = ToolCatalog.byId(id);
    if (definition.pro && !_entitlements.current.isPremium) {
      Get.toNamed(AppRoutes.subscription);
      return;
    }

    Get.toNamed(AppRoutes.conversion, arguments: {'tool': id.name});
  }
}
