import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_translations.dart';
import '../../data/extensions/document_kind_extensions.dart';
import '../../domain/entities/app_document.dart';
import '../controllers/app_locale_controller.dart';
import 'app_animations.dart';

final _localizedUiStrings = AppTranslations().keys;

class BilingualText extends StatelessWidget {
  const BilingualText(
    this.ar,
    this.en, {
    super.key,
    this.arStyle,
    this.enStyle,
    this.align = TextAlign.start,
    this.spacing = 2,
    this.maxLines,
  });
  final String ar;
  final String en;
  final TextStyle? arStyle;
  final TextStyle? enStyle;
  final TextAlign align;
  final double spacing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Get.isRegistered<AppLocaleController>()
        ? Get.find<AppLocaleController>()
        : null;

    if (locale == null) return _buildLegacyBilingual(theme);
    return Obx(() {
      if (locale.showsBothLanguages) {
        return _buildLanguagePair(
          theme,
          locale.primaryLanguage.value,
          locale.secondaryLanguage.value,
        );
      }

      return _languageText(theme, locale.primaryLanguage.value);
    });
  }

  // KSA renders the exact ordered language pair selected by the user.
  Widget _buildLanguagePair(
    ThemeData theme,
    AppLanguage primary,
    AppLanguage secondary,
  ) => Column(
    crossAxisAlignment: align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      _languageText(theme, primary),
      SizedBox(height: spacing),
      _languageText(theme, secondary),
    ],
  );

  // Tests and isolated widgets without the locale controller retain the KSA
  // Arabic/English fallback instead of depending on global GetX state.
  Widget _buildLegacyBilingual(ThemeData theme) =>
      _buildLanguagePair(theme, AppLanguage.arabic, AppLanguage.english);

  Widget _languageText(ThemeData theme, AppLanguage language) {
    final isArabic = language == AppLanguage.arabic;
    final locale = language.locale;
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    final value = isArabic ? ar : (_localizedUiStrings[localeKey]?[en] ?? en);
    final fallbackStyle = isArabic
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );
    return Text(
      value,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: align,
      textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      style: _withMinimumSize(
        (isArabic ? arStyle : enStyle) ?? fallbackStyle,
        isArabic ? 15.5 : 14,
      ),
    );
  }

  TextStyle _withMinimumSize(TextStyle? style, double minimum) {
    final current = style?.fontSize ?? minimum;
    return (style ?? const TextStyle()).copyWith(
      fontSize: current < minimum ? minimum : current,
    );
  }
}

/// Compact two-line label that keeps Arabic and Latin direction independent.
class BilingualButtonLabel extends StatelessWidget {
  const BilingualButtonLabel(this.ar, this.en, {super.key});

  final String ar;
  final String en;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    // Button labels follow the same ordered single/dual KSA language contract.
    return BilingualText(
      ar,
      en,
      maxLines: 1,
      align: TextAlign.center,
      spacing: 0,
      arStyle: style.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
      enStyle: style.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.ar,
    required this.en,
    this.action,
    this.onAction,
  });
  final String ar;
  final String en;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: BilingualText(ar, en)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: const Color(0xFF1F4F9A).withValues(alpha: .035),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return AppPressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: card,
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.ar,
    required this.en,
    required this.onTap,
    this.description,
  });
  final IconData icon;
  final String ar;
  final String en;
  final String? description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(icon),
          const SizedBox(height: 12),
          BilingualText(ar, en, maxLines: 1),
          if (description?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.ar,
    required this.en,
    required this.value,
    this.icon,
  });
  final String ar;
  final String en;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: AppColors.accent(context)),
          if (icon != null) const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.accent(context),
            ),
          ),
          const SizedBox(height: 4),
          BilingualText(
            ar,
            en,
            arStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            enStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    super.key,
    required this.document,
    required this.onTap,
  });
  final AppDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final invoice = document.invoice;
    return AppSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Hero(
            tag: 'document-${document.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                width: 58,
                height: 70,
                child: _thumbnail(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  document.kind.bilingualLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.documentDate(document.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (invoice != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.money(
                    invoice.total,
                    currency: invoice.currency,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent(context),
                  ),
                ),
                const SizedBox(height: 6),
                _StatusChip(review: invoice.needsReview),
              ],
            )
          else
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.secondaryText(context),
            ),
        ],
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    final path = document.thumbnailPath;
    if (path == null) return const DocumentPlaceholder();
    return AppFileImage(path: path, fallback: const DocumentPlaceholder());
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.review});
  final bool review;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: review
          ? AppColors.warning.withValues(alpha: .10)
          : AppColors.success.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      review ? 'Review' : 'Verified',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: review ? AppColors.warning : AppColors.success,
      ),
    ),
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.ar,
    required this.en,
    this.actionAr,
    this.actionEn,
    this.onAction,
  });
  final IconData icon;
  final String ar;
  final String en;
  final String? actionAr;
  final String? actionEn;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    // Empty states remain usable inside short lists and split-screen layouts.
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconBox(icon, size: 64, iconSize: 30),
          const SizedBox(height: 18),
          BilingualText(ar, en, align: TextAlign.center),
          if (onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              child: Text('${actionAr ?? ''}  ${actionEn ?? ''}'),
            ),
          ],
        ],
      ),
    ),
  );
}

class BilingualAppBarTitle extends StatelessWidget {
  const BilingualAppBarTitle(this.ar, this.en, {super.key});
  final String ar;
  final String en;
  @override
  Widget build(BuildContext context) => BilingualText(
    ar,
    en,
    arStyle: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    enStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 0),
    this.bottomSafeArea = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: bottomSafeArea,
    child: Padding(padding: padding, child: child),
  );
}

class AppScreenTitle extends StatelessWidget {
  const AppScreenTitle(this.ar, this.en, {super.key});

  final String ar;
  final String en;

  @override
  Widget build(BuildContext context) => BilingualText(
    ar,
    en,
    arStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
    enStyle: TextStyle(
      fontSize: 15,
      color: AppColors.accent(context),
      fontWeight: FontWeight.w700,
    ),
  );
}

class AppIconBox extends StatelessWidget {
  const AppIconBox(
    this.icon, {
    super.key,
    this.size = 44,
    this.iconSize = 23,
    this.color,
    this.background,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background ?? AppColors.accentSurface(context),
      borderRadius: BorderRadius.circular(size * .275),
    ),
    child: Icon(
      icon,
      color: color ?? AppColors.onAccentSurface(context),
      size: iconSize,
    ),
  );
}

class AppProBadge extends StatelessWidget {
  const AppProBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.accentSurface(context),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'PRO',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.onAccentSurface(context),
      ),
    ),
  );
}

class DocumentPlaceholder extends StatelessWidget {
  const DocumentPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.accentSurface(context),
    child: Center(
      child: Icon(
        Icons.description_outlined,
        color: AppColors.onAccentSurface(context),
      ),
    ),
  );
}

class BilingualIconAction extends StatelessWidget {
  const BilingualIconAction({
    super.key,
    required this.icon,
    required this.ar,
    required this.en,
    required this.onTap,
    this.selected = false,
    this.selectedIcon,
    this.horizontalPadding = 12,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String ar;
  final String en;
  final VoidCallback onTap;
  final bool selected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.accent(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return AppPressScale(
      pressedScale: .94,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$ar / $en',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected && selectedIcon != null ? selectedIcon : icon,
                  size: 23,
                  color: color,
                ),
                const SizedBox(height: 3),
                BilingualText(
                  ar,
                  en,
                  align: TextAlign.center,
                  spacing: 1,
                  maxLines: 1,
                  arStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  enStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppProcessingOverlay extends StatelessWidget {
  const AppProcessingOverlay({
    super.key,
    required this.label,
    this.detail = 'Please keep the app open / أبقِ التطبيق مفتوحاً',
  });

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .93),
    child: Center(
      child: AppSurfaceCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class AppFileRow extends StatelessWidget {
  const AppFileRow({
    super.key,
    required this.name,
    this.leadingIcon = Icons.insert_drive_file_outlined,
    this.trailing,
  });

  final String name;
  final IconData leadingIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(leadingIcon, color: AppColors.accent(context), size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ],
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search_rounded),
      hintText: hintText,
    ),
  );
}

class AppFileImage extends StatelessWidget {
  const AppFileImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String path;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) => Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, _, _) => fallback ?? const DocumentPlaceholder(),
  );
}
