import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final illustrationHeight = (constraints.maxHeight * 0.46).clamp(
              250.0,
              340.0,
            );

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    child: Column(
                      children: [
                        _buildBrand(context),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: illustrationHeight,
                          width: double.infinity,
                          child: _buildIllustration(context),
                        ),

                        const SizedBox(height: 16),

                        _buildIntroduction(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TechStep',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Belajar Informatika dengan langkahmu',
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6DCF4), Color(0xFFD5C8EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: -35, right: -30, child: _circle(130, 0x33FFFFFF)),
            Positioned(bottom: -45, left: -25, child: _circle(115, 0x22FFFFFF)),
            const Positioned(
              top: 28,
              left: 35,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 23),
            ),
            const Positioned(
              top: 65,
              right: 55,
              child: Icon(Icons.star_rounded, color: Colors.white, size: 28),
            ),
            const Positioned(
              top: 95,
              left: 80,
              child: Icon(
                Icons.star_rounded,
                color: Color(0xCCFFFFFF),
                size: 15,
              ),
            ),
            Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Container(height: 23, color: const Color(0xFFBBA5DE)),
            ),

            // Ilustrasi tumpukan buku.
            Positioned(
              bottom: 55,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -0.055,
                    child: _book(
                      width: 205,
                      color: const Color(0xFF70B7F2),
                      title: 'HARDWARE',
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(5, -5),
                    child: Transform.rotate(
                      angle: 0.045,
                      child: _book(
                        width: 230,
                        color: const Color(0xFF448FD0),
                        title: 'SOFTWARE',
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-5, -10),
                    child: Transform.rotate(
                      angle: -0.035,
                      child: _book(
                        width: 215,
                        color: const Color(0xFF8DC9F8),
                        title: 'SISTEM OPERASI',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 17,
              right: 18,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 22,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, int color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Color(color)),
    );
  }

  Widget _book({
    required double width,
    required Color color,
    required String title,
  }) {
    return Container(
      width: width,
      height: 65,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF448DC9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF44366C).withValues(alpha: 0.12),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 13,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.75),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              border: const Border(right: BorderSide(color: Color(0x33FFFFFF))),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF486DA8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
        ],
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mulai Belajar Hari Ini',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jelajahi materi Hardware, Software, dan Sistem '
            'Operasi. Uji pemahamanmu melalui kuis dan '
            'tantangan seru di TechStep.',
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 19),

          Row(
            children: [
              _feature(context, Icons.menu_book_rounded, 'Materi'),
              const SizedBox(width: 14),
              _feature(context, Icons.quiz_rounded, 'Quiz'),
              const SizedBox(width: 14),
              _feature(context, Icons.sports_esports_rounded, 'Challenge'),
            ],
          ),

          const SizedBox(height: 23),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mulai Belajar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 9),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
