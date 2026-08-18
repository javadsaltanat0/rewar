import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Text input filled with the brand gradient, per `DESIGN light.md`:
///
/// > *Card Fill: Cards use a 20% opacity version of the brand gradient
/// > (#E1F4E5 to #187C64).*
/// > *Edge Definition: a subtle 1px white inner border (20% opacity).*
/// > *Backdrop Blur: every card and modal must have blur(20px).*
///
/// Translucent on purpose — the background photo reads through it, which is
/// what the Reset Password mockup shows.
///
/// Distinct from Login's frosted-white `_GlassField`, which stays as it is by
/// explicit decision. Corner radius is the design file's 12px for inputs, not
/// the rounder corners drawn in the mockup.
class GradientField extends StatelessWidget {
  const GradientField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.prefix,
    this.dark,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// Used by the picker-backed fields (date of birth, gender): the field
  /// shows the chosen value but is never typed into directly.
  final bool readOnly;
  final VoidCallback? onTap;

  /// Extra leading widget between the icon and the text, e.g. the country
  /// dialling-code selector on the phone field.
  final Widget? prefix;

  /// "Moonlit" treatment from `DESIGN dark.md`: emerald glass instead of the
  /// mint→green gradient, with Luminous Mint as the focus colour.
  final bool? dark;

  /// `DESIGN light.md` → Shapes → "Search Inputs: 12px corner radius".
  static const double radius = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = dark ?? colorScheme.brightness == Brightness.dark;

    OutlineInputBorder borderWith(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    // Light: 20%-opacity brand gradient, per the design file's card fill.
    // Dark: the emerald glass gradient from `DESIGN dark.md`.
    final fill = isDark
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.15, 1.0],
            colors: [
              AppColors.darkGlassTop.withValues(alpha: 0.58),
              AppColors.darkGlassTop.withValues(alpha: 0.45),
              AppColors.darkGlassBottom.withValues(alpha: 0.45),
            ],
          )
        : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.pageGradientTop.withValues(alpha: 0.55),
              AppColors.pageGradientBottom.withValues(alpha: 0.55),
            ],
          );

    final accent = isDark ? AppColors.luminousMint : AppColors.actionNavy;
    final edge = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.75);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: fill,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            // Picker-backed fields shouldn't look like they take typing.
            showCursor: !readOnly,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                // DESIGN dark.md: placeholder text is white at 60-70% —
                // visibly dimmer than entered text, but still legible.
                color: isDark
                    ? AppColors.darkOnSurfaceSecondary.withValues(
                        alpha: AppColors.darkHintOpacity,
                      )
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                fontSize: 16,
              ),
              prefixIcon: (prefixIcon == null && prefix == null)
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 18,
                        end: 12,
                      ),
                      // The prefix cluster (icon plus, on the phone field, the
                      // country selector) has to share the row with the text
                      // being typed. Scaling it down when it doesn't fit keeps
                      // it whole and readable; without this it overflows on a
                      // narrow screen once the system font is enlarged.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prefixIcon != null)
                              Icon(prefixIcon, color: accent, size: 22),
                            if (prefix != null) ...[
                              const SizedBox(width: 10),
                              prefix!,
                            ],
                          ],
                        ),
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: suffix,
              // Matches the 56dp field height used across the app.
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: borderWith(edge, 1.2),
              border: borderWith(edge, 1.2),
              focusedBorder: borderWith(accent, 1.6),
              errorBorder: borderWith(colorScheme.error, 1.4),
              focusedErrorBorder: borderWith(colorScheme.error, 1.6),
              errorStyle: TextStyle(
                color: colorScheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
