import 'package:flutter/material.dart';

import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 42, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MingleTheme.violet, MingleTheme.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * .32),
        boxShadow: [
          BoxShadow(
            color: MingleTheme.purple.withValues(alpha: .24),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.forum_rounded, color: Colors.white, size: size * .53),
    );
    if (!showWordmark) return icon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 11),
        Text(
          'mingle',
          style: TextStyle(
            fontSize: size * .59,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
