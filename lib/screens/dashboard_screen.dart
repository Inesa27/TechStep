import 'package:flutter/material.dart';
import '../services/learning_analytics_service.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onLearn;
  final VoidCallback? onQuiz;
  final VoidCallback? onChallenge;

  const DashboardScreen({
    super.key,
    this.onLearn,
    this.onQuiz,
    this.onChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  _buildHeader(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // WELCOME
                  // ==================================================

                  _buildWelcomeCard(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // PROGRESS BELAJAR
                  // ==================================================

                  const Text(
                    'Progress Belajar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildProgressCard(analytics),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MATERI PEMBELAJARAN
                  // ==================================================

                  const Text(
                    'Materi Pembelajaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildMaterialCard(
                    title: 'Hardware',
                    subtitle:
                        'Komponen fisik yang membentuk sistem komputer.',
                    icon: Icons.memory_rounded,
                    progress:
                        analytics.hardwareMastery / 100,
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 12),

                  _buildMaterialCard(
                    title: 'Software',
                    subtitle:
                        'Perangkat lunak yang digunakan untuk menjalankan komputer.',
                    icon: Icons.apps_rounded,
                    progress:
                        analytics.softwareMastery / 100,
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 12),

                  _buildMaterialCard(
                    title: 'Sistem Operasi',
                    subtitle:
                        'Perangkat lunak yang mengelola sumber daya komputer.',
                    icon:
                        Icons.desktop_windows_rounded,
                    progress:
                        analytics.operatingSystemMastery / 100,
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MULAI BELAJAR
                  // ==================================================

                  const Text(
                    'Mulai Belajar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Learn',
                          subtitle: 'Pelajari materi',
                          icon: Icons.menu_book_rounded,
                          onTap: onLearn,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildActionCard(
                          title: 'Quiz',
                          subtitle: 'Uji pemahaman',
                          icon: Icons.quiz_rounded,
                          onTap: onQuiz,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // RIWAYAT AKTIVITAS
                  // ==================================================

                  const Text(
                    'Riwayat Aktivitas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildActivityHistory(analytics),

                  const SizedBox(height: 24),

                  // ==================================================
                  // COMPUTER CHALLENGE
                  // ==================================================

                  _buildChallengeCard(
                    analytics,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TechStep',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              SizedBox(height: 2),

              Text(
                'Belajar Informatika dengan langkahmu',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Siap melanjutkan\nlangkah belajarmu?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Pelajari materi, kerjakan quiz, dan tantang kemampuanmu.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: onLearn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    const Color(0xFF4F46E5),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Belajar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard(
    LearningAnalyticsService analytics,
  ) {
    final progress = analytics.overallProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEEF2FF),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color:
                      Color(0xFF4F46E5),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Belajar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Perkembangan pembelajaranmu',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF4F46E5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child:
                LinearProgressIndicator(
              value: progress / 100,
              minHeight: 9,
              backgroundColor:
                  const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Color(0xFF4F46E5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                analytics.quizCompleted
                    ? 'Quiz sudah dikerjakan'
                    : '3 materi tersedia',
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Color(0xFF6B7280),
                ),
              ),

              Text(
                analytics.learningStatus,
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MATERIAL CARD
  // ============================================================

  Widget _buildMaterialCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double progress,
    VoidCallback? onTap,
  }) {
    final percentage =
        (progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFEEF2FF),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Icon(
                icon,
                color:
                    const Color(0xFF4F46E5),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 9),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    child:
                        LinearProgressIndicator(
                      value:
                          progress,
                      minHeight: 6,
                      backgroundColor:
                          const Color(
                        0xFFE5E7EB,
                      ),
                      valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                        Color(
                          0xFF6366F1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '$percentage%',
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF4F46E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFEEF2FF),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Icon(
                icon,
                color:
                    const Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RIWAYAT AKTIVITAS
  // ============================================================

  Widget _buildActivityHistory(
    LearningAnalyticsService analytics,
  ) {
    if (analytics.activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFEEF2FF),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
                color:
                    Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum ada aktivitas',
                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1F2937),
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Mulai belajar untuk melihat riwayat aktivitasmu.',
                    style:
                        TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final activities =
        analytics.activities.take(5).toList();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          ...List.generate(
            activities.length,
            (index) {
              final activity =
                  activities[index];

              return Padding(
                padding:
                    EdgeInsets.only(
                  bottom:
                      index ==
                              activities.length -
                                  1
                          ? 0
                          : 14,
                ),
                child:
                    _buildActivityItem(
                  activity,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    LearningActivity activity,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(
            color:
                const Color(0xFFEEF2FF),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            activity.title
                    .toLowerCase()
                    .contains('quiz')
                ? Icons.quiz_rounded
                : Icons
                    .sports_esports_rounded,
            color:
                const Color(0xFF4F46E5),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                activity.description,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color:
                      Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _formatActivityTime(
                  activity.time,
                ),
                style:
                    const TextStyle(
                  fontSize: 10,
                  color:
                      Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatActivityTime(
    DateTime time,
  ) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '${time.day}/${time.month}/${time.year} • $hour:$minute';
  }

  // ============================================================
  // COMPUTER CHALLENGE
  // ============================================================

  Widget _buildChallengeCard(
    LearningAnalyticsService analytics,
  ) {
    final challengeProgress =
        analytics.completedChallengeLevels /
            LearningAnalyticsService
                .totalChallengeLevels;

    return InkWell(
      onTap: onChallenge,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              const Color(0xFF111827),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(alpha:0.10),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .sports_esports_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Computer Challenge',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Uji kemampuanmu melalui 5 level tantangan.',
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color:
                      Colors.white70,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                    child:
                        LinearProgressIndicator(
                      value:
                          challengeProgress,
                      minHeight: 7,
                      backgroundColor:
                          Colors.white
                              .withValues(alpha:
                        0.12,
                      ),
                      valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  '${analytics.completedChallengeLevels}/5',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}