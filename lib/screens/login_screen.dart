import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/page_background.dart';
import '../widgets/primary_button.dart';
import 'forget_password_screen.dart';
import 'home_screen.dart';
import 'language_selection_screen.dart';
import 'register_screen.dart';

/// Phase 1 — Login / Auth screen (light mode only).
///
/// Photo background under a green gradient, a back button, the logo, and a
/// "liquid glass" card containing the login form, social sign-in, and
/// register link, with "Continue as Guest" outside the card.
///
/// IMPORTANT: the actions here are placeholders. Real authentication needs
/// Firebase, which is not set up yet. Every button currently calls
/// [_notWired] so nothing silently pretends to work.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.languageCode = 'en'});

  /// The language the user picked on the Language screen ('en' | 'ku' | 'ar').
  final String languageCode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Mirrors the app-wide [appDarkMode] notifier, which the toggle on the
  /// **Language** screen owns. This screen only reads it — there is no toggle
  /// here any more.
  bool get _darkMode => appDarkMode.value;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Temporary stand-in for any action that will need the (not-yet-configured)
  /// Firebase backend. Keeps the UI honest — it says what *will* happen.
  void _notWired(String whatItWillDo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$whatItWillDo (backend not connected yet)')),
      );
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _notWired('Would sign in with email + password via Firebase Auth');
    }
  }

  void _onBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
      );
    }
  }

  /// Enters the app without an account. The home screen is fully browsable
  /// as a guest; only saving a favourite prompts for sign-in.
  ///
  /// `pushReplacement`, so Back from the dashboard doesn't return to Login —
  /// the auth flow is finished either way.
  void _onContinueAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  void _onForgetPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds if the mode is changed elsewhere while this screen is alive.
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    // Swapping the whole subtree's ThemeData is what makes every `Text` and
    // `colorScheme.*` lookup on this screen flip at once, instead of
    // scattering if/else colour branches through the widget tree.
    final theme = _darkMode
        ? AppTheme.darkForLocale(Localizations.localeOf(context))
        : AppTheme.lightForLocale(Localizations.localeOf(context));

    return Theme(
      data: theme,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: PageBackground(
          dark: _darkMode,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _TopBar(onBack: _onBack, dark: _darkMode),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildCard(),
                          ),
                          const SizedBox(height: 18),
                          _GuestButton(onTap: _onContinueAsGuest),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // Dark mode's action colour is Luminous Mint, light mode's is navy.
    final accent = _darkMode ? AppColors.luminousMint : AppColors.actionNavy;
    return GlassPanel(
      borderRadius: 26,
      dark: _darkMode,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.logIn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 22),
            _GlassField(
              controller: _emailController,
              hint: l10n.email,
              keyboardType: TextInputType.emailAddress,
              focusedBorderColor: accent,
              dark: _darkMode,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return l10n.emailRequired;
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(text)) {
                  return l10n.emailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _GlassField(
              controller: _passwordController,
              hint: l10n.password,
              obscureText: _obscurePassword,
              focusedBorderColor: accent,
              dark: _darkMode,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.secondaryText(context),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return l10n.passwordRequired;
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GestureDetector(
                onTap: _onForgetPassword,
                child: Text(
                  l10n.forgetPassword,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: l10n.logIn, onTap: _onLogin, dark: _darkMode),
            const SizedBox(height: 20),
            const _OrDivider(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    icon: Icon(Icons.apple, size: 24, color: accent),
                    label: 'Apple',
                    dark: _darkMode,
                    onTap: () => _notWired('Would sign in with Apple'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SocialButton(
                    icon: Icon(Icons.g_mobiledata, size: 30, color: accent),
                    label: 'Gmail',
                    dark: _darkMode,
                    onTap: () => _notWired('Would sign in with Google'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      // The design file's own example of secondary text.
                      color: AppColors.secondaryText(context),
                    ),
                    children: [
                      TextSpan(text: l10n.dontHaveAccount),
                      TextSpan(
                        text: l10n.registerNow,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar: circular glass back button (top-left, all languages) and the
/// centered logo.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, this.dark = false});

  final VoidCallback onBack;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GlassBackButton(onTap: onBack, dark: dark),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/logo.png',
              height: 74,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'Logo',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted text input matching the design's input style.
class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.focusedBorderColor,
    this.validator,
    this.dark = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final Color? focusedBorderColor;
  final String? Function(String?)? validator;

  /// `DESIGN dark.md` asks for "semi-transparent dark emerald" fields whose
  /// border glows Luminous Mint on focus. The outline shape is kept rather
  /// than the file's bottom-border-only style, so the field doesn't change
  /// silhouette when the mode is toggled.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = dark
        ? AppColors.darkGlassTop.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.28);
    final borderColor = dark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.7);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              // DESIGN dark.md: placeholder text is white at 60-70%.
              color: dark
                  ? AppColors.darkOnSurfaceSecondary.withValues(
                      alpha: AppColors.darkHintOpacity,
                    )
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 16,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: border,
            border: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: focusedBorderColor ?? AppColors.actionNavy,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// A frosted social sign-in button (icon + label).
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassPanel(
      borderRadius: 14,
      dark: dark,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                // Two of these sit side by side, so each gets under half the
                // screen. Without this the label pushes the row past its
                // width on a narrow phone, or once the system font is
                // enlarged. Scaling down keeps the whole word readable,
                // where clipping would leave "Gm…".
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: colorScheme.onSurface,
                      ),
                    ),
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

/// "———— Or ————" divider.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.secondaryText(context);
    Widget line() => Expanded(
      child: Container(height: 1.2, color: color.withValues(alpha: 0.45)),
    );
    return Row(
      children: [
        line(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context).orLabel,
            style: TextStyle(color: color, fontSize: 15),
          ),
        ),
        line(),
      ],
    );
  }
}

/// "Continue as Guest" link shown outside the card.
class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        AppLocalizations.of(context).continueAsGuest,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Color(0x66000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
