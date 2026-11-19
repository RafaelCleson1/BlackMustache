import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.iconSize = 30,
  });

  final String url;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _Fallback(iconSize: iconSize);

    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceElevated,
          alignment: Alignment.center,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: AppColors.gold.withValues(alpha: 0.7),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _Fallback(iconSize: iconSize),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262626), Color(0xFF141414)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.content_cut_rounded,
        color: AppColors.gold.withValues(alpha: 0.55),
        size: iconSize,
      ),
    );
  }
}
