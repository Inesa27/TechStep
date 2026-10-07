import 'package:flutter/foundation.dart';

import '../models/learning_content.dart';
import 'techstep_database.dart';

class LearningActivity {
  final String title;
  final String description;
  final String type;
  final DateTime time;

  const LearningActivity({
    required this.title,
    required this.description,
    required this.type,
    required this.time,
  });

  factory LearningActivity.fromMap(Map<String, Object?> map) {
    return LearningActivity(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'learn',
      time: DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
    );
  }
}

class LearningAnalyticsService extends ChangeNotifier {
  static final LearningAnalyticsService instance =
      LearningAnalyticsService._internal();

  LearningAnalyticsService._internal();

  static const int totalChallengeLevels = 5;

  final TechStepDatabase _database = TechStepDatabase.instance;

  bool initialized = false;
  bool quizCompleted = false;

  int quizScore = 0;
  int hardwareQuizScore = 0;
  int softwareQuizScore = 0;
  int operatingSystemQuizScore = 0;

  int hardwareMastery = 0;
  int softwareMastery = 0;
  int operatingSystemMastery = 0;

  int completedChallengeLevels = 0;
  int completedMaterials = 0;
  int totalMaterials = 0;

  final List<LearningActivity> _activities = [];
  final List<CompetencyProgress> _competencies = [];

  List<LearningActivity> get activities {
    return List.unmodifiable(_activities);
  }

  List<CompetencyProgress> get competencies {
    return List.unmodifiable(_competencies);
  }

  List<CompetencyProgress> get competenciesNeedingSupport {
    return _competencies.where((item) {
      return item.masteryScore < 80;
    }).toList();
  }

  List<String> get recommendations {
    return competenciesNeedingSupport
        .map((item) => item.recommendation)
        .where((item) => item.isNotEmpty)
        .take(6)
        .toList();
  }

  Future<void> initialize() async {
    await _database.initialize();
    await refresh();
    initialized = true;
  }

  Future<void> refresh() async {
    quizCompleted = await _database.hasQuizResult();
    quizScore = await _database.latestQuizScore();

    final quizScores = await _database.latestQuizScoresByMaterial();
    hardwareQuizScore = quizScores['hardware'] ?? 0;
    softwareQuizScore = quizScores['software'] ?? 0;
    operatingSystemQuizScore = quizScores['sistem_operasi'] ?? 0;

    final materialScores = await _database.materialMasteryScores();
    hardwareMastery = materialScores['hardware'] ?? 0;
    softwareMastery = materialScores['software'] ?? 0;
    operatingSystemMastery = materialScores['sistem_operasi'] ?? 0;

    completedChallengeLevels = await _database.completedChallengeLevels();
    completedMaterials = await _database.completedSubmaterials();
    totalMaterials = await _database.totalSubmaterials();

    final activityRows = await _database.getActivities(limit: 20);
    _activities
      ..clear()
      ..addAll(activityRows.map(LearningActivity.fromMap));

    final competencyRows = await _database.getCompetencyProgress();
    _competencies
      ..clear()
      ..addAll(competencyRows);

    notifyListeners();
  }

  Future<void> recordSubmaterialOpened(Submaterial submaterial) async {
    await _database.recordSubmaterialOpened(submaterial);
    await refresh();
  }

  Future<void> recordQuizResult({
    required List<LearningQuestion> questions,
    required Map<String, String> selectedOptionKeys,
  }) async {
    await _database.recordQuizResult(
      questions: questions,
      selectedOptionKeys: selectedOptionKeys,
    );
    await refresh();
  }

  Future<void> recordChallengeResult({
    required int levelId,
    required List<LearningQuestion> questions,
    required Map<String, String> firstSelectedOptionKeys,
  }) async {
    await _database.recordChallengeResult(
      levelId: levelId,
      questions: questions,
      firstSelectedOptionKeys: firstSelectedOptionKeys,
    );
    await refresh();
  }

  double get challengeProgress {
    return (completedChallengeLevels / totalChallengeLevels) * 100;
  }

  int get learningProgress {
    if (totalMaterials == 0) {
      return 0;
    }

    return ((completedMaterials / totalMaterials) * 100).round();
  }

  int get overallProgress {
    final learnContribution = learningProgress * 0.30;
    final quizContribution = quizCompleted ? 30.0 : 0.0;
    final challengeContribution = challengeProgress * 0.40;

    return (learnContribution + quizContribution + challengeContribution)
        .round()
        .clamp(0, 100);
  }

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

  String competencyStatus(int score) {
    return _database.competencyStatus(score);
  }
}
