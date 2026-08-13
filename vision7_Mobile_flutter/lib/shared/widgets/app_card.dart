import 'package:flutter/material.dart';
import '../../core/theme/custom_text_theme.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? imageUrl;
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.onTap,
    this.imageUrl,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 120,
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: AppColors.muted),
                    ),
                  ),
                ),
              if (title != null) ...[
                const SizedBox(height: 12),
                Text(title!, style: Theme.of(context).textTheme.h4),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
              if (child != null) ...[
                const SizedBox(height: 12),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
