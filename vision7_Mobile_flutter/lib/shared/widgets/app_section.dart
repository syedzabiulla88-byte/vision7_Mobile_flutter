import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/custom_text_theme.dart';

class AppSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? rightAction;
  final List<Widget> children;
  final bool noPadding;

  const AppSection({
    super.key,
    required this.title,
    this.subtitle,
    this.rightAction,
    required this.children,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
      padding: noPadding ? EdgeInsets.zero : const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.h3),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (rightAction != null) rightAction!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
      ),
    );
  }
}
