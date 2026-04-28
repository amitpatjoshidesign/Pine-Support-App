import 'package:flutter/material.dart';

class SupportColorTokens {
  const SupportColorTokens._();

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4B662C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCCEDA4),
    onPrimaryContainer: Color(0xFF344E16),
    primaryFixed: Color(0xFFCCEDA4),
    primaryFixedDim: Color(0xFFB1D18A),
    onPrimaryFixed: Color(0xFF0F2000),
    onPrimaryFixedVariant: Color(0xFF344E16),
    secondary: Color(0xFF506528),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD2EC9F),
    onSecondaryContainer: Color(0xFF394D12),
    secondaryFixed: Color(0xFFD2EC9F),
    secondaryFixedDim: Color(0xFFB6D086),
    onSecondaryFixed: Color(0xFF131F00),
    onSecondaryFixedVariant: Color(0xFF394D12),
    tertiary: Color(0xFF386663),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFBBECE8),
    onTertiaryContainer: Color(0xFF1F4E4B),
    tertiaryFixed: Color(0xFFBBECE8),
    tertiaryFixedDim: Color(0xFFA0CFCC),
    onTertiaryFixed: Color(0xFF00201F),
    onTertiaryFixedVariant: Color(0xFF1F4E4B),
    error: Color(0xFF904A43),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF73332E),
    surface: Color(0xFFF5FBF7),
    onSurface: Color(0xFF171D1B),
    surfaceDim: Color(0xFFD5DBD8),
    surfaceBright: Color(0xFFF5FBF7),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF5F1),
    surfaceContainer: Color(0xFFE9EFEC),
    surfaceContainerHigh: Color(0xFFE3EAE6),
    surfaceContainerHighest: Color(0xFFDEE4E0),
    onSurfaceVariant: Color(0xFF414942),
    outline: Color(0xFF717971),
    outlineVariant: Color(0xFFC0C9BF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B3230),
    onInverseSurface: Color(0xFFECF2EF),
    inversePrimary: Color(0xFFB1D18A),
    surfaceTint: Color(0xFF4B662C),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB1D18A),
    onPrimary: Color(0xFF1E3702),
    primaryContainer: Color(0xFF344E16),
    onPrimaryContainer: Color(0xFFCCEDA4),
    primaryFixed: Color(0xFFCCEDA4),
    primaryFixedDim: Color(0xFFB1D18A),
    onPrimaryFixed: Color(0xFF0F2000),
    onPrimaryFixedVariant: Color(0xFF344E16),
    secondary: Color(0xFFB6D086),
    onSecondary: Color(0xFF243600),
    secondaryContainer: Color(0xFF394D12),
    onSecondaryContainer: Color(0xFFD2EC9F),
    secondaryFixed: Color(0xFFD2EC9F),
    secondaryFixedDim: Color(0xFFB6D086),
    onSecondaryFixed: Color(0xFF131F00),
    onSecondaryFixedVariant: Color(0xFF394D12),
    tertiary: Color(0xFFA0CFCC),
    onTertiary: Color(0xFF003735),
    tertiaryContainer: Color(0xFF1F4E4B),
    onTertiaryContainer: Color(0xFFBBECE8),
    tertiaryFixed: Color(0xFFBBECE8),
    tertiaryFixedDim: Color(0xFFA0CFCC),
    onTertiaryFixed: Color(0xFF00201F),
    onTertiaryFixedVariant: Color(0xFF1F4E4B),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF561E19),
    errorContainer: Color(0xFF73332E),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0E1513),
    onSurface: Color(0xFFDEE4E0),
    surfaceDim: Color(0xFF0E1513),
    surfaceBright: Color(0xFF343B38),
    surfaceContainerLowest: Color(0xFF090F0E),
    surfaceContainerLow: Color(0xFF171D1B),
    surfaceContainer: Color(0xFF1B211F),
    surfaceContainerHigh: Color(0xFF252B29),
    surfaceContainerHighest: Color(0xFF303634),
    onSurfaceVariant: Color(0xFFC0C9BF),
    outline: Color(0xFF8B938A),
    outlineVariant: Color(0xFF414942),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDEE4E0),
    onInverseSurface: Color(0xFF2B3230),
    inversePrimary: Color(0xFF4B662C),
    surfaceTint: Color(0xFFB1D18A),
  );
}

class SupportShapeTokens {
  const SupportShapeTokens._();

  static const double none = 0;
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double largeIncreased = 20;
  static const double extraLarge = 28;
  static const double extraLargeIncreased = 32;
  static const double extraExtraLarge = 48;
  static const double full = 1000;
}

class SupportTypeTokens {
  static const String fontFamily = 'Google Sans Flex';

  const SupportTypeTokens._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        height: 64 / 57,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        height: 52 / 45,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 36 / 28,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        height: 28 / 22,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 16 / 11,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
      ),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
