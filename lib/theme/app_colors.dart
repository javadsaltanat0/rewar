import 'package:flutter/material.dart';

/// Brand color tokens for the app.
///
/// These are the single source of truth for brand colors so no widget
/// hardcodes a raw hex value (see CLAUDE.md rule on semantic tokens).
/// The splash gradient is a fixed brand asset — intentionally identical
/// in light and dark mode.
class AppColors {
  AppColors._();

  /// Splash background gradient — light mint at the top…
  static const Color splashGradientTop = Color(0xFFE1F4E5);

  /// …fading to deep Kurdistan green at the bottom.
  static const Color splashGradientBottom = Color(0xFF187C64);

  /// Splash title text (over the gradient).
  static const Color splashText = Colors.white;

  /// Base page gradient (light mint → deep green), used as an overlay on
  /// top of the background photo on the Language screen. Same stops as the
  /// splash, from `DESIGN light.md` ("Base Background").
  static const Color pageGradientTop = Color(0xFFE1F4E5);
  static const Color pageGradientBottom = Color(0xFF187C64);

  /// Action / icon navy. `DESIGN light.md` prose reserves this dark navy
  /// for primary interactive elements and icons (e.g. the globe icon).
  /// Note: this differs from the `tertiary` token (#3F5774) in the same
  /// file — using the prose value here because it matches the mockup.
  static const Color actionNavy = Color(0xFF0E2A44);

  // --- Dark mode ("Lush Horizon: Moonlit", from `DESIGN dark.md`) ---------
  //
  // Dark mode is a different design language, not a recolour of light mode:
  // mint-filled buttons instead of navy, heavier blur, deeper radii. These
  // tokens are currently used by the Login screen only.

  /// "Forest floor" base — the solid canvas everything else sits on.
  static const Color darkForestFloor = Color(0xFF062C32);

  /// Liquid-glass gradient: top…
  static const Color darkGlassTop = Color(0xFF0C1F1F);

  /// …to bottom.
  static const Color darkGlassBottom = Color(0xFF062C32);

  /// Luminous mint — dark mode's primary action colour, the counterpart to
  /// [actionNavy]. Buttons filled with this take *dark* text.
  static const Color luminousMint = Color(0xFF2AF598);

  /// Text/icons drawn **on** [luminousMint] — the `on-primary` token.
  ///
  /// `DESIGN dark.md` → Text & Legibility: *"Text on Luminous Mint buttons:
  /// dark (`on-primary` #00391E) — this is the one place dark text is
  /// correct, because the background is bright."*
  ///
  /// Distinct from [darkForestFloor] (#062C32), which is the *background*
  /// canvas, not a text colour.
  static const Color darkOnPrimary = Color(0xFF00391E);

  /// Dark mode's `on-surface-secondary` / `on-surface-muted` / `heading` /
  /// `on-glass` tokens. **All four are pure white** — the design file sets
  /// every text-capable token to `#ffffff` deliberately, so that whichever
  /// one a widget reaches for, the text comes out readable.
  static const Color darkOnSurfaceSecondary = Color(0xFFFFFFFF);

  /// Opacity for secondary / helper text in dark mode ("Or", "Don't have an
  /// account?", captions, field hints). `DESIGN dark.md` specifies a
  /// **70-80%** band — softer than a heading, but plainly readable.
  ///
  /// Headings and body text are *not* covered by this: they are white at
  /// 100%. "A heading that looks dim is a bug, not a style."
  static const double darkSecondaryTextOpacity = 0.75;

  /// Placeholder text inside dark inputs — `DESIGN dark.md` specifies
  /// exactly **60%**.
  static const double darkHintOpacity = 0.60;

  /// Opacity for white borders and strokes in dark mode. `DESIGN dark.md`:
  /// *"When `outline` is used for its actual purpose — a border or stroke —
  /// it must be applied at 10-15% opacity. A solid, fully opaque white
  /// border is wrong."*
  static const double darkBorderOpacity = 0.12;

  /// Primary interactive accent for the active appearance.
  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? luminousMint
      : actionNavy;

  /// Returns the correct helper/secondary text colour for the current
  /// theme, so the dark-mode 70-80% rule is applied in one place instead of
  /// being re-derived (and mis-derived) per widget.
  static Color secondaryText(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return scheme.brightness == Brightness.dark
        ? darkOnSurfaceSecondary.withValues(alpha: darkSecondaryTextOpacity)
        : scheme.onSurfaceVariant;
  }

  /// Same, for helper text drawn directly on the background photo rather
  /// than on a glass surface (see [onPhotoBackground]).
  static Color onPhotoSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurfaceSecondary.withValues(alpha: darkSecondaryTextOpacity)
        : onPhotoBackground;
  }

  /// Text drawn **directly on the photo background**, outside any glass
  /// surface — e.g. the Register screen's "Or" divider and its
  /// "Already have an Account?" line.
  ///
  /// A semantic token rather than a bare `Colors.white` so the intent is
  /// explicit: the normal `onSurfaceVariant` (`#3E4945` in light mode) is a
  /// dark grey chosen for legibility *on a surface*, and it loses contrast
  /// badly against the deep green at the bottom of the page gradient.
  ///
  /// Correct in both modes — dark mode's `on-surface-variant` is already
  /// pure white per `DESIGN dark.md`.
  static const Color onPhotoBackground = Colors.white;
}
