import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swiftscan/core/routes/app_routes.dart';
import 'package:swiftscan/core/utils/app_utils.dart';
import 'package:swiftscan/data/models/scan_model.dart';
import 'package:swiftscan/data/repository/scan_repository.dart';

import '../../core/services/pdf_service.dart'; // Ensure this is imported
import 'package:flutter/material.dart';
import '../widgets/delete_dialog.dart';

class ScanDetailController extends GetxController {
  final ScanRepository _repository;
  final PdfService _pdfService = PdfService(); // Initialize the service

  ScanDetailController(this._repository);

  late final ScanModel scan;
  late final bool isNewScan;

  final RxBool showImage = true.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs; // Track PDF generation state

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      scan = args['scan'] as ScanModel;
      isNewScan = args['isNewScan'] as bool? ?? false;
    } else {
      scan = args as ScanModel;
      isNewScan = false;
    }
    if (isNewScan) {
      showImage.value = false;
    }
  }

  bool get imageExists => File(scan.imagePath).existsSync();

  Future<void> copyText() async {
    await Clipboard.setData(ClipboardData(text: scan.rawText));
    AppUtils.showSuccess(msg: 'Text copied to clipboard');
  }

  Future<void> shareText() async {
    await Share.share(scan.rawText, subject: scan.title);
  }

  Future<void> shareImage() async {
    if (!imageExists) {
      AppUtils.showError(msg: 'Image file not found');
      return;
    }
    await Share.shareXFiles([XFile(scan.imagePath)], subject: scan.title);
  }

  Future<void> translateText() {
    return Future(() {
      Get.toNamed(RouteNames.translation, arguments: scan.rawText);
    });
  }

  Future<void> exportToPdf() async {
    if (isExporting.value) return;

    try {
      isExporting.value = true;

      await _pdfService.generateAndSavePdf(scan);
    } catch (e) {
      AppUtils.showError(msg: 'Failed to generate PDF: $e');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> promptDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteScanDialog(title: scan.title),
    );
    if (confirmed == true) {
      confirmDelete();
    }
  }

  Future<void> confirmDelete() async {
    isDeleting.value = true;
    await _repository.delete(scan.id);
    Get.back();
  }
}
