import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

mixin SearchStateMixin on GetxController {
  final query = ''.obs;
  final searchController = TextEditingController();

  void onSearch(String value) => query.value = value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
