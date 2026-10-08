import 'package:flutter/material.dart';

/// Brand palette derived from DeepSeek's official blue / white / gray identity.
abstract final class AppColors {
  static const Color brand = Color(0xFF4D6BFE);
  static const Color brandDeep = Color(0xFF0052D4);
  static const Color brandSoftLight = Color(0xFFE9EDFF);
  static const Color brandSoftDark = Color(0xFF1B2340);

  static const Color peak = Color(0xFFFF5A5F);
  static const Color offPeak = Color(0xFF2EC27E);

  static const Color _lightBg = Color(0xFFF5F7FC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF10131A);
  static const Color _lightMuted = Color(0xFF6B7280);
  static const Color _lightOutline = Color(0xFFE3E7F0);

  static const Color _darkBg = Color(0xFF0B0D13);
  static const Color _darkSurface = Color(0xFF161A23);
  static const Color _darkText = Color(0xFFE9ECF4);
  static const Color _darkMuted = Color(0xFF9AA3B2);
  static const Color _darkOutline = Color(0xFF272D3A);

  static const Color lightBackground = _lightBg;
  static const Color lightSurface = _lightSurface;
  static const Color lightText = _lightText;
  static const Color lightMuted = _lightMuted;
  static const Color lightOutline = _lightOutline;

  static const Color darkBackground = _darkBg;
  static const Color darkSurface = _darkSurface;
  static const Color darkText = _darkText;
  static const Color darkMuted = _darkMuted;
  static const Color darkOutline = _darkOutline;
}

/// Convenience accessors for palette values that depend on the active
/// brightness. Prefer these over hard-coding colors in widgets.
extension AppThemeContext on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get brandSoft => _isDark
      ? AppColors.brandSoftDark
      : AppColors.brandSoftLight;

  Color get mutedText =>
      _isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get cardOutline =>
      _isDark ? AppColors.darkOutline : AppColors.lightOutline;

  Color get cardSurface =>
      _isDark ? AppColors.darkSurface : AppColors.lightSurface;
}

abstract final class AppTheme {
  static const double radius = 24;
  static const double radiusSmall = 16;

  static ThemeData light() => _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightText,
    outline: AppColors.lightOutline,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    outline: AppColors.darkOutline,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color outline,
  }) {
    final isDark = brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brand,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? AppColors.brandSoftDark
          : AppColors.brandSoftLight,
      onPrimaryContainer: isDark ? Colors.white : AppColors.brandDeep,
      secondary: AppColors.brandDeep,
      onSecondary: Colors.white,
      error: AppColors.peak,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark
          ? const Color(0xFF1D222C)
          : const Color(0xFFEFF2F9),
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: AppColors.brand,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: onSurface, displayColor: onSurface)
          .copyWith(
            displaySmall: base.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            labelLarge: base.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1F29) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: muted, fontSize: 15),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: _inputBorder(outline),
        enabledBorder: _inputBorder(outline),
        focusedBorder: _inputBorder(AppColors.brand, width: 1.6),
        errorBorder: _inputBorder(AppColors.peak),
        focusedErrorBorder: _inputBorder(AppColors.peak, width: 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isDark ? const Color(0xFF2A3140) : AppColors.lightText,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
