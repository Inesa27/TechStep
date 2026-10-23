import 'package:flutter/material.dart';

/// Palet warna utama TechStep.
abstract final class TechStepColors {
  static const primary = Color(0xFF5547E8);
  static const primaryDark = Color(0xFF4034C8);
  static const primarySoft = Color(0xFFEEEDFF);

  static const background = Color(0xFFF4F3FC);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF242438);
  static const textSecondary = Color(0xFF77778B);
  static const border = Color(0xFFE7E5F2);

  static const success = Color(0xFF239B70);
  static const successSoft = Color(0xFFE8F7F0);

  static const danger = Color(0xFFD93649);
  static const dangerSoft = Color(0xFFFFEEF0);

  static const warning = Color(0xFFE5A323);
  static const warningSoft = Color(0xFFFFF5DF);
}

/// Standar jarak antarelemen.
abstract final class TechStepSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  static const EdgeInsets cardPadding =
      EdgeInsets.all(16);
}

/// Standar radius komponen.
abstract final class TechStepRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 100;
}

/// Tema utama aplikasi TechStep.
abstract final class TechStepTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: TechStepColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: TechStepColors.primary,
      onPrimary: Colors.white,
      secondary: TechStepColors.primarySoft,
      onSecondary: TechStepColors.textPrimary,
      surface: TechStepColors.surface,
      onSurface: TechStepColors.textPrimary,
      error: TechStepColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TechStepColors.background,

      // Tipografi.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: TechStepColors.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TechStepColors.textPrimary,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TechStepColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: TechStepColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TechStepColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TechStepColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TechStepColors.textPrimary,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TechStepColors.textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // AppBar.
      appBarTheme: const AppBarTheme(
        backgroundColor: TechStepColors.background,
        foregroundColor: TechStepColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TechStepColors.textPrimary,
        ),
      ),

      // Kartu standar.
      cardTheme: CardThemeData(
        color: TechStepColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.lg,
          ),
          side: const BorderSide(
            color: TechStepColors.border,
          ),
        ),
      ),

      // Input dan form.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TechStepColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: TechStepColors.textSecondary,
          fontSize: 14,
        ),
        prefixIconColor: TechStepColors.textSecondary,
        suffixIconColor: TechStepColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
          borderSide: const BorderSide(
            color: TechStepColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
          borderSide: const BorderSide(
            color: TechStepColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
          borderSide: const BorderSide(
            color: TechStepColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
          borderSide: const BorderSide(
            color: TechStepColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
          borderSide: const BorderSide(
            color: TechStepColors.danger,
            width: 1.5,
          ),
        ),
      ),

      // Tombol utama.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, 48),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          backgroundColor: const WidgetStatePropertyAll(
            TechStepColors.primary,
          ),
          foregroundColor: const WidgetStatePropertyAll(
            Colors.white,
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                TechStepRadius.md,
              ),
            ),
          ),
        ),
      ),

      // Tombol sekunder.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, 48),
          ),
          foregroundColor: const WidgetStatePropertyAll(
            TechStepColors.primary,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: TechStepColors.border),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                TechStepRadius.md,
              ),
            ),
          ),
        ),
      ),

      // Navigasi bawah.
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: TechStepColors.surface,
        elevation: 0,
        indicatorColor: TechStepColors.primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            TechStepRadius.md,
          ),
        ),
        labelTextStyle:
            WidgetStateProperty.resolveWith<TextStyle?>(
          (states) {
            final selected =
                states.contains(WidgetState.selected);

            return TextStyle(
              fontSize: 12,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selected
                  ? TechStepColors.primary
                  : TechStepColors.textSecondary,
            );
          },
        ),
        iconTheme:
            WidgetStateProperty.resolveWith<IconThemeData?>(
          (states) {
            final selected =
                states.contains(WidgetState.selected);

            return IconThemeData(
              size: 22,
              color: selected
                  ? TechStepColors.primary
                  : TechStepColors.textSecondary,
            );
          },
        ),
      ),

      // Indikator progres.
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: TechStepColors.primary,
        linearTrackColor: TechStepColors.border,
        circularTrackColor: TechStepColors.border,
      ),

      dividerColor: TechStepColors.border,
      iconTheme: const IconThemeData(
        color: TechStepColors.textSecondary,
      ),
    );
  }
}