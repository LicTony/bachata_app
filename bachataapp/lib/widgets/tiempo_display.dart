import 'package:flutter/material.dart';
import '../models/paso.dart';
import '../utils/constants.dart';

class TiempoDisplay extends StatelessWidget {
  final TiempoPaso tiempo;
  final int tiempoIndex;
  final RolView rolView;

  const TiempoDisplay({
    super.key,
    required this.tiempo,
    required this.tiempoIndex,
    required this.rolView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del tiempo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      AppConstants.tiempos[tiempoIndex],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  AppConstants.tiemposDescriptivos[tiempoIndex],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Contenido según el rol
          if (rolView == RolView.lider || rolView == RolView.ambos)
            _buildRolCard(
              titulo: 'Líder',
              texto: tiempo.lider,
              color: AppColors.lider,
              icono: Icons.man,
            ),

          if (rolView == RolView.ambos) const SizedBox(height: 16),

          if (rolView == RolView.follower || rolView == RolView.ambos)
            _buildRolCard(
              titulo: 'Follower',
              texto: tiempo.follower,
              color: AppColors.follower,
              icono: Icons.woman,
            ),
        ],
      ),
    );
  }

  Widget _buildRolCard({
    required String titulo,
    required String texto,
    required Color color,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            texto.isEmpty ? 'Sin descripción' : texto,
            style: TextStyle(
              fontSize: 18,
              color: texto.isEmpty ? Colors.white38 : Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}