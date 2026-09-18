import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/quiz_screen.dart';

void main() {
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
      home: const TechStepHome(),
    );
  }
}

class TechStepHome extends StatefulWidget {
  const TechStepHome({super.key});

  @override
  State<TechStepHome> createState() => _TechStepHomeState();
}

class _TechStepHomeState extends State<TechStepHome> {
  int currentIndex = 0;

  late final List<Widget> pages = [
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
      onChallenge: () {},
    ),
    const LearnScreen(),
    const QuizScreen(),
  ];

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
        ],
      ),
    );
  }
}