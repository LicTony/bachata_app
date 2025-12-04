import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/coreografia.dart';
import '../../models/paso.dart';
import '../../utils/constants.dart';
import '../../widgets/tiempo_button.dart';
import '../../widgets/tiempo_display.dart';

class CoreoExecutionScreen extends StatefulWidget {
  final Coreografia coreografia;

  const CoreoExecutionScreen({super.key, required this.coreografia});

  @override
  State<CoreoExecutionScreen> createState() => _CoreoExecutionScreenState();
}

class _CoreoExecutionScreenState extends State<CoreoExecutionScreen> {
  int _currentPasoIndex = 0;
  int _currentTiempoIndex = 0;
  RolView _rolView = RolView.ambos;
  bool _isPlaying = false;
  Timer? _timer;
  late int _bpm;
  int _repeticiones = 0;
  bool _loopEnabled = true;

  Paso get currentPaso => widget.coreografia.pasosCompletos[_currentPasoIndex];
  int get totalPasos => widget.coreografia.pasosCompletos.length;

  @override
  void initState() {
    super.initState();
    _bpm = widget.coreografia.bpmDefault;
    // Bloquear rotación para mejor experiencia
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      _avanzarTiempo();
    });
  }

  void _avanzarTiempo() {
    setState(() {
      if (_currentTiempoIndex < 7) {
        _currentTiempoIndex++;
      } else {
        // Fin del paso actual
        if (_currentPasoIndex < totalPasos - 1) {
          // Pasar al siguiente paso
          _currentPasoIndex++;
          _currentTiempoIndex = 0;
        } else {
          // Fin de la coreografía
          _repeticiones++;
          if (_loopEnabled) {
            _currentPasoIndex = 0;
            _currentTiempoIndex = 0;
          } else {
            _isPlaying = false;
            _timer?.cancel();
          }
        }
      }
    });
  }

  void _irAPaso(int index) {
    if (index < 0 || index >= totalPasos) return;
    setState(() {
      _currentPasoIndex = index;
      _currentTiempoIndex = 0;
    });
  }

  void _pasoAnterior() {
    if (_currentPasoIndex > 0) {
      _irAPaso(_currentPasoIndex - 1);
    }
  }

  void _pasoSiguiente() {
    if (_currentPasoIndex < totalPasos - 1) {
      _irAPaso(_currentPasoIndex + 1);
    }
  }

  void _reiniciar() {
    setState(() {
      _currentPasoIndex = 0;
      _currentTiempoIndex = 0;
      _repeticiones = 0;
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
        title: Text(widget.coreografia.nombre),
        actions: [
          // Toggle loop
          IconButton(
            icon: Icon(
              _loopEnabled ? Icons.repeat : Icons.repeat_one,
              color: _loopEnabled ? AppColors.primary : Colors.white54,
            ),
            onPressed: () => setState(() => _loopEnabled = !_loopEnabled),
            tooltip: _loopEnabled ? 'Loop activado' : 'Sin loop',
          ),
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
          // Indicador de progreso de pasos
          _buildPasosProgress(),

          // Info del paso actual
          _buildCurrentPasoHeader(),

          // Barra de tiempos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TiemposRow(
              selectedIndex: _currentTiempoIndex,
              isPlaying: _isPlaying,
              onTiempoSelected: (index) {
                setState(() => _currentTiempoIndex = index);
              },
            ),
          ),

          const SizedBox(height: 8),

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
                tiempo: currentPaso.tiempos[_currentTiempoIndex],
                tiempoIndex: _currentTiempoIndex,
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

  Widget _buildPasosProgress() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalPasos,
        itemBuilder: (context, index) {
          final paso = widget.coreografia.pasosCompletos[index];
          final isSelected = index == _currentPasoIndex;
          
          return GestureDetector(
            onTap: () => _irAPaso(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white24 : AppColors.cardDark,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    paso.nombre,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPasoHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                '${_currentPasoIndex + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPaso.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Paso ${_currentPasoIndex + 1} de $totalPasos • Rep: $_repeticiones',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _reiniciar,
            icon: const Icon(Icons.replay, color: Colors.white70),
            tooltip: 'Reiniciar',
          ),
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      rol.icono,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rol.nombre,
                      style: TextStyle(
                        fontSize: 12,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navegación de pasos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _currentPasoIndex > 0 ? _pasoAnterior : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Paso ant.'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
                const SizedBox(width: 40),
                TextButton.icon(
                  onPressed: _currentPasoIndex < totalPasos - 1 ? _pasoSiguiente : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Paso sig.'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Controles principales
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tiempo anterior
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentTiempoIndex = (_currentTiempoIndex - 1 + 8) % 8;
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
                
                // Tiempo siguiente
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentTiempoIndex = (_currentTiempoIndex + 1) % 8;
                    });
                  },
                  icon: const Icon(Icons.skip_next, size: 36),
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}