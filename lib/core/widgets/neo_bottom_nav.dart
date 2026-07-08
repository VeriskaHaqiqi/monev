import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeoBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NeoBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Dashboard'),
    (icon: Icons.receipt_long_rounded, label: 'Transaksi'),
    (icon: Icons.category_rounded, label: 'Kategori'),
    (icon: Icons.bar_chart_rounded, label: 'Statistik'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline, width: 2)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final selected = index == currentIndex;
              final item = _items[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}