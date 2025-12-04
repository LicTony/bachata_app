import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/paso.dart';
import '../../providers/bachata_provider.dart';
import '../../utils/constants.dart';

class PasoFormScreen extends StatefulWidget {
  final Paso? paso;

  const PasoFormScreen({super.key, this.paso});

  @override
  State<PasoFormScreen> createState() => _PasoFormScreenState();
}

class _PasoFormScreenState extends State<PasoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _categoriaController;
  late TextEditingController _descripcionController;
  
  late List<TextEditingController> _liderControllers;
  late List<TextEditingController> _followerControllers;
  
  int _selectedTiempo = 0;
  bool _isLoading = false;

  bool get isEditing => widget.paso != null;

  @override
  void initState() {
    super.initState();
    final paso = widget.paso;
    
    _nombreController = TextEditingController(text: paso?.nombre ?? '');
    _categoriaController = TextEditingController(text: paso?.categoria ?? '');
    _descripcionController = TextEditingController(text: paso?.descripcion ?? '');
    
    _liderControllers = List.generate(
      8,
      (i) => TextEditingController(text: paso?.tiempos[i].lider ?? ''),
    );
    
    _followerControllers = List.generate(
      8,
      (i) => TextEditingController(text: paso?.tiempos[i].follower ?? ''),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _descripcionController.dispose();
    for (var c in _liderControllers) {
      c.dispose();
    }
    for (var c in _followerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(isEditing ? 'Editar Paso' : 'Nuevo Paso'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
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
                    decoration: _inputDecoration('Nombre del paso *'),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'El nombre es requerido' : null,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoriaController,
                    decoration: _inputDecoration('Categoría (ej: Básico, Giros...)'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: _inputDecoration('Descripción (opcional)'),
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selector de tiempos
            _buildSeccion(
              titulo: 'Tiempos',
              child: Column(
                children: [
                  // Botones de tiempo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(8, (index) {
                        final isSelected = index == _selectedTiempo;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTiempo = index),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                AppConstants.tiempos[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campos para el tiempo seleccionado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      key: ValueKey(_selectedTiempo),
                      children: [
                        // Líder
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lider.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lider.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.man, color: AppColors.lider, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Líder - ${AppConstants.tiemposDescriptivos[_selectedTiempo]}',
                                    style: TextStyle(
                                      color: AppColors.lider,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _liderControllers[_selectedTiempo],
                                decoration: _inputDecoration('Movimiento del líder'),
                                maxLines: 2,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Follower
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.follower.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.follower.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.woman, color: AppColors.follower, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Follower - ${AppConstants.tiemposDescriptivos[_selectedTiempo]}',
                                    style: TextStyle(
                                      color: AppColors.follower,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _followerControllers[_selectedTiempo],
                                decoration: _inputDecoration('Movimiento del follower'),
                                maxLines: 2,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navegación rápida
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _selectedTiempo > 0
                            ? () => setState(() => _selectedTiempo--)
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                      ),
                      Text(
                        '${_selectedTiempo + 1} / 8',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      TextButton.icon(
                        onPressed: _selectedTiempo < 7
                            ? () => setState(() => _selectedTiempo++)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Siguiente'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Espacio para FAB
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tiempos = List.generate(8, (i) {
      return TiempoPaso(
        lider: _liderControllers[i].text.trim(),
        follower: _followerControllers[i].text.trim(),
      );
    });

    final paso = Paso(
      id: widget.paso?.id,
      nombre: _nombreController.text.trim(),
      categoria: _categoriaController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      tiempos: tiempos,
      fechaCreacion: widget.paso?.fechaCreacion ?? DateTime.now(),
    );

    final provider = context.read<BachataProvider>();

    try {
      if (isEditing) {
        await provider.actualizarPaso(paso);
      } else {
        await provider.agregarPaso(paso);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Paso actualizado' : 'Paso creado'),
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