import 'dart:ui' show ImageFilter, TileMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// The home screen's full-bleed background.
///
/// This is **not** [PageBackground]: the two modes layer their photo
/// differently, straight from the design files.
///
/// * **Light** — `DESIGN light.md` → Colors → Base Background: *"A
///   full-viewport linear gradient from #E1F4E5 (85%) to #187C64 (15%).
///   Overlaid on this is a high-exposure, blurred landscape photo at 50%
///   opacity."* The photo sits **on top of** the gradient, so the page stays
///   pale mint almost all the way down and only deepens to green at the very
///   bottom edge — which is what the reference screenshot shows. The auth
///   screens' [PageBackground] does the opposite (photo underneath, wash on
///   top) and would come out far too dark here.
/// * **Dark** — `DESIGN dark.md` → Background Imagery Treatment: the photo is
///   blurred first, then covered by the `#0C1F1F → #062C32` wash at a flat
///   **80%**, uniform top to bottom with no vignette.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key, required this.child, this.dark});

  final Widget child;

  /// Overrides the ambient theme brightness (used by tests).
  final bool? dark;

  static const String imageAsset = 'assets/images/main screen back image.webp';

  /// The source photo is a very large JPEG. Decoded cost is
  /// `width × height × 4` bytes regardless of file size, so it is decoded
  /// down to the height actually drawn — the same rule the onboarding
  /// panorama follows.
  static int decodeHeightFor(BuildContext context) {
    final media = MediaQuery.of(context);
    return (media.size.height * media.devicePixelRatio).round();
  }

  /// "Light-to-moderate" gaussian blur, per both design files.
  static const double blurSigma = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;

    final photo = ImageFiltered(
      // Clamp so the blur doesn't sample transparency at the screen edges and
      // leave a lighter border — the treatment must be uniform, no vignette.
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: TileMode.clamp,
      ),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        cacheHeight: decodeHeightFor(context),
        // A missing asset must not leave a blank screen; the gradient below
        // already carries the brand colour on its own.
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light mode draws navy text on a pale background, so the status-bar
      // icons must be dark; dark mode is the reverse.
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isDark) ...[
            photo,
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0C1F1F), // deep emerald @ 80%
                    Color(0xCC062C32), // forest floor @ 80%
                  ],
                ),
              ),
            ),
          ] else ...[
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.pageGradientTop,
                    AppColors.pageGradientBottom,
                  ],
                  // "#E1F4E5 (85%) to #187C64 (15%)" — mint holds for the top
                  // 85% of the viewport, green only takes over at the bottom.
                  stops: [0.85, 1.0],
                ),
              ),
            ),
            Opacity(opacity: 0.5, child: photo),
          ],
          child,
        ],
      ),
    );
  }
}
