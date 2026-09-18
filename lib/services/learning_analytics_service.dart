import 'package:flutter/foundation.dart';

class LearningActivity {
  final String title;
  final String description;
  final DateTime time;

  const LearningActivity({
    required this.title,
    required this.description,
    required this.time,
  });
}

class LearningAnalyticsService extends ChangeNotifier {
  static final LearningAnalyticsService instance =
      LearningAnalyticsService._internal();

  LearningAnalyticsService._internal();

  // ============================================================
  // DATA QUIZ
  // ============================================================

  bool quizCompleted = false;

  int quizScore = 0;

  int hardwareQuizScore = 0;
  int softwareQuizScore = 0;
  int operatingSystemQuizScore = 0;

  // ============================================================
  // DATA CHALLENGE
  // ============================================================

  int completedChallengeLevels = 0;

  static const int totalChallengeLevels = 5;

  // ============================================================
  // RIWAYAT AKTIVITAS
  // ============================================================

  final List<LearningActivity> _activities = [];

  List<LearningActivity> get activities {
    return List.unmodifiable(
      _activities.reversed,
    );
  }

  // ============================================================
  // CATAT HASIL QUIZ
  // ============================================================

  void recordQuizResult({
    required int totalCorrect,
    required int totalQuestions,
    required int hardwareScore,
    required int softwareScore,
    required int operatingSystemScore,
  }) {
    quizCompleted = true;

    quizScore =
        ((totalCorrect / totalQuestions) * 100).round();

    hardwareQuizScore = hardwareScore;
    softwareQuizScore = softwareScore;
    operatingSystemQuizScore = operatingSystemScore;

    _activities.add(
      LearningActivity(
        title: 'Quiz selesai',
        description: 'Nilai quiz: $quizScore',
        time: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  // ============================================================
  // CATAT LEVEL CHALLENGE
  // ============================================================

  void recordChallengeLevel({
    required int level,
  }) {
    if (level > completedChallengeLevels) {
      completedChallengeLevels = level;

      _activities.add(
        LearningActivity(
          title: 'Challenge selesai',
          description: 'Level $level berhasil diselesaikan',
          time: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // ============================================================
  // PROGRESS CHALLENGE
  // ============================================================

  double get challengeProgress {
    return (completedChallengeLevels /
            totalChallengeLevels) *
        100;
  }

  // ============================================================
  // PROGRESS KESELURUHAN
  //
  // Quiz = 50%
  // Challenge = 50%
  // ============================================================

  int get overallProgress {
    final quizProgress =
        quizCompleted ? 50.0 : 0.0;

    final challengeContribution =
        challengeProgress * 0.5;

    return (quizProgress +
            challengeContribution)
        .round();
  }

  // ============================================================
  // HITUNG PENGUASAAN KOMPETENSI
  //
  // 70% QUIZ
  // 30% CHALLENGE
  // ============================================================

  int _calculateMastery(int quizScore) {
    return (
      (quizScore * 0.70) +
      (challengeProgress * 0.30)
    ).round();
  }

  int get hardwareMastery {
    return _calculateMastery(
      hardwareQuizScore,
    );
  }

  int get softwareMastery {
    return _calculateMastery(
      softwareQuizScore,
    );
  }

  int get operatingSystemMastery {
    return _calculateMastery(
      operatingSystemQuizScore,
    );
  }

  // ============================================================
  // STATUS PEMBELAJARAN
  // ============================================================

  String get learningStatus {
    final progress = overallProgress;

    if (progress == 0) {
      return 'Belum Memulai Pembelajaran';
    }

    if (progress < 40) {
      return 'Sedang Memulai';
    }

    if (progress < 70) {
      return 'Sedang Berkembang';
    }

    if (progress < 100) {
      return 'Hampir Selesai';
    }

    return 'Pembelajaran Selesai';
  }

  // ============================================================
  // STATUS KOMPETENSI
  // ============================================================

  String competencyStatus(int score) {
    if (score >= 80) {
      return 'Sangat Baik';
    }

    if (score >= 60) {
      return 'Baik';
    }

    if (score >= 40) {
      return 'Cukup';
    }

    return 'Perlu Penguatan';
  }

  // ============================================================
  // RESET DATA
  //
  // Berguna untuk testing.
  // ============================================================

  void resetData() {
    quizCompleted = false;

    quizScore = 0;

    hardwareQuizScore = 0;
    softwareQuizScore = 0;
    operatingSystemQuizScore = 0;

    completedChallengeLevels = 0;

    _activities.clear();

    notifyListeners();
  }
}