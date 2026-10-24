
import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

// ============================================================
// LEARN SCREEN
// ============================================================

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const Color _background = Color(0xFFF4F3FC);
  static const Color _primary = Color(0xFF5547E8);
  static const Color _textPrimary = Color(0xFF242438);
  static const Color _textSecondary = Color(0xFF77778B);
  static const Color _border = Color(0xFFE7E5F2);

  @override
  Widget build(BuildContext context) {
    final analytics = LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: const Text(
              'Learn',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: SafeArea(
            child: FutureBuilder<List<LearningMaterial>>(
              future: TechStepDatabase.instance.getMaterialsWithProgress(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final materials = snapshot.data ?? [];

                if (materials.isEmpty) {
                  return _buildEmptyState();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(analytics.learningProgress),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Materi',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Tentukan topik yang ingin kamu pelajari.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${materials.length} Topik',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      ...materials.map(
                        (material) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildMaterialCard(context, material),
                        ),
                      ),

                      const SizedBox(height: 4),
                      _buildLearningTip(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: _textSecondary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Materi belum dapat dimuat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan periksa kembali dan coba buka halaman Learn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: _primary,
            ),
            SizedBox(height: 14),
            Text(
              'Belum ada materi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Materi pembelajaran akan ditampilkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // KARTU PEMBUKA DAN RINGKASAN PROGRES
  // ------------------------------------------------------------

  Widget _buildIntroCard(int learningProgress) {
    final progress =
        (learningProgress / 100).clamp(0.0, 1.0).toDouble();

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
            right: -35,
            top: 55,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 90,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 12,
                ),
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
                      'RUANG BELAJAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              const Text(
                'Ayo Tingkatkan\nPemahamanmu!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pelajari Hardware, Software, dan Sistem Operasi secara bertahap.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
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
                        const Expanded(
                          child: Text(
                            'Progres Belajar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '$learningProgress%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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

  // ------------------------------------------------------------
  // KARTU PILIHAN MATERI
  // ------------------------------------------------------------

  Widget _buildMaterialCard(
    BuildContext context,
    LearningMaterial material,
  ) {
    final color = _colorFromHex(material.colorHex);
    final percentage = (material.progress * 100).round();

    final isComplete = material.totalSubmaterials > 0 &&
        material.completedSubmaterials >= material.totalSubmaterials;

    final statusText = isComplete
        ? 'Selesai'
        : material.completedSubmaterials == 0
            ? 'Belum dipelajari'
            : 'Sedang dipelajari';

    final statusColor = isComplete
        ? const Color(0xFF239B70)
        : _primary;

    final statusBackground = isComplete
        ? const Color(0xFFE7F7EF)
        : const Color(0xFFEEEDFF);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialDetailScreen(
                material: material,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Icon(
                      _iconFromKey(material.iconKey),
                      color: color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            material.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9292A7),
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : Icons.menu_book_rounded,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progres materi',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 13,
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
                  value:
                      material.progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF0EFF7),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${material.completedSubmaterials}/${material.totalSubmaterials} submateri dibuka',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9292A7),
                      ),
                    ),
                  ),
                  Text(
                    isComplete ? 'Pelajari lagi' : 'Mulai belajar',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TIPS BELAJAR
  // ------------------------------------------------------------

  Widget _buildLearningTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDDBFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: _primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Belajar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pelajari setiap submateri secara bertahap dan pahami konsepnya sebelum melanjutkan ke topik berikutnya.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
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
}

// ============================================================
// MATERIAL DETAIL SCREEN
// ============================================================

class MaterialDetailScreen extends StatefulWidget {
  final LearningMaterial material;

  const MaterialDetailScreen({
    super.key,
    required this.material,
  });

  @override
  State<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late Future<List<Submaterial>> _submaterialsFuture;

  @override
  void initState() {
    super.initState();
    _loadSubmaterials();
  }

  void _loadSubmaterials() {
    _submaterialsFuture = TechStepDatabase.instance.getSubmaterials(
      widget.material.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(widget.material.colorHex);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F3FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.material.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF242438),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Submaterial>>(
          future: _submaterialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5547E8),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Submateri belum dapat dimuat.'),
              );
            }

            final submaterials = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(color, submaterials.length),
                  const SizedBox(height: 25),

                  const Text(
                    'Tentang Materi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF242438),
                    ),
                  ),
                  const SizedBox(height: 11),
                  _buildDescriptionCard(),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Submateri',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF242438),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEDFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${submaterials.length} bagian',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5547E8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Pilih bagian yang ingin kamu pelajari.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF77778B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (submaterials.isEmpty)
                    _buildNoSubmaterials()
                  else
                    ...List.generate(
                      submaterials.length,
                      (index) => _buildSubmaterialItem(
                        submaterial: submaterials[index],
                        number: index + 1,
                        color: color,
                        submaterials: submaterials,
                        currentIndex: index,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color color, int totalSubmaterials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  _iconFromKey(widget.material.iconKey),
                  color: color,
                  size: 34,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MATERI',
                  style: TextStyle(
                    color: Color(0xFF5547E8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            widget.material.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF242438),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            widget.material.subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF77778B),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: color,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$totalSubmaterials submateri tersedia',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF55556A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF9292A7),
                  size: 19,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E5F2)),
      ),
      child: Text(
        widget.material.description,
        style: const TextStyle(
          fontSize: 13,
          height: 1.8,
          color: Color(0xFF55556A),
        ),
      ),
    );
  }

  Widget _buildNoSubmaterials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E5F2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: Color(0xFF9292A7),
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada submateri',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF242438),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmaterialItem({
    required Submaterial submaterial,
    required int number,
    required Color color,
    required List<Submaterial> submaterials,
    required int currentIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await LearningAnalyticsService.instance
                .recordSubmaterialOpened(submaterial);

            if (!mounted) {
              return;
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmaterialScreen(
                  material: widget.material,
                  submaterials: submaterials,
                  currentIndex: currentIndex,
                ),
              ),
            );

            if (mounted) {
              setState(_loadSubmaterials);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: submaterial.completed
                    ? color.withValues(alpha: 0.55)
                    : const Color(0xFFE7E5F2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: submaterial.completed
                        ? const Color(0xFFE7F7EF)
                        : color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: submaterial.completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF239B70),
                          size: 22,
                        )
                      : Text(
                          number.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submaterial.title,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242438),
                        ),
                      ),
                      if (submaterial.summary.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          submaterial.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: Color(0xFF77778B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),
                      Text(
                        submaterial.completed
                            ? 'Sudah dipelajari'
                            : 'Ketuk untuk mempelajari',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: submaterial.completed
                              ? const Color(0xFF239B70)
                              : color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: submaterial.completed
                      ? color
                      : const Color(0xFF9292A7),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUBMATERIAL SCREEN
// ============================================================

class SubmaterialScreen extends StatelessWidget {
  final LearningMaterial material;
  final List<Submaterial> submaterials;
  final int currentIndex;

  const SubmaterialScreen({
    super.key,
    required this.material,
    required this.submaterials,
    required this.currentIndex,
  });

  Future<void> _openSubmaterialAt(
    BuildContext context,
    int targetIndex,
  ) async {
    final target = submaterials[targetIndex];

    await LearningAnalyticsService.instance.recordSubmaterialOpened(
      target,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => SubmaterialScreen(
          material: material,
          submaterials: submaterials,
          currentIndex: targetIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(material.colorHex);
    final submaterial = submaterials[currentIndex];
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < submaterials.length - 1;

    final progress = (currentIndex + 1) / submaterials.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F3FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          material.title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF242438),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE7E5F2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _iconFromKey(material.iconKey),
                            color: color,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            material.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        Text(
                          '${currentIndex + 1}/${submaterials.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF77778B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      submaterial.title,
                      style: const TextStyle(
                        color: Color(0xFF242438),
                        fontSize: 23,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 17),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0EFF7),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lanjutkan belajar sesuai urutan submateri.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF77778B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ...submaterial.blocks.map(
                (block) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _buildContentBlock(block, color),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  if (hasPrevious)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openSubmaterialAt(
                          context,
                          currentIndex - 1,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                        ),
                        label: const Text('Sebelumnya'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5547E8),
                          side: const BorderSide(
                            color: Color(0xFFDDD9F0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (hasNext) {
                          _openSubmaterialAt(
                            context,
                            currentIndex + 1,
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        hasNext
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded,
                        size: 18,
                      ),
                      label: Text(
                        hasNext ? 'Berikutnya' : 'Selesai',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5547E8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Submateri ${currentIndex + 1} dari ${submaterials.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9292A7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ISI MATERI BERDASARKAN JENIS BLOK
  // ------------------------------------------------------------

  Widget _buildContentBlock(ContentBlock block, Color color) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 3),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: Color(0xFF242438),
            ),
          ),
        );

      case 'bullet':
        return _buildTextCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.75,
                    color: Color(0xFF55556A),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'image':
        return _buildImageCard(block);

      case 'table':
        return _buildTableCard(block);

      default:
        return _buildTextCard(
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.8,
              color: Color(0xFF55556A),
            ),
          ),
        );
    }
  }

  Widget _buildTextCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E5F2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildImageCard(ContentBlock block) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E5F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              block.asset,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          if (block.caption.isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              block.caption,
              style: const TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF77778B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCard(ContentBlock block) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E5F2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: const WidgetStatePropertyAll(
            Color(0xFFEEEDFF),
          ),
          columnSpacing: 22,
          horizontalMargin: 12,
          columns: block.headers.map((header) {
            return DataColumn(
              label: Text(
                header,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF242438),
                ),
              ),
            );
          }).toList(),
          rows: block.rows.map((row) {
            return DataRow(
              cells: row.map((cell) {
                return DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      cell,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF55556A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// HELPER
// ============================================================

IconData _iconFromKey(String key) {
  switch (key) {
    case 'memory':
      return Icons.memory_rounded;
    case 'apps':
      return Icons.apps_rounded;
    case 'desktop':
      return Icons.desktop_windows_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}
