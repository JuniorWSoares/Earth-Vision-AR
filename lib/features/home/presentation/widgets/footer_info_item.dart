import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class FooterInfoItem extends StatelessWidget {
  const FooterInfoItem({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.white30),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white30,
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
