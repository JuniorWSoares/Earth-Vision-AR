import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AtmosphereChart extends StatelessWidget {
  const AtmosphereChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                      flex: 78,
                      child: Container(color: AppColors.atmosphereNitrogen)),
                  Expanded(
                      flex: 21,
                      child: Container(color: AppColors.atmosphereOxygen)),
                  Expanded(flex: 1, child: Container(color: AppColors.white54)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(
                child: _LegendItem(
                    color: AppColors.atmosphereNitrogen,
                    label: 'Nitrogênio (78%)'),
              ),
              Flexible(
                child: _LegendItem(
                    color: AppColors.atmosphereOxygen, label: 'Oxigênio (21%)'),
              ),
              Flexible(
                child: _LegendItem(color: AppColors.white54, label: 'Outros (1%)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
