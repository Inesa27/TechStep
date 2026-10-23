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
          backgroundColor:
              Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  _buildWelcomeCard(context),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Progress Belajar',
                    subtitle:
                        'Pantau perkembangan belajarmu.',
                  ),

                  const SizedBox(height: 14),

                  _buildProgressCard(
                    context,
                    analytics,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Materi Pembelajaran',
                    subtitle:
                        'Tiga materi utama Sistem Komputer.',
                  ),

                  const SizedBox(height: 14),

                  _buildMaterialCard(
                    context,
                    title: 'Hardware',
                    subtitle:
                        'Kenali komponen fisik komputer.',
                    icon: Icons.memory_rounded,
                    progress:
                        analytics.hardwareMastery / 100,
                    iconColor: const Color(0xFF5547E8),
                    iconBackground:
                        const Color(0xFFEEEDFF),
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 12),

                  _buildMaterialCard(
                    context,
                    title: 'Software',
                    subtitle:
                        'Pelajari perangkat lunak komputer.',
                    icon: Icons.apps_rounded,
                    progress:
                        analytics.softwareMastery / 100,
                    iconColor: const Color(0xFF239B70),
                    iconBackground:
                        const Color(0xFFE8F7F0),
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 12),

                  _buildMaterialCard(
                    context,
                    title: 'Sistem Operasi',
                    subtitle:
                        'Pahami pengelolaan sumber daya komputer.',
                    icon: Icons.desktop_windows_rounded,
                    progress: analytics
                            .operatingSystemMastery /
                        100,
                    iconColor: const Color(0xFFB56A20),
                    iconBackground:
                        const Color(0xFFFFF1E2),
                    onTap: onLearn,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Mulai Belajar',
                    subtitle:
                        'Pilih aktivitas yang ingin kamu lakukan.',
                  ),

                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Learn',
                          subtitle: 'Pelajari materi',
                          icon: Icons.menu_book_rounded,
                          onTap: onLearn,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Quiz',
                          subtitle: 'Uji pemahaman',
                          icon: Icons.quiz_rounded,
                          onTap: onQuiz,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Computer Challenge',
                    subtitle:
                        'Tantang pemahamanmu melalui permainan.',
                  ),

                  const SizedBox(height: 14),

                  _buildChallengeCard(
                    context,
                    analytics,
                  ),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    context,
                    'Riwayat Aktivitas',
                    subtitle:
                        'Lihat aktivitas belajar terakhirmu.',
                  ),

                  const SizedBox(height: 14),

                  _buildActivityHistory(
                    context,
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

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TechStep',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Belajar Informatika dengan langkahmu',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                'Kelas X',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lightPrimary = Color.lerp(
      scheme.primary,
      Colors.white,
      0.20,
    )!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            lightPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(
              alpha: 0.14,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -24,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: -45,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Siap melanjutkan\nlangkah belajarmu?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Pelajari materi, kerjakan quiz, dan '
                'uji kemampuanmu melalui tantangan.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: onLearn,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: const Text('Mulai Belajar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  backgroundColor: Colors.white,
                  foregroundColor: scheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard(
    BuildContext context,
    LearningAnalyticsService analytics,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final progress =
        analytics.overallProgress.clamp(0, 100).toInt();

    final progressValue = progress / 100.0;

    return _DashboardSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.insights_rounded,
                color: scheme.primary,
                backgroundColor: scheme.secondary,
                size: 50,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres keseluruhan',
                      style:
                          textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Pencapaian belajar saat ini',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Text(
                '$progress%',
                style: textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              backgroundColor:
                  Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                scheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: scheme.primary,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  analytics.quizCompleted
                      ? 'Quiz sudah dikerjakan'
                      : 'Tersedia 3 materi pembelajaran',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: scheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                analytics.learningStatus,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MATERIAL CARD
  // ============================================================

  Widget _buildMaterialCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required double progress,
    required Color iconColor,
    required Color iconBackground,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final normalizedProgress =
        progress.clamp(0.0, 1.0);

    final percentage =
        (normalizedProgress * 100).round();

    return _DashboardSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _IconBadge(
            icon: icon,
            color: iconColor,
            backgroundColor: iconBackground,
            size: 52,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: normalizedProgress,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).dividerColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),

              const SizedBox(height: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: scheme.onSurface.withValues(
                  alpha: 0.45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _DashboardSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(
            icon: icon,
            color: scheme.primary,
            backgroundColor: scheme.secondary,
            size: 46,
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                'Buka',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),

              const SizedBox(width: 5),

              Icon(
                Icons.arrow_forward_rounded,
                color: scheme.primary,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPUTER CHALLENGE
  // ============================================================

  Widget _buildChallengeCard(
    BuildContext context,
    LearningAnalyticsService analytics,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total =
        LearningAnalyticsService.totalChallengeLevels;

    final completed =
        analytics.completedChallengeLevels
            .clamp(0, total);

    final progress = total > 0
        ? completed / total
        : 0.0;

    return _DashboardSurfaceCard(
      onTap: onChallenge,
      padding: const EdgeInsets.all(18),
      backgroundColor: scheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.sports_esports_rounded,
                color: scheme.primary,
                backgroundColor: Colors.white,
                size: 52,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Computer Challenge',
                      style:
                          textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Uji kemampuanmu melalui 5 level '
                      'tantangan.',
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: scheme.primary,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 7,
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      scheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '$completed/$total',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            'Level selesai',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVITY HISTORY
  // ============================================================

  Widget _buildActivityHistory(
    BuildContext context,
    LearningAnalyticsService analytics,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (analytics.activities.isEmpty) {
      return _DashboardSurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _IconBadge(
              icon: Icons.history_rounded,
              color: scheme.primary,
              backgroundColor: scheme.secondary,
              size: 48,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum ada aktivitas',
                    style: textTheme.titleSmall,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Mulai belajar atau kerjakan quiz '
                    'untuk melihat riwayat aktivitasmu.',
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
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

    return _DashboardSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          activities.length,
          (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == activities.length - 1
                    ? 0
                    : 17,
              ),
              child: _buildActivityItem(
                context,
                activities[index],
                isLast:
                    index == activities.length - 1,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    LearningActivity activity, {
    required bool isLast,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final activityTitle =
        activity.title.toLowerCase();

    final isQuiz = activityTitle.contains('quiz');

    final isChallenge =
        activityTitle.contains('challenge');

    final icon = isQuiz
        ? Icons.quiz_rounded
        : isChallenge
            ? Icons.sports_esports_rounded
            : Icons.menu_book_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBadge(
          icon: icon,
          color: scheme.primary,
          backgroundColor: scheme.secondary,
          size: 42,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                activity.description,
                style: textTheme.bodySmall?.copyWith(
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _formatActivityTime(activity.time),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT WAKTU
  // ============================================================

  String _formatActivityTime(DateTime time) {
    final day =
        time.day.toString().padLeft(2, '0');

    final month =
        time.month.toString().padLeft(2, '0');

    final year = time.year;

    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }
}

// ============================================================
// REUSABLE DASHBOARD CARD
// ============================================================

class _DashboardSurfaceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const _DashboardSurfaceCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// REUSABLE ICON BADGE
// ============================================================

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  const _IconBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.50,
      ),
    );
  }
}