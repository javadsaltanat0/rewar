import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// How a [GlassPanel]'s light-mode interior is filled.
///
/// Dark mode ignores this — `DESIGN dark.md` defines exactly one glass fill
/// (the emerald gradient with the 85/15 split), so both values look the same
/// there.
enum GlassFill {
  /// Translucent white sheen, brighter at the top. The original treatment,
  /// used by Login's card, the social buttons and the language buttons.
  sheen,

  /// `DESIGN light.md` → Elevation & Depth:
  ///
  /// > *Card Fill: Cards use a 20% opacity version of the brand gradient
  /// > (#E1F4E5 to #187C64).*
  ///
  /// Paired with the file's 20%-white edge stroke. Used by the Register
  /// form container.
  brandGradient,
}

/// Reusable frosted "liquid glass" surface (blur + translucent fill +
/// light border + soft shadow), per the design system's Elevation & Depth
/// section. Shared across the auth screens.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = EdgeInsets.zero,
    this.borderColor,
    this.borderWidth,
    this.dark,
    this.fill = GlassFill.sheen,
  });

  /// Which light-mode interior to use. See [GlassFill].
  final GlassFill fill;

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  /// Overrides the default ~55%-white border (e.g. for a selected state).
  final Color? borderColor;
  final double? borderWidth;

  /// Switches to the "Moonlit" glass from `DESIGN dark.md`: a 45%-opacity
  /// `#0C1F1F → #062C32` gradient with the 85/15 split (the top catches
  /// "moonlight"), a heavier 40px blur, and a 12%-white edge stroke.
  ///
  /// Only the Login screen passes true today.
  final bool? dark;

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    // DESIGN dark.md requires a minimum 40px blur on glass; light mode uses 20.
    final blur = isDark ? 40.0 : 20.0;

    final LinearGradient fillGradient;
    if (isDark) {
      fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        // 85/15 split — the top 15% is brighter, per the design file.
        stops: const [0.0, 0.15, 1.0],
        colors: [
          AppColors.darkGlassTop.withValues(alpha: 0.58),
          AppColors.darkGlassTop.withValues(alpha: 0.45),
          AppColors.darkGlassBottom.withValues(alpha: 0.45),
        ],
      );
    } else if (fill == GlassFill.brandGradient) {
      // "20% opacity version of the brand gradient (#E1F4E5 to #187C64)".
      fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.pageGradientTop.withValues(alpha: 0.20),
          AppColors.pageGradientBottom.withValues(alpha: 0.20),
        ],
      );
    } else {
      fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.34),
          Colors.white.withValues(alpha: 0.14),
        ],
      );
    }

    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        // The design file's "1px white inner border (20% opacity)" for the
        // brand-gradient card; the sheen variant keeps its brighter edge.
        : Colors.white.withValues(
            alpha: fill == GlassFill.brandGradient ? 0.20 : 0.55,
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: fillGradient,
              border: Border.all(
                color: borderColor ?? defaultBorder,
                width: borderWidth ?? 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
