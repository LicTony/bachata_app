import 'dart:convert';
import 'paso.dart';

class PasoCoreografia {
  int pasoId;
  int orden;
  int repeticiones;

  PasoCoreografia({
    required this.pasoId,
    required this.orden,
    this.repeticiones = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'paso_id': pasoId,
      'orden': orden,
      'repeticiones': repeticiones,
    };
  }

  factory PasoCoreografia.fromMap(Map<String, dynamic> map) {
    return PasoCoreografia(
      pasoId: map['paso_id'],
      orden: map['orden'],
      repeticiones: map['repeticiones'] ?? 1,
    );
  }
}

class Coreografia {
  int? id;
  String nombre;
  String? descripcion;
  List<PasoCoreografia> pasosIds;
  DateTime fechaCreacion;
  int bpmDefault;

  // Lista temporal para almacenar los pasos cargados
  List<Paso> pasosCompletos = [];

  Coreografia({
    this.id,
    required this.nombre,
    this.descripcion,
    List<PasoCoreografia>? pasosIds,
    DateTime? fechaCreacion,
    this.bpmDefault = 120,
  })  : pasosIds = pasosIds ?? [],
        fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'pasos_ids': jsonEncode(pasosIds.map((p) => p.toMap()).toList()),
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'bpm_default': bpmDefault,
    };
  }

  factory Coreografia.fromMap(Map<String, dynamic> map) {
    List<PasoCoreografia> pasosList = [];
    if (map['pasos_ids'] != null) {
      final decoded = jsonDecode(map['pasos_ids']) as List;
      pasosList = decoded.map((p) => PasoCoreografia.fromMap(p)).toList();
    }

    return Coreografia(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      pasosIds: pasosList,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      bpmDefault: map['bpm_default'] ?? 120,
    );
  }

  void agregarPaso(int pasoId) {
    pasosIds.add(PasoCoreografia(
      pasoId: pasoId,
      orden: pasosIds.length,
    ));
    _reordenar();
  }

  void eliminarPaso(int index) {
    pasosIds.removeAt(index);
    _reordenar();
  }

  void moverPaso(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final paso = pasosIds.removeAt(oldIndex);
    pasosIds.insert(newIndex, paso);
    _reordenar();
  }

  void _reordenar() {
    for (int i = 0; i < pasosIds.length; i++) {
      pasosIds[i].orden = i;
    }
  }

  int get totalPasos => pasosIds.length;
}