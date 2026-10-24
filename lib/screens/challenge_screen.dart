
import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  static const Color _background = Color(0xFFF4F3FC);
  static const Color _primary = Color(0xFF5547E8);
  static const Color _primarySoft = Color(0xFFEEEDFF);
  static const Color _textPrimary = Color(0xFF242438);
  static const Color _textSecondary = Color(0xFF77778B);
  static const Color _border = Color(0xFFE7E5F2);
  static const Color _success = Color(0xFF239B70);
  static const Color _danger = Color(0xFFD93649);

  late Future<List<ChallengeLevel>> _levelsFuture;

  List<ChallengeLevel> levels = [];
  List<LearningQuestion> levelQuestions = [];
  List<bool> completedBoxes = [];
  List<bool> wrongBoxes = [];

  final Map<String, String> firstSelectedAnswers = {};

  int selectedLevel = -1;
  int currentBox = 0;

  bool loadingLevel = false;
  bool savingLevel = false;

  final List<Color> levelColors = const [
    Color(0xFF5547E8),
    Color(0xFF6358E8),
    Color(0xFF786BEA),
    Color(0xFF8B7EF0),
    Color(0xFF4538BC),
  ];

  @override
  void initState() {
    super.initState();
    _levelsFuture = TechStepDatabase.instance.getChallengeLevels();
  }

  void _reloadLevels() {
    _levelsFuture = TechStepDatabase.instance.getChallengeLevels();
  }

  bool isLevelUnlocked(int level) {
    if (level == 0) {
      return true;
    }

    if (level - 1 >= levels.length) {
      return false;
    }

    return levels[level - 1].completed;
  }

  // ============================================================
  // LOGIKA LEVEL
  // ============================================================

  Future<void> openLevel(int level) async {
    if (!isLevelUnlocked(level) || loadingLevel) {
      return;
    }

    setState(() {
      loadingLevel = true;
    });

    try {
      final questions =
          await TechStepDatabase.instance.getChallengeQuestions(
        levels[level].id,
      );

      if (!mounted) return;

      if (questions.isEmpty) {
        setState(() {
          loadingLevel = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soal untuk level ini belum tersedia.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        selectedLevel = level;
        currentBox = 0;
        levelQuestions = questions;
        completedBoxes = List<bool>.filled(questions.length, false);
        wrongBoxes = List<bool>.filled(questions.length, false);
        firstSelectedAnswers.clear();
        loadingLevel = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadingLevel = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Level gagal dibuka: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void exitLevel() {
    setState(() {
      selectedLevel = -1;
      currentBox = 0;
      levelQuestions = [];
      completedBoxes = [];
      wrongBoxes = [];
      firstSelectedAnswers.clear();
      savingLevel = false;
      _reloadLevels();
    });
  }

  void answerQuestion(String selectedAnswerKey) {
    if (savingLevel || currentBox >= levelQuestions.length) {
      return;
    }

    final question = levelQuestions[currentBox];

    firstSelectedAnswers.putIfAbsent(
      question.id,
      () => selectedAnswerKey,
    );

    if (selectedAnswerKey == question.correctOptionKey) {
      setState(() {
        completedBoxes[currentBox] = true;
        wrongBoxes[currentBox] = false;
      });

      _showCorrectAnswerDialog();
    } else {
      setState(() {
        wrongBoxes[currentBox] = true;
      });

      _showWrongAnswerDialog();
    }
  }

  // ============================================================
  // DIALOG JAWABAN
  // ============================================================

  void _showCorrectAnswerDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7EF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _success,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Jawaban Benar!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Hebat! Kotak ini berhasil kamu selesaikan. '
                'Lanjutkan perjalanan ke tantangan berikutnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _moveToNextBox();
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Lanjutkan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWrongAnswerDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEBEC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: _danger,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum Tepat!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Jawaban kamu belum tepat. Kotak tetap merah. '
                'Coba pahami kembali pertanyaannya dan pilih '
                'jawaban yang paling sesuai.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MENYELESAIKAN KOTAK DAN LEVEL
  // ============================================================

  Future<void> _moveToNextBox() async {
    final isLastBox = currentBox == levelQuestions.length - 1;

    if (!isLastBox) {
      setState(() {
        currentBox++;
      });
      return;
    }

    setState(() {
      savingLevel = true;
    });

    try {
      await LearningAnalyticsService.instance.recordChallengeResult(
        levelId: levels[selectedLevel].id,
        questions: levelQuestions,
        firstSelectedOptionKeys: firstSelectedAnswers,
      );

      if (!mounted) return;

      setState(() {
        savingLevel = false;
        _reloadLevels();
      });

      _showLevelComplete();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        savingLevel = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hasil level belum berhasil disimpan: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLevelComplete() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final lastLevel = selectedLevel == levels.length - 1;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: _primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                lastLevel ? 'Semua Level Selesai!' : 'Level Selesai!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                lastLevel
                    ? 'Selamat! Kamu telah menyelesaikan semua '
                        'level Computer Challenge.'
                    : 'Kamu telah menyelesaikan '
                        '${levels[selectedLevel].name}. '
                        'Level berikutnya sekarang sudah terbuka.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  exitLevel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Kembali ke Level'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PEMILIHAN HALAMAN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (loadingLevel) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (selectedLevel != -1) {
      if (levelQuestions.isEmpty ||
          currentBox >= levelQuestions.length) {
        return _buildEmptyLevelPage();
      }

      return _buildLevelPage();
    }

    return FutureBuilder<List<ChallengeLevel>>(
      future: _levelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _background,
            body: Center(
              child: CircularProgressIndicator(color: _primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildLoadError(snapshot.error.toString());
        }

        levels = snapshot.data ?? [];

        return _buildChallengeHome();
      },
    );
  }

  Widget _buildLoadError(String message) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEBEC),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: _danger,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Level gagal dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(_reloadLevels);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLevelPage() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text(
          'Computer Challenge',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 48,
                color: _primary,
              ),
              const SizedBox(height: 15),
              const Text(
                'Soal level tidak tersedia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kembali ke halaman level untuk memilih tantangan lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: exitLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HALAMAN UTAMA COMPUTER CHALLENGE
  // ============================================================

  Widget _buildChallengeHome() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Computer Challenge',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChallengeHeader(),
              const SizedBox(height: 28),
              const Text(
                'Level Tantangan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selesaikan tantangan secara berurutan untuk membuka '
                'level berikutnya.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              if (levels.isEmpty)
                _buildNoLevelsCard()
              else
                ...List.generate(
                  levels.length,
                  (index) => _buildLevelCard(index),
                ),
              const SizedBox(height: 6),
              _buildRubricCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeHeader() {
    final completedCount =
        levels.where((item) => item.completed).length;

    final progress = levels.isEmpty
        ? 0.0
        : completedCount / levels.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 65,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'MODE TANTANGAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              const Text(
                'Lompat, Jawab,\nSelesaikan Tantangan!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Lewati setiap kotak engklek dan uji pemahamanmu '
                'tentang sistem komputer melalui tantangan interaktif.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 23),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Progres Tantangan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completedCount dari ${levels.length} level selesai',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoLevelsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sports_esports_rounded,
            color: _primary,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Level belum tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU LEVEL
  // ============================================================

  Widget _buildLevelCard(int index) {
    final unlocked = isLevelUnlocked(index);
    final level = levels[index];
    final completed = level.completed;
    final color = levelColors[index % levelColors.length];

    final stateText = completed
        ? 'Level selesai'
        : unlocked
            ? 'Siap dimainkan'
            : 'Selesaikan level sebelumnya';

    final stateColor = completed
        ? _success
        : unlocked
            ? _primary
            : _textSecondary;

    final stateBackground = completed
        ? const Color(0xFFE7F7EF)
        : unlocked
            ? _primarySoft
            : const Color(0xFFF0EFF5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: unlocked ? Colors.white : const Color(0xFFF0EFF5),
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          onTap: unlocked ? () => openLevel(index) : null,
          borderRadius: BorderRadius.circular(23),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: completed
                    ? _success.withValues(alpha: 0.45)
                    : unlocked
                        ? _border
                        : const Color(0xFFE8E6EF),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 57,
                      height: 57,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? color.withValues(alpha: 0.12)
                            : const Color(0xFFE6E4ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : unlocked
                                ? Icons.sports_esports_rounded
                                : Icons.lock_rounded,
                        color: unlocked ? color : const Color(0xFFAAA7B9),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEVEL ${level.id}',
                              style: TextStyle(
                                color: unlocked ? color : _textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              level.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: unlocked
                                    ? _textPrimary
                                    : const Color(0xFFAAA7B9),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              level.description,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: unlocked
                                    ? _textSecondary
                                    : const Color(0xFFAAA7B9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : unlocked
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_outline_rounded,
                      color: completed
                          ? _success
                          : unlocked
                              ? _primary
                              : const Color(0xFFAAA7B9),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: stateBackground,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              completed
                                  ? Icons.check_circle_outline_rounded
                                  : unlocked
                                      ? Icons.play_circle_outline_rounded
                                      : Icons.lock_outline_rounded,
                              size: 13,
                              color: stateColor,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                stateText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: stateColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (completed)
                      Text(
                        'Nilai ${level.bestScore}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _success,
                        ),
                      )
                    else
                      const Text(
                        '5 kotak tantangan',
                        style: TextStyle(
                          fontSize: 10,
                          color: _textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRubricCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primarySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDDBFF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: _primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rubrik Penilaian',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '0–1 benar = Belum Siap\n'
                  '2–3 benar = Mulai Memahami\n'
                  '4 benar = Cukup Dikuasai\n'
                  '5 benar = Dikuasai dengan Baik',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.7,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HALAMAN TANTANGAN LEVEL
  // ============================================================

  Widget _buildLevelPage() {
    final question = levelQuestions[currentBox];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Keluar dari level',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
          onPressed: savingLevel ? null : exitLevel,
        ),
        title: Text(
          'Level ${levels[selectedLevel].id}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelTitle(),
              const SizedBox(height: 21),
              _buildHopscotchMap(),
              const SizedBox(height: 24),
              _buildCurrentQuestion(question),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTitle() {
    final color = levelColors[selectedLevel % levelColors.length];

    final completedCount =
        completedBoxes.where((completed) => completed).length;

    final progress = levelQuestions.isEmpty
        ? 0.0
        : completedCount / levelQuestions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.sports_esports_rounded,
                  color: color,
                  size: 29,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL ${levels[selectedLevel].id}',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levels[selectedLevel].name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            levels[selectedLevel].description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.6,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kotak terselesaikan',
                  style: TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
              ),
              Text(
                '$completedCount/${levelQuestions.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFF0EFF7),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAPAN ENGKLEK
  // ============================================================

  Widget _buildHopscotchMap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 19, 15, 21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.grid_4x4_rounded,
                  color: _primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Papan Engklek',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Selesaikan kotak secara berurutan',
                    style: TextStyle(
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final singleWidth = constraints.maxWidth < 175
                  ? constraints.maxWidth
                  : 155.0;

              final pairWidth =
                  ((constraints.maxWidth - 8) / 2)
                      .clamp(90.0, 155.0)
                      .toDouble();

              return Column(
                children: [
                  _buildHopscotchBox(4, width: singleWidth),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHopscotchBox(2, width: pairWidth),
                      const SizedBox(width: 8),
                      _buildHopscotchBox(3, width: pairWidth),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildHopscotchBox(1, width: singleWidth),
                  const SizedBox(height: 8),
                  _buildHopscotchBox(0, width: singleWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 13,
            runSpacing: 8,
            children: [
              _buildMapLegend(
                color: _success,
                label: 'Selesai',
              ),
              _buildMapLegend(
                color: _primary,
                label: 'Aktif',
              ),
              _buildMapLegend(
                color: _danger,
                label: 'Belum tepat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegend({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHopscotchBox(
    int boxIndex, {
    required double width,
  }) {
    if (boxIndex >= levelQuestions.length) {
      return SizedBox(
        width: width,
        height: 62,
      );
    }

    final active = boxIndex == currentBox;
    final completed = completedBoxes[boxIndex];
    final wrong = wrongBoxes[boxIndex];
    final levelColor = levelColors[selectedLevel % levelColors.length];

    late Color backgroundColor;
    late Color borderColor;
    late Color textColor;
    late IconData icon;

    if (completed) {
      backgroundColor = const Color(0xFFE7F7EF);
      borderColor = _success;
      textColor = _success;
      icon = Icons.check_circle_rounded;
    } else if (wrong) {
      backgroundColor = const Color(0xFFFDEBEC);
      borderColor = _danger;
      textColor = _danger;
      icon = Icons.close_rounded;
    } else if (active) {
      backgroundColor = _primary;
      borderColor = _primary;
      textColor = Colors.white;
      icon = Icons.location_on_rounded;
    } else {
      backgroundColor = const Color(0xFFF4F3FA);
      borderColor = _border;
      textColor = _textSecondary;
      icon = Icons.circle_outlined;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: active || wrong || completed ? 1.7 : 1,
        ),
        boxShadow: active && !wrong && !completed
            ? [
                BoxShadow(
                  color: levelColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              'Kotak ${boxIndex + 1}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU PERTANYAAN
  // ============================================================

  Widget _buildCurrentQuestion(LearningQuestion question) {
    final color = levelColors[selectedLevel % levelColors.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  question.materialTitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Kotak ${currentBox + 1}/${levelQuestions.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.track_changes_rounded,
                size: 17,
                color: _primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Kompetensi: ${question.competencyTitle}',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'TANTANGAN SAAT INI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Pilih jawabanmu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAnswerButton(option),
            ),
          ),
          if (savingLevel) ...[
            const SizedBox(height: 12),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: _primary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menyimpan hasil tantangan...',
                    style: TextStyle(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerButton(AnswerOption option) {
    return Material(
      color: const Color(0xFFFAF9FE),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: savingLevel
            ? null
            : () {
                answerQuestion(option.key);
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option.key,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9292A7),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
