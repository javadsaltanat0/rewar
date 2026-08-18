import 'package:flutter/widgets.dart';

/// Whether the app is showing its dark ("Lush Horizon: Moonlit") appearance.
///
/// Shared app-wide so the choice survives navigation: the toggle lives on the
/// Language screen, but the Login screen has to honour the same value.
///
/// **Scope today:** only the Language and Login screens listen to this.
/// `MaterialApp` is still pinned to `ThemeMode.light`, so screens further into
/// the flow stay light until dark mode is rolled out to them.
///
/// Not persisted — a cold start begins in light mode. Same simple-notifier
/// approach as [appLocale]; a fuller state-management solution can replace
/// both later (still undecided per CLAUDE.md).
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);
