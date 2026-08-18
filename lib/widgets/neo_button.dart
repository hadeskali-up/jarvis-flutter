import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NeoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor ?? NeoColors.yellow,
          border: Border.all(color: NeoColors.black, width: 3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? NeoColors.black, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor ?? NeoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
