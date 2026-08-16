import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';


class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );
  }
}