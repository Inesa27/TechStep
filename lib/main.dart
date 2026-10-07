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

class TechStepApp extends StatelessWidget {
  const TechStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechStep',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: AuthGate(
        authenticatedHomeBuilder: (user) {
          return TechStepHome(user: user);
        },
      ),
    );
  }
}

class TechStepHome extends StatefulWidget {
  final Map<String, dynamic> user;

  const TechStepHome({
    super.key,
    required this.user,
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
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),

          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),

          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Challenge',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}