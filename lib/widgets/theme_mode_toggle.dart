import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Two-position sliding switch between light and dark mode.
///
/// A pill-shaped glass track holds a sun on the left and a moon on the right;
/// tapping slides the thumb across and lights up the icon for the side that
/// is now active. The whole control is one button, so tapping anywhere on it
/// flips the mode.
///
/// Lives on the **Language** screen and drives the app-wide `appDarkMode`
/// notifier, which the Login screen also reads — see `DESIGN_SYSTEM.md`.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  /// True when dark mode (the moon side) is active.
  final bool isDark;

  final ValueChanged<bool> onChanged;

  static const double _width = 96;
  static const double _height = 48;
  static const double _thumbInset = 4;
  static double get _thumbSize => _height - (_thumbInset * 2);

  @override
  Widget build(BuildContext context) {
    // Track and thumb colours come from the mode being switched *to*, so the
    // control reads correctly against either background.
    final trackFill = isDark
        ? AppColors.darkGlassTop.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.28);
    final trackBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.6);
    final thumbColor = isDark
        ? AppColors.luminousMint
        : Colors.white.withValues(alpha: 0.95);
    // The active icon sits on the Luminous Mint thumb in dark mode, so it
    // uses the `on-primary` token.
    final activeIcon = isDark ? AppColors.darkOnPrimary : AppColors.actionNavy;
    final inactiveIcon = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.actionNavy.withValues(alpha: 0.45);

    return Semantics(
      container: true,
      toggled: isDark,
      label: isDark ? 'Dark mode' : 'Light mode',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isDark),
          borderRadius: BorderRadius.circular(_height),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_height),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: trackFill,
                  borderRadius: BorderRadius.circular(_height),
                  border: Border.all(color: trackBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // The thumb slides between the two ends. Alignment (not a
                    // hardcoded offset) keeps this correct under RTL too.
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: isDark
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _thumbInset,
                        ),
                        child: Container(
                          width: _thumbSize,
                          height: _thumbSize,
                          decoration: BoxDecoration(
                            color: thumbColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Icons sit above the thumb; whichever side the thumb is
                    // on gets the high-contrast colour.
                    //
                    // Positioned.fill matters: as a plain Stack child the Row
                    // shrinks to the icons' height and lands at the Stack's
                    // default top-start corner, which pinned both icons to the
                    // top edge. Filling the Stack lets the Row's default
                    // centre cross-axis alignment centre them vertically.
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: Icon(
                              Icons.light_mode,
                              size: 22,
                              color: isDark ? inactiveIcon : activeIcon,
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              Icons.dark_mode,
                              size: 20,
                              color: isDark ? activeIcon : inactiveIcon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
