import 'dart:convert';

class TiempoPaso {
  String lider;
  String follower;

  TiempoPaso({
    this.lider = '',
    this.follower = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'lider': lider,
      'follower': follower,
    };
  }

  factory TiempoPaso.fromMap(Map<String, dynamic> map) {
    return TiempoPaso(
      lider: map['lider'] ?? '',
      follower: map['follower'] ?? '',
    );
  }

  TiempoPaso copy() {
    return TiempoPaso(lider: lider, follower: follower);
  }
}

class Paso {
  int? id;
  String nombre;
  List<TiempoPaso> tiempos;
  DateTime fechaCreacion;
  String? descripcion;
  String? categoria;

  Paso({
    this.id,
    required this.nombre,
    List<TiempoPaso>? tiempos,
    DateTime? fechaCreacion,
    this.descripcion,
    this.categoria,
  })  : tiempos = tiempos ?? List.generate(8, (_) => TiempoPaso()),
        fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tiempos': jsonEncode(tiempos.map((t) => t.toMap()).toList()),
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'descripcion': descripcion,
      'categoria': categoria,
    };
  }

  factory Paso.fromMap(Map<String, dynamic> map) {
    List<TiempoPaso> tiemposList = [];
    if (map['tiempos'] != null) {
      final decoded = jsonDecode(map['tiempos']) as List;
      tiemposList = decoded.map((t) => TiempoPaso.fromMap(t)).toList();
    } else {
      tiemposList = List.generate(8, (_) => TiempoPaso());
    }

    return Paso(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      tiempos: tiemposList,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      descripcion: map['descripcion'],
      categoria: map['categoria'],
    );
  }

  Paso copy() {
    return Paso(
      id: id,
      nombre: nombre,
      tiempos: tiempos.map((t) => t.copy()).toList(),
      fechaCreacion: fechaCreacion,
      descripcion: descripcion,
      categoria: categoria,
    );
  }

  // Obtener texto para un tiempo específico
  String getTextoLider(int index) => tiempos[index].lider;
  String getTextoFollower(int index) => tiempos[index].follower;
}