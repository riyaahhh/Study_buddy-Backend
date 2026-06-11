import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF6366F1);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text
  static const Color textH = Color(0xFF111827);
  static const Color textB = Color(0xFF374151);
  static const Color textS = Color(0xFF6B7280);
  static const Color textT = Color(0xFF9CA3AF);

  // Tints
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color secondaryLight = Color(0xFFEEF2FF);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color errorLight = Color(0xFFFEF2F2);

  // Subject palette
  static const List<Color> palette = [
    Color(0xFF2563EB),
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
  ];
}

// ── Shadows ────────────────────────────────────────────────────────
List<BoxShadow> get cardShadow => [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];

List<BoxShadow> get subtleShadow => [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.04),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ];

List<BoxShadow> get primaryShadow => [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.25),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

List<BoxShadow> get secondaryShadow => [
      BoxShadow(
        color: AppColors.secondary.withOpacity(0.2),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: AppColors.primary,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.secondaryLight,
          onSecondaryContainer: AppColors.secondary,
          tertiary: AppColors.success,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.successLight,
          onTertiaryContainer: AppColors.success,
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorLight,
          onErrorContainer: AppColors.error,
          background: AppColors.background,
          onBackground: AppColors.textH,
          surface: AppColors.surface,
          onSurface: AppColors.textH,
          surfaceVariant: AppColors.surfaceAlt,
          onSurfaceVariant: AppColors.textS,
          outline: AppColors.border,
          outlineVariant: AppColors.borderLight,
          shadow: Color(0xFF0F172A),
          scrim: Color(0xFF0F172A),
          inverseSurface: Color(0xFF1E293B),
          onInverseSurface: Color(0xFFF8FAFC),
          inversePrimary: Color(0xFF93C5FD),
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ─────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textH,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Color(0x0F0F172A),
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          titleTextStyle: TextStyle(
            color: AppColors.textH,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: -0.2,
          ),
          toolbarTextStyle: TextStyle(
            color: AppColors.textH,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(
            color: AppColors.textH,
            size: 22,
          ),
          actionsIconTheme: IconThemeData(
            color: AppColors.textS,
            size: 22,
          ),
        ),

        // ── Elevated Button ────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textT,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              letterSpacing: 0.1,
            ),
          ),
        ),

        // ── Outlined Button ────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textT,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: const BorderSide(color: AppColors.border, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // ── Text Button ────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // ── Input ──────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintStyle: const TextStyle(
            color: AppColors.textT,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textS,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
          prefixIconColor: AppColors.textS,
          suffixIconColor: AppColors.textS,
          isDense: false,
        ),

        // ── Card ───────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Chip ───────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceAlt,
          selectedColor: AppColors.primaryLight,
          disabledColor: AppColors.borderLight,
          deleteIconColor: AppColors.textS,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: AppColors.textB,
          ),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColors.border, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          elevation: 0,
        ),

        // ── Bottom Navigation ──────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textT,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          selectedIconTheme: IconThemeData(size: 22),
          unselectedIconTheme: IconThemeData(size: 22),
        ),

        // ── Tab Bar ────────────────────────────────────────────────
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textS,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.border,
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),

        // ── Divider ────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),

        // ── Dialog ─────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.textH,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.textS,
            fontSize: 14,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),

        // ── Bottom Sheet ───────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          dragHandleColor: AppColors.border,
          dragHandleSize: Size(40, 4),
        ),

        // ── Snackbar ───────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textH,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          actionTextColor: AppColors.primaryLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        // ── Progress ───────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primaryLight,
          circularTrackColor: AppColors.primaryLight,
          linearMinHeight: 4,
        ),

        // ── List Tile ──────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: AppColors.textS,
          textColor: AppColors.textH,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textH,
            fontFamily: 'Inter',
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textS,
            fontFamily: 'Inter',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),

        // ── Icon ───────────────────────────────────────────────────
        iconTheme: const IconThemeData(
          color: AppColors.textS,
          size: 22,
        ),

        // ── FloatingActionButton ───────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // ── Switch ─────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected))
              return AppColors.primary;
            return AppColors.textT;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected))
              return AppColors.primaryLight;
            return AppColors.borderLight;
          }),
        ),

        // ── Checkbox ───────────────────────────────────────────────
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected))
              return AppColors.primary;
            return Colors.transparent;
          }),
          checkColor: const MaterialStatePropertyAll(Colors.white),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        // ── Text Theme ─────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textH,
            letterSpacing: -0.8,
            fontFamily: 'Inter',
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textH,
            letterSpacing: -0.5,
            fontFamily: 'Inter',
            height: 1.2,
          ),
          displaySmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textH,
            letterSpacing: -0.3,
            fontFamily: 'Inter',
            height: 1.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textH,
            letterSpacing: -0.2,
            fontFamily: 'Inter',
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textH,
            letterSpacing: -0.1,
            fontFamily: 'Inter',
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textH,
            fontFamily: 'Inter',
            height: 1.4,
          ),
          titleLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textH,
            fontFamily: 'Inter',
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textB,
            fontFamily: 'Inter',
            height: 1.4,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textB,
            fontFamily: 'Inter',
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textB,
            fontFamily: 'Inter',
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textB,
            fontFamily: 'Inter',
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textS,
            fontFamily: 'Inter',
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textH,
            fontFamily: 'Inter',
            letterSpacing: 0.1,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textS,
            fontFamily: 'Inter',
            letterSpacing: 0.2,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textT,
            fontFamily: 'Inter',
            letterSpacing: 0.3,
          ),
        ),

        // ── Splash / Highlight ─────────────────────────────────────
        splashFactory: InkRipple.splashFactory,
        highlightColor: AppColors.primaryLight.withOpacity(0.5),
        splashColor: AppColors.primaryLight.withOpacity(0.4),
        hoverColor: AppColors.surfaceAlt,

        // ── Misc ───────────────────────────────────────────────────
        visualDensity: VisualDensity.adaptivePlatformDensity,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // Backward compat
  static ThemeData get theme => light;

  // ── also update main.dart usage ──────────────────────────────
  // MaterialApp(theme: AppTheme.light)
}
