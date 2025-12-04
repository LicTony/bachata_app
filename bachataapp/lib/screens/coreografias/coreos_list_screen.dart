import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coreografia.dart';
import '../../providers/bachata_provider.dart';
import '../../utils/constants.dart';
import 'coreo_form_screen.dart';
import 'coreo_execution_screen.dart';

class CoreosListScreen extends StatelessWidget {
  const CoreosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Mis Coreografías',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BachataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.coreografias.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.coreografias.length,
            itemBuilder: (context, index) {
              final coreo = provider.coreografias[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CoreoCard(
                  coreo: coreo,
                  onTap: () => _ejecutarCoreo(context, coreo),
                  onEdit: () => _editarCoreo(context, coreo),
                  onDelete: () => _confirmarEliminar(context, coreo),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearCoreo(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Coreo'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay coreografías creadas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Primero crea algunos pasos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _crearCoreo(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear coreografía'),
          ),
        ],
      ),
    );
  }

  void _crearCoreo(BuildContext context) {
    final provider = context.read<BachataProvider>();
    if (provider.pasos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes crear algunos pasos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CoreoFormScreen(),
      ),
    );
  }

  void _editarCoreo(BuildContext context, Coreografia coreo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreoFormScreen(coreografia: coreo),
      ),
    );
  }

  void _ejecutarCoreo(BuildContext context, Coreografia coreo) async {
    final provider = context.read<BachataProvider>();
    final coreoCompleta = await provider.getCoreografiaConPasos(coreo.id!);
    
    if (coreoCompleta == null || coreoCompleta.pasosCompletos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La coreografía no tiene pasos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreoExecutionScreen(coreografia: coreoCompleta),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Coreografia coreo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar coreografía'),
        content: Text('¿Seguro que deseas eliminar "${coreo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<BachataProvider>().eliminarCoreografia(coreo.id!);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoreoCard extends StatelessWidget {
  final Coreografia coreo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CoreoCard({
    required this.coreo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.queue_music,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coreo.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${coreo.totalPasos} pasos · ${coreo.bpmDefault} BPM',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (coreo.descripcion != null && coreo.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    coreo.descripcion!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}