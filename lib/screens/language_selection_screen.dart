import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../services/onboarding_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/theme_mode_toggle.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// A selectable language option.
class _LanguageOption {
  const _LanguageOption({
    required this.label,
    required this.hint,
    required this.code,
  });

  /// English name shown as the main label (e.g. "Kurdish").
  final String label;

  /// The language's own name, shown as the hint (e.g. "کوردی").
  final String hint;

  /// Locale code carried into the app ('en' | 'ku' | 'ar').
  final String code;
}

/// Phase 1, screen 2 — Language selection.
///
/// Light-mode only (per the handed-over `DESIGN light.md`). A blurred forest
/// photo sits behind a light-mint→green gradient, with the app's globe icon,
/// a title/subtitle, and three "liquid glass" language buttons.
///
/// Selecting a language switches the whole app to it, then continues to the
/// onboarding intro on a first install, or straight to Login once onboarding
/// has already been completed.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const _glassSettings = OCLiquidGlassSettings(
    blendPx: 4.0,
    refractStrength: -0.28,
    distortFalloffPx: 38.0,
    distortExponent: 3.0,
    blurRadiusPx: 2.0,
    specAngle: 4.0,
    specStrength: 0.5,
    specPower: 120.0,
    specWidth: 8.0,
    lightbandOffsetPx: 8.0,
    lightbandWidthPx: 20.0,
    lightbandStrength: 0.55,
    lightbandColor: Colors.white,
  );

  static const List<_LanguageOption> _options = [
    _LanguageOption(label: 'English', hint: 'English', code: 'en'),
    _LanguageOption(label: 'Kurdish', hint: 'کوردی', code: 'ku'),
    _LanguageOption(label: 'Arabic', hint: 'العربية', code: 'ar'),
  ];

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    OCLiquidGlassGroup.precacheShader();
  }

  Future<void> _selectLanguage(int index) async {
    final code = _options[index].code;
    setState(() => _selectedIndex = index);
    // Switch the whole app to the chosen language (and direction).
    appLocale.value = Locale(code);

    // The onboarding intro runs on first install only; after it has been
    // completed once, this goes straight to Login.
    final seenOnboarding = await OnboardingPreferences.hasSeenOnboarding();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => seenOnboarding
            ? LoginScreen(languageCode: code)
            : OnboardingScreen(languageCode: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds the screen whenever the shared light/dark value changes.
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, _) => _buildScreen(context, isDark),
    );
  }

  Widget _buildScreen(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    // Swapping the subtree's ThemeData flips every `colorScheme.*` lookup at
    // once instead of branching on colour in each widget.
    final theme = isDark
        ? AppTheme.darkForLocale(Localizations.localeOf(context))
        : AppTheme.lightForLocale(Localizations.localeOf(context));
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // Light mode's top edge is pale (dark status-bar icons); dark mode's
        // is deep emerald (light icons).
        value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background photo.
              if (isDark)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 8,
                    sigmaY: 8,
                    tileMode: TileMode.clamp,
                  ),
                  child: Image.asset(
                    'assets/images/Language.webp',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: AppColors.darkForestFloor),
                  ),
                )
              else
                Image.asset(
                  'assets/images/Language.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.pageGradientBottom),
                ),
              // Light: mint→green wash. Dark: the "Moonlit" treatment —
              // `#0C1F1F → #062C32` at a flat 80%, per `DESIGN dark.md`
              // ("Overlay opacity … 80% is the standard", uniform across the
              // whole screen with no vignette).
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? const [
                            Color(0xCC0C1F1F), // deep emerald, 80%
                            Color(0xCC062C32), // forest floor, 80%
                          ]
                        : const [
                            Color(0xB3E1F4E5), // light mint, ~70%
                            Color(0xD9187C64), // deep green, ~85%
                          ],
                  ),
                ),
              ),
              // Content. Scrollable so it can't overflow on short screens —
              // it stays vertically centred whenever there is room, and
              // scrolls instead of overflowing when there isn't.
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              isDark
                                  ? 'assets/images/language_logo dark.png'
                                  : 'assets/images/language_logo light.png',
                              height: 84,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.public,
                                    size: 76,
                                    color: isDark
                                        ? AppColors.luminousMint
                                        : AppColors.actionNavy,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.chooseYourLanguage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                height: 1.1,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.selectLanguageToContinue,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                            const SizedBox(height: 40),
                            OCLiquidGlassGroup(
                              settings: _glassSettings,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < _options.length; i++) ...[
                                    _LanguageButton(
                                      option: _options[i],
                                      selected: _selectedIndex == i,
                                      dark: isDark,
                                      onTap: () => _selectLanguage(i),
                                    ),
                                    if (i != _options.length - 1)
                                      const SizedBox(height: 18),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // The app's single light/dark switch. Lives here
                            // rather than on Login so the choice is made
                            // before the rest of the flow starts; Login reads
                            // the same notifier.
                            Align(
                              child: ThemeModeToggle(
                                isDark: isDark,
                                onChanged: (value) => appDarkMode.value = value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A language button whose background is rendered by the liquid-glass shader.
class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.option,
    required this.selected,
    required this.onTap,
    this.dark = false,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Dark mode's active/accent colour is Luminous Mint, light mode's is the
    // scheme primary.
    final selectedBorder = dark
        ? AppColors.luminousMint
        : colorScheme.primary.withValues(alpha: 0.90);
    return OCLiquidGlass(
      color: Colors.transparent,
      borderRadius: 20,
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.28 : 0.10),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(color: selectedBorder, width: 2)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Corbel',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamilyForCode(option.code),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
