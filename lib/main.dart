import 'package:flutter/material.dart';

import 'services/learning_analytics_service.dart';
import 'screens/auth_gate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LearningAnalyticsService.instance.initialize();

  runApp(const TechStepApp());
}

// ============================================================
// TECHSTEP APP
// ============================================================

class TechStepApp extends StatelessWidget {
  const TechStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechStep',
      theme: _buildTechStepTheme(),
      home: AuthGate(
        authenticatedHomeBuilder: (user, onLogout) {
          return TechStepHome(
            user: user,
            onLogout: onLogout,
          );
        },
      ),
    );
  }
}

// ============================================================
// TECHSTEP GLOBAL THEME
// ============================================================

ThemeData _buildTechStepTheme() {
  const primary = Color(0xFF5547E8);
  const primarySoft = Color(0xFFEEEDFF);

  const background = Color(0xFFF4F3FC);
  const surface = Color(0xFFFFFFFF);

  const textPrimary = Color(0xFF242438);
  const textSecondary = Color(0xFF77778B);
  const border = Color(0xFFE7E5F2);

  const success = Color(0xFF239B70);
  const danger = Color(0xFFD93649);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: primary,
    onPrimary: Colors.white,
    secondary: primarySoft,
    onSecondary: textPrimary,
    surface: surface,
    onSurface: textPrimary,
    error: danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // Latar belakang halaman.
    scaffoldBackgroundColor: background,

    // ----------------------------------------------------------
    // TYPOGRAPHY
    // ----------------------------------------------------------

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ----------------------------------------------------------
    // APP BAR
    // ----------------------------------------------------------

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),

    // ----------------------------------------------------------
    // CARD
    // ----------------------------------------------------------

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: border,
        ),
      ),
    ),

    // ----------------------------------------------------------
    // INPUT
    // ----------------------------------------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: danger,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: danger,
          width: 1.5,
        ),
      ),
    ),

    // ----------------------------------------------------------
    // PRIMARY BUTTON
    // ----------------------------------------------------------

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
          primary,
        ),
        foregroundColor: const WidgetStatePropertyAll(
          Colors.white,
        ),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),

    // ----------------------------------------------------------
    // OUTLINED BUTTON
    // ----------------------------------------------------------

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(0, 48),
        ),
        foregroundColor: const WidgetStatePropertyAll(
          primary,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: border),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),

    // ----------------------------------------------------------
    // TEXT BUTTON
    // ----------------------------------------------------------

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // ----------------------------------------------------------
    // BOTTOM NAVIGATION
    // ----------------------------------------------------------

    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: surface,
      elevation: 0,
      indicatorColor: primarySoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      labelBehavior:
          NavigationDestinationLabelBehavior.alwaysShow,
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
            color: selected ? primary : textSecondary,
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
            color: selected ? primary : textSecondary,
          );
        },
      ),
    ),

    // ----------------------------------------------------------
    // PROGRESS INDICATORS
    // ----------------------------------------------------------

    progressIndicatorTheme:
        const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),

    // ----------------------------------------------------------
    // DIVIDER AND ICON
    // ----------------------------------------------------------

    dividerColor: border,

    iconTheme: const IconThemeData(
      color: textSecondary,
    ),

    // Warna interaksi.
    splashColor: primary.withValues(alpha: 0.08),
    highlightColor: primary.withValues(alpha: 0.04),
    hoverColor: primary.withValues(alpha: 0.04),
    focusColor: primary.withValues(alpha: 0.08),
    disabledColor: textSecondary,
    shadowColor: Colors.black.withValues(alpha: 0.05),
    primaryColor: primary,

    // Warna status bisa digunakan oleh semua halaman.
    extensions: const <ThemeExtension<dynamic>>[
      _TechStepStatusColors(
        success: success,
        danger: danger,
        successSoft: Color(0xFFE8F7F0),
        dangerSoft: Color(0xFFFFEEF0),
      ),
    ],
  );
}

// ============================================================
// STATUS COLORS
// ============================================================

@immutable
class _TechStepStatusColors
    extends ThemeExtension<_TechStepStatusColors> {
  final Color success;
  final Color danger;
  final Color successSoft;
  final Color dangerSoft;

  const _TechStepStatusColors({
    required this.success,
    required this.danger,
    required this.successSoft,
    required this.dangerSoft,
  });

  @override
  _TechStepStatusColors copyWith({
    Color? success,
    Color? danger,
    Color? successSoft,
    Color? dangerSoft,
  }) {
    return _TechStepStatusColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      successSoft: successSoft ?? this.successSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
    );
  }

  @override
  _TechStepStatusColors lerp(
    covariant ThemeExtension<_TechStepStatusColors>? other,
    double t,
  ) {
    if (other is! _TechStepStatusColors) {
      return this;
    }

    return _TechStepStatusColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      successSoft:
          Color.lerp(successSoft, other.successSoft, t)!,
      dangerSoft:
          Color.lerp(dangerSoft, other.dangerSoft, t)!,
    );
  }
}

// ============================================================
// TECHSTEP HOME AND NAVIGATION
// ============================================================

class TechStepHome extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const TechStepHome({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<TechStepHome> createState() => _TechStepHomeState();
}

class _TechStepHomeState extends State<TechStepHome> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardScreen(
        onLearn: () {
          setState(() {
            currentIndex = 1;
          });
        },
        onQuiz: () {
          setState(() {
            currentIndex = 2;
          });
        },
        onChallenge: () {
          setState(() {
            currentIndex = 3;
          });
        },
      ),
      const LearnScreen(),
      const QuizScreen(),
      const ChallengeScreen(),
      ProfileScreen(
        user: widget.user,
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports_rounded),
            label: 'Challenge',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}