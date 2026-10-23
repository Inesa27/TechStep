import 'package:flutter/material.dart';

import '../theme/techstep_theme.dart';

/// Kartu standar TechStep.
class TechStepCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double radius;
  final VoidCallback? onTap;

  const TechStepCard({
    super.key,
    required this.child,
    this.padding = TechStepSpacing.cardPadding,
    this.backgroundColor,
    this.radius = TechStepRadius.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return Material(
      color: backgroundColor ?? TechStepColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(
          color: TechStepColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Judul bagian dengan deskripsi dan widget opsional di kanan.
class TechStepSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const TechStepSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: TechStepSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// Latar ikon yang seragam.
class TechStepIconBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double? iconSize;

  const TechStepIconBadge({
    super.key,
    required this.icon,
    this.backgroundColor = TechStepColors.primarySoft,
    this.iconColor = TechStepColors.primary,
    this.size = 48,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          TechStepRadius.md,
        ),
      ),
      child: Icon(
        icon,
        size: iconSize ?? size * 0.48,
        color: iconColor,
      ),
    );
  }
}

/// Tombol utama dengan ukuran dan bentuk yang konsisten.
class TechStepPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const TechStepPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Bar progres dengan pilihan label dan persentase.
class TechStepProgressBar extends StatelessWidget {
  final double value;
  final String? label;
  final bool showPercentage;
  final double height;
  final Color color;

  const TechStepProgressBar({
    super.key,
    required this.value,
    this.label,
    this.showPercentage = true,
    this.height = 7,
    this.color = TechStepColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (value / 100).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ),
              if (showPercentage)
                Text(
                  '${value.round()}%',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(
            TechStepRadius.pill,
          ),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            color: color,
            backgroundColor: TechStepColors.border,
          ),
        ),
      ],
    );
  }
}