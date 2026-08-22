import 'package:fatoralens/presentation/controllers/scanner_controller.dart';
import 'package:fatoralens/presentation/views/scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scanner controls react without GetX or overflow errors', (
    tester,
  ) async {
    final controller = ScannerController();

    // Reproduce the stale, oversized Android bottom inset from the regression.
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            padding: EdgeInsets.only(top: 24, bottom: 500),
          ),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: ScannerControls(controller: controller),
          ),
        ),
      ),
    );

    expect(find.text('فاتورة\nInvoice'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Updating nested reactive state must rebuild the owning Obx safely.
    controller.mode.value = ScanMode.batch;
    controller.batchPaths.add('page-1.jpg');
    await tester.pump();

    expect(find.text('1 صفحات'), findsOneWidget);
    expect(find.text('1 pages'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Busy state keeps the layout stable while native capture is in progress.
    controller.isCapturing.value = true;
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
