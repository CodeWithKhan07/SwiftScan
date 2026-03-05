import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../history/history_screen.dart';
import '../scanner/scanner_screen.dart';
import '../settings/settings_screen.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    const ScannerScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}
