import 'package:flutter/material.dart';

class AppConstants {
  // Tiempos de la bachata
  static const List<String> tiempos = ['1', '2', '3', 'T', '5', '6', '7', 'T'];
  
  // Nombres descriptivos de los tiempos
  static const List<String> tiemposDescriptivos = [
    'Tiempo 1', 'Tiempo 2', 'Tiempo 3', 'Tap 1',
    'Tiempo 5', 'Tiempo 6', 'Tiempo 7', 'Tap 2'
  ];
  
  // Velocidades disponibles (BPM)
  static const List<int> velocidades = [60, 80, 100, 120, 140, 160];
  static const int velocidadDefault = 120;
  
  // Duración de un tiempo en ms según BPM
  static int getMsPerBeat(int bpm) => (60000 / bpm).round();
}

class AppColors {
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color accent = Color(0xFFFF4081);
  static const Color lider = Color(0xFF2196F3);
  static const Color follower = Color(0xFFE91E63);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);
}

enum RolView { lider, follower, ambos }

extension RolViewExtension on RolView {
  String get nombre {
    switch (this) {
      case RolView.lider:
        return 'Líder';
      case RolView.follower:
        return 'Follower';
      case RolView.ambos:
        return 'Ambos';
    }
  }
  
  IconData get icono {
    switch (this) {
      case RolView.lider:
        return Icons.man;
      case RolView.follower:
        return Icons.woman;
      case RolView.ambos:
        return Icons.people;
    }
  }
}