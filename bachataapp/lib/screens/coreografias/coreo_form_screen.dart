import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/paso.dart';
import '../../models/coreografia.dart';
import '../../providers/bachata_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/paso_card.dart';

class CoreoFormScreen extends StatefulWidget {
  final Coreografia? coreografia;

  const CoreoFormScreen({super.key, this.coreografia});

  @override
  State<CoreoFormScreen> createState() => _CoreoFormScreenState();
}

class _CoreoFormScreenState extends State<CoreoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  
  List<int> _pasosSeleccionados = [];
  int _bpm = AppConstants.velocidadDefault;
  bool _isLoading = false;

  bool get isEditing => widget.coreografia != null;

  @override
  void initState() {
    super.initState();
    final coreo = widget.coreografia;
    
    _nombreController = TextEditingController(text: coreo?.nombre ?? '');
    _descripcionController = TextEditingController(text: coreo?.descripcion ?? '');
    
    if (coreo != null) {
      _pasosSeleccionados = coreo.pasosIds.map((p) => p.pasoId).toList();
      _bpm = coreo.bpmDefault;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BachataProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(isEditing ? 'Editar Coreografía' : 'Nueva Coreografía'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.check, color: AppColors.primary),
              label: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información básica
            _buildSeccion(
              titulo: 'Información',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: _inputDecoration('Nombre de la coreografía *'),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'El nombre es requerido' : null,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: _inputDecoration('Descripción (opcional)'),
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Selector de BPM
                  Row(
                    children: [
                      const Text(
                        'Velocidad (BPM):',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _bpm,
                        dropdownColor: AppColors.cardDark,
                        style: const TextStyle(color: Colors.white),
                        items: AppConstants.velocidades.map((bpm) {
                          return DropdownMenuItem(
                            value: bpm,
                            child: Text('$bpm BPM'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _bpm = v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pasos de la coreografía (reordenables)
            _buildSeccion(
              titulo: 'Pasos en la coreografía (${_pasosSeleccionados.length})',
              child: _pasosSeleccionados.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Center(
                        child: Text(
                          'Agrega pasos desde la lista de abajo',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pasosSeleccionados.length,
                      onReorder: _reordenarPaso,
                      itemBuilder: (context, index) {
                        final pasoId = _pasosSeleccionados[index];
                        final paso = provider.getPasoById(pasoId);
                        
                        return ListTile(
                          key: ValueKey('$pasoId-$index'),
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            paso?.nombre ?? 'Paso eliminado',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.redAccent),
                                onPressed: () => _quitarPaso(index),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle,
                                    color: Colors.white38),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // Lista de pasos disponibles
            _buildSeccion(
              titulo: 'Pasos disponibles',
              child: Column(
                children: provider.pasos.map((paso) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PasoSelectableCard(
                      paso: paso,
                      onAdd: () => _agregarPaso(paso.id!),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({required String titulo, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  void _agregarPaso(int pasoId) {
    setState(() {
      _pasosSeleccionados.add(pasoId);
    });
  }

  void _quitarPaso(int index) {
    setState(() {
      _pasosSeleccionados.removeAt(index);
    });
  }

  void _reordenarPaso(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final paso = _pasosSeleccionados.removeAt(oldIndex);
      _pasosSeleccionados.insert(newIndex, paso);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pasosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un paso a la coreografía'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final pasosIds = _pasosSeleccionados.asMap().entries.map((e) {
      return PasoCoreografia(
        pasoId: e.value,
        orden: e.key,
      );
    }).toList();

    final coreo = Coreografia(
      id: widget.coreografia?.id,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      pasosIds: pasosIds,
      bpmDefault: _bpm,
      fechaCreacion: widget.coreografia?.fechaCreacion ?? DateTime.now(),
    );

    final provider = context.read<BachataProvider>();

    try {
      if (isEditing) {
        await provider.actualizarCoreografia(coreo);
      } else {
        await provider.agregarCoreografia(coreo);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Coreografía actualizada' : 'Coreografía creada'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _PasoSelectableCard extends StatelessWidget {
  final Paso paso;
  final VoidCallback onAdd;

  const _PasoSelectableCard({
    required this.paso,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.directions_walk,
            color: Colors.white54,
          ),
        ),
        title: Text(
          paso.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: paso.categoria != null
            ? Text(
                paso.categoria!,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              )
            : null,
        trailing: IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
        ),
      ),
    );
  }
}