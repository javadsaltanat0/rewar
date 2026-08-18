import 'dart:ui' show ImageFilter, TileMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Shared auth-screen background: the mountain photo under the green gradient
/// wash (light mint at the top → deep green at the bottom). Used by the Login
/// and Forget Password screens so they match.
class PageBackground extends StatelessWidget {
  const PageBackground({
    super.key,
    required this.child,
    this.dark,
    this.imageAsset = 'assets/images/Login.webp',
  });

  final Widget child;

  /// Which photo sits under the gradient wash. Defaults to the shared auth
  /// background; Account Setup passes its own.
  final String imageAsset;

  /// Switches to the "Moonlit" treatment from `DESIGN dark.md`: the same
  /// photo under a deep-emerald `#0C1F1F → #062C32` wash at ~80% opacity,
  /// so the photo reads as atmosphere rather than a legible scene.
  ///
  /// Only the Login screen passes true today.
  final bool? dark;

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // `DESIGN dark.md` → Background Imagery Treatment: in dark mode a
          // light-to-moderate gaussian blur is applied to the photo *itself*,
          // before the overlay, so it reads as "soft, defocused light blobs"
          // rather than a legible scene. This is separate from, and in
          // addition to, the 40px backdrop blur of glass cards on top.
          _MaybeBlurred(
            blurred: isDark,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: isDark
                    ? AppColors.darkForestFloor
                    : AppColors.pageGradientBottom,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [
                        Color(0xCC0C1F1F), // deep emerald ~80%
                        Color(0xCC062C32), // forest floor ~80%
                      ]
                    : const [
                        Color(0x8CE1F4E5), // light mint ~55%
                        Color(0xCC187C64), // deep green ~80%
                      ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Applies the dark-mode gaussian blur to the background photo, and nothing
/// at all in light mode — where the design calls for a legible scene.
///
/// Kept as a widget rather than an inline ternary so light mode pays no cost
/// for a filter it never uses.
class _MaybeBlurred extends StatelessWidget {
  const _MaybeBlurred({required this.blurred, required this.child});

  final bool blurred;
  final Widget child;

  /// "Light-to-moderate" per the design file — enough to remove readable
  /// detail without turning the photo into flat colour.
  static const double _sigma = 8;

  @override
  Widget build(BuildContext context) {
    if (!blurred) return child;
    return ImageFiltered(
      // Clamp, so the blur doesn't sample transparency at the screen edges
      // and leave a lighter border — the design file requires a uniform
      // treatment with no vignette.
      imageFilter: ImageFilter.blur(
        sigmaX: _sigma,
        sigmaY: _sigma,
        tileMode: TileMode.clamp,
      ),
      child: child,
    );
  }
}
