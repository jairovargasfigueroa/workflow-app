import 'package:flutter/material.dart';

/// Tokens de espaciado (Flutter no trae una escala built-in, la definimos acá).
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Tokens de radio de bordes.
abstract class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

/// Colores de marca / fondo (los semánticos salen del ColorScheme).
abstract class AppColors {
  static const Color seed = Color(0xFF1B4F8A); // azul institucional
  static const Color fondo = Color(0xFFF4F6FA); // gris claro → las cards "flotan"
}

ThemeData buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
  final textTheme = _textTheme(base.textTheme, colorScheme);

  return base.copyWith(
    // Fondo en capas: gris claro de fondo + cards blancas → profundidad.
    scaffoldBackgroundColor: AppColors.fondo,
    textTheme: textTheme,

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleLarge,
    ),

    // Cards blancas con sombra suave sobre el fondo gris → "flotan" (no planas).
    cardTheme: CardThemeData(
      elevation: 2,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      isDense: true,
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: BorderSide.none,
      labelStyle: textTheme.labelMedium,
    ),

    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      height: 64,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelMedium?.copyWith(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    ),

    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
      space: AppSpacing.md,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}

/// Escala tipográfica (jerarquía clara para que no se vea "plana").
TextTheme _textTheme(TextTheme base, ColorScheme cs) {
  return base.copyWith(
    titleLarge:
        base.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium:
        base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall:
        base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.35),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.35),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12.5,
      color: cs.onSurfaceVariant,
    ),
    labelLarge:
        base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ),
    labelSmall: base.labelSmall?.copyWith(fontSize: 11, letterSpacing: 0.4),
  );
}
