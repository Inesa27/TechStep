import 'package:flutter/material.dart';

import '../models/learning_content.dart';
import '../services/learning_analytics_service.dart';
import '../services/techstep_database.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = LearningAnalyticsService.instance;

    return AnimatedBuilder(
      animation: analytics,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Learn',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: FutureBuilder<List<LearningMaterial>>(
              future: TechStepDatabase.instance.getMaterialsWithProgress(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final materials = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(analytics.learningProgress),
                      const SizedBox(height: 24),
                      const Text(
                        'Materi Pembelajaran',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pelajari materi dari dokumen bahan ajar. Riwayat submateri yang sudah dibuka akan tersimpan otomatis.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...materials.map(
                        (material) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildMaterialCard(context, material),
                        ),
                      ),
                      const SizedBox(height: 10),
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

  Widget _buildIntroCard(int learningProgress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mulai Langkah Belajarmu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Materi Hardware, Software, dan Sistem Operasi sudah tersusun per submateri sesuai bahan ajar.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: learningProgress / 100,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$learningProgress%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, LearningMaterial material) {
    final color = _colorFromHex(material.colorHex);
    final percentage = (material.progress * 100).round();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MaterialDetailScreen(material: material),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _iconFromKey(material.iconKey),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: material.progress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  material.completedSubmaterials == 0
                      ? 'Belum dipelajari'
                      : '${material.completedSubmaterials}/${material.totalSubmaterials} submateri dibuka',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  material.completedSubmaterials == 0
                      ? 'Mulai belajar'
                      : 'Lanjutkan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF4F46E5),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Belajar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Buka submateri secara bertahap. Progress Learn ikut menjadi bukti aktivitas pada pemetaan kompetensi.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF6B7280),
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

class MaterialDetailScreen extends StatefulWidget {
  final LearningMaterial material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.material.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Submaterial>>(
          future: _submaterialsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final submaterials = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(color),
                  const SizedBox(height: 24),
                  const Text(
                    'Tentang Materi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDescriptionCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Submateri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
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

  Widget _buildHeaderCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _iconFromKey(widget.material.iconKey),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.material.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.material.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        widget.material.description,
        style: const TextStyle(
          fontSize: 13,
          height: 1.7,
          color: Color(0xFF4B5563),
        ),
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
    return InkWell(
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: submaterial.completed ? color : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: submaterial.completed
                  ? Icon(Icons.check_rounded, color: color, size: 18)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submaterial.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  if (submaterial.summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      submaterial.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

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
    final color = _colorFromHex(material.colorHex);
    final submaterial = submaterials[currentIndex];
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < submaterials.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          material.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
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
                  color: color,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      submaterial.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...submaterial.blocks.map(
                (block) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildContentBlock(block, color),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (hasPrevious)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _openSubmaterialAt(context, currentIndex - 1),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Sebelumnya'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
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
                          hasNext ? 'Submateri Berikutnya' : 'Selesai',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Submateri ${currentIndex + 1} dari ${submaterials.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBlock(ContentBlock block, Color color) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        );
      case 'bullet':
        return _buildTextCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: Color(0xFF4B5563),
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
              height: 1.7,
              color: Color(0xFF4B5563),
            ),
          ),
        );
    }
  }

  Widget _buildTextCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              block.asset,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          if (block.caption.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              block.caption,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF6B7280),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: const WidgetStatePropertyAll(Color(0xFFEEF2FF)),
          columnSpacing: 22,
          horizontalMargin: 12,
          columns: block.headers.map((header) {
            return DataColumn(
              label: Text(
                header,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
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
                        height: 1.35,
                        color: Color(0xFF4B5563),
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
