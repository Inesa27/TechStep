import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';
import '../widgets/techstep_components.dart';

// ============================================================
// LEARN SCREEN
// ============================================================

class LearnScreen extends StatefulWidget {
  final ValueChanged<bool>? onSubpageChanged;

  const LearnScreen({super.key, this.onSubpageChanged});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  Color get _background => Theme.of(context).scaffoldBackgroundColor;
  Color get _surface => Theme.of(context).colorScheme.surface;
  Color get _surfaceMuted => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _primarySoft => Theme.of(context).colorScheme.primaryContainer;
  Color get _textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get _textSecondary => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _border => Theme.of(context).colorScheme.outlineVariant;
  Color get _success => Theme.of(context).brightness == Brightness.dark
      ? Color(0xFF69D5AE)
      : Color(0xFF239B70);

  @override
  Widget build(BuildContext context) {
    final analytics = LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: FutureBuilder<List<LearningMaterial>>(
              future: TechStepDatabase.instance.getMaterialsWithProgress(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: _primary),
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
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      TechStepGradientHeader(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Ruang Belajar',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Belajar lebih terarah',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _HeaderProgress(
                              progress: analytics.learningProgress,
                            ),
                          ],
                        ),
                      ),
                      TechStepPageFrame(
                        maxWidth: 920,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TechStepSectionTitle(
                                title: 'Kategori materi',
                                subtitle: 'Pilih topik.',
                                trailing: Text(
                                  '${materials.length} topik',
                                  style: TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildCategoryGrid(materials),
                              const SizedBox(height: 28),
                              const TechStepSectionTitle(
                                title: 'Materi',
                                subtitle: 'Lanjutkan belajar.',
                              ),
                              const SizedBox(height: 14),
                              ...materials.map(
                                (material) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildMaterialCard(context, material),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildLearningTip(),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildCategoryGrid(List<LearningMaterial> materials) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: materials.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final material = materials[index];
        final color = _colorFromHex(material.colorHex);
        return TechStepCard(
          padding: const EdgeInsets.all(13),
          radius: 20,
          backgroundColor: color.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.18
                : 0.10,
          ),
          onTap: () => _openMaterial(context, material),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFromKey(material.iconKey), color: color, size: 28),
              const Spacer(),
              Text(
                material.title,
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${(material.progress * 100).round()}% selesai',
                style: TextStyle(fontSize: 11, color: _textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMaterial(
    BuildContext context,
    LearningMaterial material,
  ) async {
    widget.onSubpageChanged?.call(true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MaterialDetailScreen(material: material),
      ),
    );
    if (mounted) {
      widget.onSubpageChanged?.call(false);
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: _textSecondary),
            SizedBox(height: 14),
            Text(
              'Materi belum dapat dimuat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 48, color: _primary),
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
              style: TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // KARTU PEMBUKA DAN RINGKASAN PROGRES
  // ------------------------------------------------------------

  // Kept as a legacy private variant for existing screen references.
  // ignore: unused_element
  Widget _buildIntroCard(int learningProgress) {
    final progress = (learningProgress / 100).clamp(0.0, 1.0).toDouble();

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
                    child: Text(
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
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 19),
              Text(
                'Ayo Tingkatkan\nPemahamanmu!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Pelajari Hardware, Software, dan Sistem Operasi secara bertahap.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 22),
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
                        Expanded(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildMaterialCard(BuildContext context, LearningMaterial material) {
    final color = _colorFromHex(material.colorHex);
    final percentage = (material.progress * 100).round();

    final isComplete =
        material.totalSubmaterials > 0 &&
        material.completedSubmaterials >= material.totalSubmaterials;

    final statusText = isComplete
        ? 'Selesai'
        : material.completedSubmaterials == 0
        ? 'Belum dipelajari'
        : 'Sedang dipelajari';

    final statusColor = isComplete ? _success : _primary;

    final statusBackground = isComplete
        ? _success.withValues(alpha: 0.12)
        : _primarySoft;

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openMaterial(context, material),
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
                  SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            material.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _textSecondary,
                    size: 26,
                  ),
                ],
              ),
              SizedBox(height: 17),
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
                    SizedBox(width: 6),
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
              SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progres materi',
                    style: TextStyle(fontSize: 12, color: _textSecondary),
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
              SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: material.progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  backgroundColor: _surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${material.completedSubmaterials}/${material.totalSubmaterials} submateri dibuka',
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                  ),
                  Text(
                    isComplete ? 'Pelajari lagi' : 'Mulai belajar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: _primary),
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
        color: _primarySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.lightbulb_rounded, color: _primary, size: 24),
          ),
          SizedBox(width: 13),
          Expanded(
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

class _HeaderProgress extends StatelessWidget {
  final int progress;

  const _HeaderProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 4,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'progres',
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

// ============================================================
// MATERIAL DETAIL SCREEN
// ============================================================

class MaterialDetailScreen extends StatefulWidget {
  final LearningMaterial material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  Color get _background => Theme.of(context).scaffoldBackgroundColor;
  Color get _surface => Theme.of(context).colorScheme.surface;
  Color get _surfaceMuted => Theme.of(context).colorScheme.surfaceContainerLow;
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color get _primarySoft => Theme.of(context).colorScheme.primaryContainer;
  Color get _textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get _textSecondary => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _border => Theme.of(context).colorScheme.outlineVariant;
  Color get _success => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF69D5AE)
      : const Color(0xFF239B70);

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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.material.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Submaterial>>(
          future: _submaterialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _primary));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Submateri belum dapat dimuat.'));
            }

            final submaterials = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(color, submaterials.length),
                  SizedBox(height: 25),

                  Text(
                    'Tentang Materi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 11),
                  _buildDescriptionCard(),

                  SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Daftar Submateri',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${submaterials.length} bagian',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Pilih bagian yang ingin kamu pelajari.',
                    style: TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                  SizedBox(height: 16),

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
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
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
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'MATERI',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 19),
          Text(
            widget.material.title,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 7),
          Text(
            widget.material.subtitle,
            style: TextStyle(fontSize: 13, height: 1.6, color: _textSecondary),
          ),
          SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: color, size: 21),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$totalSubmaterials submateri tersedia',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: _textSecondary,
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
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Text(
        widget.material.description,
        style: TextStyle(fontSize: 13, height: 1.8, color: _textSecondary),
      ),
    );
  }

  Widget _buildNoSubmaterials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_rounded, color: _textSecondary, size: 36),
          SizedBox(height: 10),
          Text(
            'Belum ada submateri',
            style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
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
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await LearningAnalyticsService.instance.recordSubmaterialOpened(
              submaterial,
            );

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
                    : _border,
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
                        ? _success.withValues(alpha: 0.12)
                        : color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: submaterial.completed
                      ? Icon(Icons.check_rounded, color: _success, size: 22)
                      : Text(
                          number.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submaterial.title,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      if (submaterial.summary.isNotEmpty) ...[
                        SizedBox(height: 5),
                        Text(
                          submaterial.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: 7),
                      Text(
                        submaterial.completed
                            ? 'Sudah dipelajari'
                            : 'Ketuk untuk mempelajari',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: submaterial.completed ? _success : color,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: submaterial.completed ? color : _textSecondary,
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

  Future<void> _openSubmaterialAt(BuildContext context, int targetIndex) async {
    final target = submaterials[targetIndex];

    await LearningAnalyticsService.instance.recordSubmaterialOpened(target);

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
    final colorScheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final color = _colorFromHex(material.colorHex);
    final submaterial = submaterials[currentIndex];
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < submaterials.length - 1;

    final progress = (currentIndex + 1) / submaterials.length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          material.title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outlineVariant),
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
                        SizedBox(width: 11),
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      submaterial.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 23,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 17),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lanjutkan belajar sesuai urutan submateri.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22),

              ...submaterial.blocks.map(
                (block) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _buildContentBlock(context, block, color),
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  if (hasPrevious)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openSubmaterialAt(context, currentIndex - 1),
                        icon: Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text('Sebelumnya'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outlineVariant),
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
                    Spacer(),

                  SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (hasNext) {
                          _openSubmaterialAt(context, currentIndex + 1);
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
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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

              SizedBox(height: 10),

              Center(
                child: Text(
                  'Submateri ${currentIndex + 1} dari ${submaterials.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
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

  Widget _buildContentBlock(
    BuildContext context,
    ContentBlock block,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 3),
          child: Text(
            block.text,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        );

      case 'bullet':
        return _buildTextCard(
          context,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  block.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.75,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'image':
        return _buildImageCard(context, block);

      case 'table':
        return _buildTableCard(context, block);

      default:
        return _buildTextCard(
          context,
          child: Text(
            block.text,
            style: TextStyle(
              fontSize: 13,
              height: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
    }
  }

  Widget _buildTextCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _buildImageCard(BuildContext context, ContentBlock block) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colorScheme.outlineVariant),
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
            SizedBox(height: 11),
            Text(
              block.caption,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, ContentBlock block) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
          columnSpacing: 22,
          horizontalMargin: 12,
          columns: block.headers.map((header) {
            return DataColumn(
              label: Text(
                header,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          rows: block.rows.map((row) {
            return DataRow(
              cells: row.map((cell) {
                return DataCell(
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 220),
                    child: Text(
                      cell,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
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
