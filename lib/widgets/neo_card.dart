import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const NeoCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? NeoColors.white,
          border: Border.all(color: NeoColors.black, width: 3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
