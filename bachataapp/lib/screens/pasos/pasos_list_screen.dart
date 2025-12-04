import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/paso.dart';
import '../../providers/bachata_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/paso_card.dart';
import 'paso_form_screen.dart';
import 'paso_view_screen.dart';

class PasosListScreen extends StatelessWidget {
  const PasosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Mis Pasos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: Consumer<BachataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.pasos.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pasos.length,
            itemBuilder: (context, index) {
              final paso = provider.pasos[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PasoCard(
                  paso: paso,
                  onTap: () => _verPaso(context, paso),
                  onEdit: () => _editarPaso(context, paso),
                  onDelete: () => _confirmarEliminar(context, paso),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearPaso(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Paso'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pasos creados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _crearPaso(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear primer paso'),
          ),
        ],
      ),
    );
  }

  void _crearPaso(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasoFormScreen(),
      ),
    );
  }

  void _editarPaso(BuildContext context, Paso paso) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasoFormScreen(paso: paso),
      ),
    );
  }

  void _verPaso(BuildContext context, Paso paso) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasoViewScreen(paso: paso),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Paso paso) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar paso'),
        content: Text('¿Seguro que deseas eliminar "${paso.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<BachataProvider>().eliminarPaso(paso.id!);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${paso.nombre} eliminado'),
                  backgroundColor: AppColors.surface,
                ),
              );
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