import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/paso.dart';
import '../../utils/constants.dart';
import '../../widgets/tiempo_button.dart';
import '../../widgets/tiempo_display.dart';

class PasoViewScreen extends StatefulWidget {
  final Paso paso;

  const PasoViewScreen({super.key, required this.paso});

  @override
  State<PasoViewScreen> createState() => _PasoViewScreenState();
}

class _PasoViewScreenState extends State<PasoViewScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTiempo = 0;
  RolView _rolView = RolView.ambos;
  bool _isPlaying = false;
  Timer? _timer;
  int _bpm = AppConstants.velocidadDefault;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAutoPlay();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startAutoPlay() {
    final interval = Duration(milliseconds: AppConstants.getMsPerBeat(_bpm));
    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        _selectedTiempo = (_selectedTiempo + 1) % 8;
        _pulseController.forward().then((_) => _pulseController.reverse());
      });
    });
  }

  void _selectTiempo(int index) {
    setState(() {
      _selectedTiempo = index;
      if (_isPlaying) {
        _timer?.cancel();
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.paso.nombre),
        actions: [
          // Selector de BPM
          PopupMenuButton<int>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 4),
                Text('$_bpm', style: const TextStyle(fontSize: 14)),
              ],
            ),
            onSelected: (bpm) {
              setState(() => _bpm = bpm);
              if (_isPlaying) {
                _timer?.cancel();
                _startAutoPlay();
              }
            },
            itemBuilder: (context) => AppConstants.velocidades.map((bpm) {
              return PopupMenuItem(
                value: bpm,
                child: Text(
                  '$bpm BPM',
                  style: TextStyle(
                    fontWeight: _bpm == bpm ? FontWeight.bold : FontWeight.normal,
                    color: _bpm == bpm ? AppColors.primary : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de tiempos
          Padding(
            padding: const EdgeInsets.all(16),
            child: TiemposRow(
              selectedIndex: _selectedTiempo,
              isPlaying: _isPlaying,
              onTiempoSelected: _selectTiempo,
            ),
          ),

          // Selector de rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRolSelector(),
          ),

          const SizedBox(height: 16),

          // Display del tiempo actual
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TiempoDisplay(
                tiempo: widget.paso.tiempos[_selectedTiempo],
                tiempoIndex: _selectedTiempo,
                rolView: _rolView,
              ),
            ),
          ),

          // Controles de reproducción
          _buildPlayControls(),
        ],
      ),
    );
  }

  Widget _buildRolSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: RolView.values.map((rol) {
          final isSelected = _rolView == rol;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _rolView = rol),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      rol.icono,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rol.nombre,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón anterior
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedTiempo = (_selectedTiempo - 1 + 8) % 8;
                });
              },
              icon: const Icon(Icons.skip_previous, size: 36),
              color: Colors.white70,
            ),
            
            const SizedBox(width: 20),
            
            // Botón Play/Pause
            GestureDetector(
              onTap: _togglePlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isPlaying
                        ? [AppColors.accent, AppColors.primary]
                        : [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Botón siguiente
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedTiempo = (_selectedTiempo + 1) % 8;
                });
              },
              icon: const Icon(Icons.skip_next, size: 36),
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}