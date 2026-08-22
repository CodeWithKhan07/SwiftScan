import 'package:fatoralens/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final themeName in ['light', 'dark']) {
    test('$themeName semantic color pairs meet normal-text contrast', () {
      // Primary controls, cards, and secondary copy must remain legible in
      // every supported brightness mode.
      final colors = _themeFor(themeName).colorScheme;
      _expectContrast(colors.primary, colors.onPrimary, 4.5);
      _expectContrast(colors.primaryContainer, colors.onPrimaryContainer, 4.5);
      _expectContrast(colors.surface, colors.onSurface, 4.5);
      _expectContrast(colors.surface, colors.onSurfaceVariant, 4.5);
    });

    test('$themeName theme avoids inaccessible recurring text sizes', () {
      // Supporting copy is no smaller than 13sp and body copy starts at 14sp.
      final text = _themeFor(themeName).textTheme;
      expect(text.labelSmall?.fontSize, greaterThanOrEqualTo(13));
      expect(text.bodySmall?.fontSize, greaterThanOrEqualTo(14));
      expect(text.bodyMedium?.fontSize, greaterThanOrEqualTo(16));
    });
  }
}

ThemeData _themeFor(String themeName) =>
    themeName == 'light' ? AppTheme.light : AppTheme.dark;

void _expectContrast(Color background, Color foreground, double minimum) {
  final lighter = background.computeLuminance() > foreground.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  final darker = background.computeLuminance() > foreground.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  expect((lighter + .05) / (darker + .05), greaterThanOrEqualTo(minimum));
}
