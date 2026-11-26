import 'package:flutter/material.dart';

import 'services/learning_analytics_service.dart';
import 'screens/auth_gate.dart';
import 'screens/dashboard_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/techstep_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LearningAnalyticsService.instance.initialize();

  runApp(const TechStepApp());
}

// ============================================================
// TECHSTEP APP
// ============================================================

class TechStepApp extends StatefulWidget {
  const TechStepApp({super.key});

  @override
  State<TechStepApp> createState() => _TechStepAppState();
}

class _TechStepAppState extends State<TechStepApp> {
  final TechStepThemeController _themeController =
      TechStepThemeController.instance;

  @override
  void initState() {
    super.initState();
    _themeController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TechStep',

          theme: _buildTechStepTheme(),
          darkTheme: _buildTechStepDarkTheme(),
          themeMode: _themeController.mode,

          home: AuthGate(
            authenticatedHomeBuilder:
                (user, onLogout, {required showOnboarding}) {
                  return TechStepPostLoginFlow(
                    user: user,
                    onLogout: onLogout,
                    initiallyShowOnboarding: showOnboarding,
                  );
                },
          ),
        );
      },
    );
  }
}

// ============================================================
// POST-LOGIN FLOW
// ============================================================

class TechStepPostLoginFlow extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  final bool initiallyShowOnboarding;

  const TechStepPostLoginFlow({
    super.key,
    required this.user,
    required this.onLogout,
    required this.initiallyShowOnboarding,
  });

  @override
  State<TechStepPostLoginFlow> createState() => _TechStepPostLoginFlowState();
}

class _TechStepPostLoginFlowState extends State<TechStepPostLoginFlow> {
  late bool _showOnboarding = widget.initiallyShowOnboarding;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onContinue: () {
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    return TechStepHome(user: widget.user, onLogout: widget.onLogout);
  }
}

// ============================================================
// LIGHT MODE THEME
// ============================================================

ThemeData _buildTechStepTheme() {
  const primary = Color(0xFF7C3AED);
  const primarySoft = Color(0xFFF0E8FF);

  const background = Color(0xFFF8F6FC);
  const surface = Color(0xFFFFFFFF);

  const textPrimary = Color(0xFF28243D);
  const textSecondary = Color(0xFF77718D);
  const border = Color(0xFFEAE5F4);

  const success = Color(0xFF239B70);
  const danger = Color(0xFFD93649);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: primarySoft,
        onSecondary: textPrimary,
        primaryContainer: primarySoft,
        onPrimaryContainer: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: border,
        outlineVariant: border,
        surfaceContainerLowest: surface,
        surfaceContainerLow: const Color(0xFFFAF9FE),
        surfaceContainer: const Color(0xFFF6F5FB),
        surfaceContainerHigh: const Color(0xFFEFEFF5),
        error: danger,
        onError: Colors.white,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,

    // TYPOGRAPHY
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
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: textPrimary, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),

    // APP BAR
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

    // CARD
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: border),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    // INPUT
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(fontSize: 14, color: textSecondary),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
    ),

    // ELEVATED BUTTON
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        backgroundColor: const WidgetStatePropertyAll(primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),

    // OUTLINED BUTTON
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        foregroundColor: const WidgetStatePropertyAll(primary),
        side: const WidgetStatePropertyAll(BorderSide(color: border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),

    // TEXT BUTTON
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // BOTTOM NAVIGATION
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: surface,
      elevation: 0,
      indicatorColor: primarySoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);

        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? primary : textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          size: 22,
          color: selected ? primary : textSecondary,
        );
      }),
    ),

    // PROGRESS INDICATORS
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),

    // DIVIDER DAN ICON
    dividerColor: border,

    iconTheme: const IconThemeData(color: textSecondary),

    // INTERAKSI
    splashColor: primary.withValues(alpha: 0.08),
    highlightColor: primary.withValues(alpha: 0.04),
    hoverColor: primary.withValues(alpha: 0.04),
    focusColor: primary.withValues(alpha: 0.08),
    disabledColor: textSecondary,
    shadowColor: Colors.black.withValues(alpha: 0.05),
    primaryColor: primary,

    // STATUS COLORS
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
// DARK MODE THEME
// ============================================================

ThemeData _buildTechStepDarkTheme() {
  const primary = Color(0xFFB5A7FF);
  const primaryDark = Color(0xFF8A7AF2);
  const primarySoft = Color(0xFF332B4D);

  const background = Color(0xFF0D0D10);
  const surface = Color(0xFF17171C);

  const textPrimary = Color(0xFFF4F4F7);
  const textSecondary = Color(0xFFB4B4BE);
  const border = Color(0xFF303038);

  const success = Color(0xFF69D5AE);
  const danger = Color(0xFFFF7185);

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        onPrimary: const Color(0xFF171329),
        secondary: primarySoft,
        onSecondary: textPrimary,
        primaryContainer: primarySoft,
        onPrimaryContainer: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: const Color(0xFF46464F),
        outlineVariant: border,
        surfaceContainerLowest: const Color(0xFF111114),
        surfaceContainerLow: surface,
        surfaceContainer: const Color(0xFF1D1D23),
        surfaceContainerHigh: const Color(0xFF25252C),
        surfaceContainerHighest: const Color(0xFF2C2C34),
        error: danger,
        onError: Colors.white,
      );

  final baseTheme = ThemeData.dark(useMaterial3: true);

  return baseTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,

    textTheme: baseTheme.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),

    // APP BAR
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

    // CARD
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: border),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    // INPUT
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(fontSize: 14, color: textSecondary),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
    ),

    // ELEVATED BUTTON
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        backgroundColor: const WidgetStatePropertyAll(primaryDark),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),

    // OUTLINED BUTTON
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        foregroundColor: const WidgetStatePropertyAll(primary),
        side: const WidgetStatePropertyAll(BorderSide(color: border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),

    // TEXT BUTTON
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // BOTTOM NAVIGATION
    navigationBarTheme: NavigationBarThemeData(
      height: 76,
      backgroundColor: surface,
      elevation: 0,
      indicatorColor: primarySoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final selected = states.contains(WidgetState.selected);

        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? primary : textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          size: 22,
          color: selected ? primary : textSecondary,
        );
      }),
    ),

    // PROGRESS INDICATORS
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),

    dividerColor: border,

    iconTheme: const IconThemeData(color: textSecondary),

    splashColor: primary.withValues(alpha: 0.08),
    highlightColor: primary.withValues(alpha: 0.04),
    hoverColor: primary.withValues(alpha: 0.04),
    focusColor: primary.withValues(alpha: 0.08),
    disabledColor: textSecondary,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    primaryColor: primary,

    // STATUS COLORS
    extensions: const <ThemeExtension<dynamic>>[
      _TechStepStatusColors(
        success: success,
        danger: danger,
        successSoft: Color(0xFF263E3A),
        dangerSoft: Color(0xFF472A35),
      ),
    ],
  );
}

// ============================================================
// STATUS COLORS
// ============================================================

@immutable
class _TechStepStatusColors extends ThemeExtension<_TechStepStatusColors> {
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
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
    );
  }
}

// ============================================================
// TECHSTEP HOME AND NAVIGATION
// ============================================================

class TechStepHome extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const TechStepHome({super.key, required this.user, required this.onLogout});

  @override
  State<TechStepHome> createState() => _TechStepHomeState();
}

class _TechStepHomeState extends State<TechStepHome> {
  int currentIndex = 0;
  bool showBottomNavigation = true;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardScreen(
        userName: widget.user['name']?.toString() ?? 'Pelajar',
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
      LearnScreen(
        onSubpageChanged: (hidden) =>
            setState(() => showBottomNavigation = !hidden),
      ),
      QuizScreen(
        onSubpageChanged: (hidden) =>
            setState(() => showBottomNavigation = !hidden),
      ),
      ChallengeScreen(
        onSubpageChanged: (hidden) =>
            setState(() => showBottomNavigation = !hidden),
      ),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: showBottomNavigation
          ? SafeArea(
              top: false,
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: NavigationBar(
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
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
