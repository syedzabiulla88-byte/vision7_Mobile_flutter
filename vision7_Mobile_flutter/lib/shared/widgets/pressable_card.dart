import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Wraps an already-tappable card so it gets a ripple + border-highlight in
/// the current mode's accent color (gold for Academy, black for Leisure) on
/// press — the mobile equivalent of the website's hover state. Wrap the
/// existing card's outermost widget with this; it adds the interaction
/// layer without needing to touch the card's own decoration.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isAcademy;
  final BorderRadius borderRadius;

  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    required this.isAcademy,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.isAcademy ? AppColors.gold : AppColors.black;
    return Semantics(
      button: widget.onTap != null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: _pressed ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            onHighlightChanged: (v) {
              if (mounted) setState(() => _pressed = v);
            },
            splashColor: accent.withValues(alpha: 0.15),
            highlightColor: accent.withValues(alpha: 0.06),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
