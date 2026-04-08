import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/app_fonts.dart';

// ─── Color Palette ───
const _accent = Color(0xFF00E5FF); // Vibrant cyan accent
const _accentDark = Color(0xFF00B8D4);

// Dark theme surfaces
const _darkBg = Color(0xFF0D1B2A);
const _darkSurface = Color(0xFF1B2838);
const _darkCard = Color(0xFF213040);
const _darkOnSurface = Color(0xFFE0E6ED);

// Light theme surfaces
const _lightBg = Color(0xFFF5F7FA);
const _lightSurface = Color(0xFFFFFFFF);
const _lightCard = Color(0xFFFFFFFF);
const _lightOnSurface = Color(0xFF1A1A2E);

// ─── Dark Theme ───
ThemeData darkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBg,
  primaryColor: _accent,
  colorScheme: const ColorScheme.dark(
    primary: _accent,
    secondary: _accentDark,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    onPrimary: _darkBg,
    error: Color(0xFFCF6679),
    outline: Color(0xFF2A3A4A),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    iconTheme: IconThemeData(color: _darkOnSurface),
    centerTitle: true,
    elevation: 0.0,
    backgroundColor: _darkBg,
    surfaceTintColor: _darkBg,
    titleTextStyle: TextStyle(
      color: _darkOnSurface,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
  ),
  cardTheme: CardThemeData(
    color: _darkCard,
    elevation: 2,
    shadowColor: Colors.black45,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _darkSurface,
    selectedItemColor: _accent,
    unselectedItemColor: Color(0xFF6B7D8D),
    elevation: 8.0,
    type: BottomNavigationBarType.fixed,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: _accent),
  dialogTheme: DialogThemeData(
    backgroundColor: _darkSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _darkSurface,
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF2A3A4A)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.title,
      fontWeight: FontWeights.extraBold,
    ),
    titleMedium: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.subTitle,
      fontWeight: FontWeights.bold,
    ),
    titleSmall: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.details,
      fontWeight: FontWeights.semiBold,
    ),
    bodyLarge: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.subTitle,
      fontWeight: FontWeights.semiBold,
    ),
    bodyMedium: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.bodyText,
      fontWeight: FontWeights.regular,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: FontSize.details,
      fontWeight: FontWeights.medium,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF8899AA),
      fontSize: FontSize.details,
      fontWeight: FontWeights.medium,
    ),
    labelMedium: TextStyle(
      color: _darkOnSurface,
      fontSize: FontSize.paragraph,
      fontWeight: FontWeights.medium,
    ),
    labelSmall: TextStyle(
      color: Color(0xFF8899AA),
      fontSize: FontSize.paragraph,
      fontWeight: FontWeights.regular,
    ),
  ),
);

// ─── Light Theme ───
ThemeData lightTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  primaryColor: _accentDark,
  colorScheme: const ColorScheme.light(
    primary: _accentDark,
    secondary: _accent,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    onPrimary: Colors.white,
    error: Color(0xFFB00020),
    outline: Color(0xFFD0D7DE),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    iconTheme: IconThemeData(color: _lightOnSurface),
    centerTitle: true,
    elevation: 0.0,
    backgroundColor: _lightSurface,
    surfaceTintColor: _lightSurface,
    titleTextStyle: TextStyle(
      color: _lightOnSurface,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
  ),
  cardTheme: CardThemeData(
    color: _lightCard,
    elevation: 1,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _lightSurface,
    selectedItemColor: _accentDark,
    unselectedItemColor: Color(0xFF9E9E9E),
    elevation: 8.0,
    type: BottomNavigationBarType.fixed,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: _accentDark),
  dialogTheme: DialogThemeData(
    backgroundColor: _lightSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _lightSurface,
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.title,
      fontWeight: FontWeights.extraBold,
    ),
    titleMedium: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.subTitle,
      fontWeight: FontWeights.bold,
    ),
    titleSmall: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.details,
      fontWeight: FontWeights.semiBold,
    ),
    bodyLarge: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.subTitle,
      fontWeight: FontWeights.semiBold,
    ),
    bodyMedium: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.bodyText,
      fontWeight: FontWeights.regular,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: FontSize.details,
      fontWeight: FontWeights.medium,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF6B7280),
      fontSize: FontSize.details,
      fontWeight: FontWeights.medium,
    ),
    labelMedium: TextStyle(
      color: _lightOnSurface,
      fontSize: FontSize.paragraph,
      fontWeight: FontWeights.medium,
    ),
    labelSmall: TextStyle(
      color: Color(0xFF6B7280),
      fontSize: FontSize.paragraph,
      fontWeight: FontWeights.regular,
    ),
  ),
);
