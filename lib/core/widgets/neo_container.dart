import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeoContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double shadowOffset;

  const NeoContainer({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.padding = const EdgeInsets.all(16),
    this.radius = 12,
    this.shadowOffset = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.outline, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0, // hard shadow, bukan blur — ciri khas neobrutalism
          ),
        ],
      ),
      child: child,
    );
  }
}