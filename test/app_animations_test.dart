import 'package:fatoralens/presentation/widgets/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('press feedback scales down and returns smoothly', (
    tester,
  ) async {
    // Pointer feedback must remain visual only; the child keeps tap ownership.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppPressScale(
              child: SizedBox(key: ValueKey('target'), width: 100, height: 100),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('target'))),
    );
    await tester.pump(AppMotion.quick);
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      .975,
    );

    await gesture.up();
    await tester.pump(AppMotion.standard);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('reduced motion removes entrance and press animation wrappers', (
    tester,
  ) async {
    // Accessibility settings bypass decorative movement while preserving UI.
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: FadeSlideIn(child: AppPressScale(child: Text('Ready'))),
          ),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
  });

  testWidgets(
    'tab motion never paints the previous and selected pages together',
    (tester) async {
      // A single-paint indexed stack prevents frozen outgoing pages from
      // overlapping the selected page while entrance motion is active.
      final selected = ValueNotifier<int>(0);
      addTearDown(selected.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<int>(
            valueListenable: selected,
            builder: (context, index, _) => AppAnimatedIndexedStack(
              index: index,
              children: const [Text('Home page'), Text('Account page')],
            ),
          ),
        ),
      );

      expect(find.text('Home page'), findsOneWidget);
      expect(find.text('Account page'), findsNothing);

      selected.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(find.text('Home page'), findsNothing);
      expect(find.text('Account page'), findsOneWidget);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1));

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    },
  );
}
