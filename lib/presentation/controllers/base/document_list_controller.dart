import 'dart:async';

import 'package:get/get.dart';

import '../../../domain/entities/app_document.dart';
import '../../../domain/usecases/document_usecases.dart';

abstract class DocumentListController extends GetxController {
  DocumentListController(this.documentsUseCases);

  final DocumentUseCases documentsUseCases;
  final documents = <AppDocument>[].obs;
  StreamSubscription<List<AppDocument>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = documentsUseCases.watchAll().listen(documents.assignAll);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
