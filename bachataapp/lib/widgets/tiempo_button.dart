import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TiempoButton extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const TiempoButton({
    super.key,
    required this.index,
    required this.isActive,
    this.isPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tiempo = AppConstants.tiempos[index];
    final isTap = tiempo == 'T';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? (isPlaying ? AppColors.accent : AppColors.primary)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.white24 : Colors.white10,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            tiempo,
            style: TextStyle(
              fontSize: isTap ? 14 : 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}

class TiemposRow extends StatelessWidget {
  final int selectedIndex;
  final bool isPlaying;
  final Function(int) onTiempoSelected;

  const TiemposRow({
    super.key,
    required this.selectedIndex,
    this.isPlaying = false,
    required this.onTiempoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          8,
          (index) => TiempoButton(
            index: index,
            isActive: index == selectedIndex,
            isPlaying: isPlaying,
            onTap: () => onTiempoSelected(index),
          ),
        ),
      ),
    );
  }
}