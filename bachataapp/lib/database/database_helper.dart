import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/paso.dart';
import '../models/coreografia.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bachata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de pasos
    await db.execute('''
      CREATE TABLE pasos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tiempos TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        descripcion TEXT,
        categoria TEXT
      )
    ''');

    // Tabla de coreografías
    await db.execute('''
      CREATE TABLE coreografias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        pasos_ids TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        bpm_default INTEGER DEFAULT 120
      )
    ''');

    // Insertar pasos de ejemplo
    await _insertarPasosEjemplo(db);
  }

  Future<void> _insertarPasosEjemplo(Database db) async {
    final pasosEjemplo = [
      Paso(
        nombre: 'Paso Básico Lateral',
        tiempos: [
          TiempoPaso(lider: 'Pie izquierdo al lado izquierdo', follower: 'Pie derecho al lado derecho'),
          TiempoPaso(lider: 'Pie derecho junta al izquierdo', follower: 'Pie izquierdo junta al derecho'),
          TiempoPaso(lider: 'Pie izquierdo al lado izquierdo', follower: 'Pie derecho al lado derecho'),
          TiempoPaso(lider: 'Tap con pie derecho', follower: 'Tap con pie izquierdo'),
          TiempoPaso(lider: 'Pie derecho al lado derecho', follower: 'Pie izquierdo al lado izquierdo'),
          TiempoPaso(lider: 'Pie izquierdo junta al derecho', follower: 'Pie derecho junta al izquierdo'),
          TiempoPaso(lider: 'Pie derecho al lado derecho', follower: 'Pie izquierdo al lado izquierdo'),
          TiempoPaso(lider: 'Tap con pie izquierdo', follower: 'Tap con pie derecho'),
        ],
        categoria: 'Básico',
      ),
      Paso(
        nombre: 'Paso Básico Adelante-Atrás',
        tiempos: [
          TiempoPaso(lider: 'Pie izquierdo adelante', follower: 'Pie derecho atrás'),
          TiempoPaso(lider: 'Peso al pie derecho', follower: 'Peso al pie izquierdo'),
          TiempoPaso(lider: 'Pie izquierdo regresa', follower: 'Pie derecho regresa'),
          TiempoPaso(lider: 'Tap con pie derecho', follower: 'Tap con pie izquierdo'),
          TiempoPaso(lider: 'Pie derecho atrás', follower: 'Pie izquierdo adelante'),
          TiempoPaso(lider: 'Peso al pie izquierdo', follower: 'Peso al pie derecho'),
          TiempoPaso(lider: 'Pie derecho regresa', follower: 'Pie izquierdo regresa'),
          TiempoPaso(lider: 'Tap con pie izquierdo', follower: 'Tap con pie derecho'),
        ],
        categoria: 'Básico',
      ),
      Paso(
        nombre: 'Giro Simple Derecha',
        tiempos: [
          TiempoPaso(lider: 'Marca giro, paso izq adelante', follower: 'Inicia giro derecha, pie der'),
          TiempoPaso(lider: 'Pie derecho en lugar', follower: 'Continúa giro, pie izquierdo'),
          TiempoPaso(lider: 'Pie izquierdo junta', follower: 'Completa giro, pie derecho'),
          TiempoPaso(lider: 'Tap derecho', follower: 'Tap izquierdo'),
          TiempoPaso(lider: 'Retoma posición, pie der atrás', follower: 'Retoma, pie izq adelante'),
          TiempoPaso(lider: 'Peso al izquierdo', follower: 'Peso al derecho'),
          TiempoPaso(lider: 'Pie derecho junta', follower: 'Pie izquierdo junta'),
          TiempoPaso(lider: 'Tap izquierdo', follower: 'Tap derecho'),
        ],
        categoria: 'Giros',
      ),
    ];

    for (final paso in pasosEjemplo) {
      await db.insert('pasos', paso.toMap());
    }
  }

  // ==================== CRUD PASOS ====================

  Future<int> insertPaso(Paso paso) async {
    final db = await database;
    return await db.insert('pasos', paso.toMap());
  }

  Future<List<Paso>> getAllPasos() async {
    final db = await database;
    final result = await db.query('pasos', orderBy: 'nombre ASC');
    return result.map((map) => Paso.fromMap(map)).toList();
  }

  Future<Paso?> getPaso(int id) async {
    final db = await database;
    final result = await db.query(
      'pasos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Paso.fromMap(result.first);
  }

  Future<int> updatePaso(Paso paso) async {
    final db = await database;
    return await db.update(
      'pasos',
      paso.toMap(),
      where: 'id = ?',
      whereArgs: [paso.id],
    );
  }

  Future<int> deletePaso(int id) async {
    final db = await database;
    return await db.delete(
      'pasos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Paso>> getPasosByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    final result = await db.query(
      'pasos',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return result.map((map) => Paso.fromMap(map)).toList();
  }

  // ==================== CRUD COREOGRAFÍAS ====================

  Future<int> insertCoreografia(Coreografia coreo) async {
    final db = await database;
    return await db.insert('coreografias', coreo.toMap());
  }

  Future<List<Coreografia>> getAllCoreografias() async {
    final db = await database;
    final result = await db.query('coreografias', orderBy: 'nombre ASC');
    return result.map((map) => Coreografia.fromMap(map)).toList();
  }

  Future<Coreografia?> getCoreografia(int id) async {
    final db = await database;
    final result = await db.query(
      'coreografias',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Coreografia.fromMap(result.first);
  }

  Future<Coreografia?> getCoreografiaConPasos(int id) async {
    final coreo = await getCoreografia(id);
    if (coreo == null) return null;

    final pasoIds = coreo.pasosIds.map((p) => p.pasoId).toList();
    final pasos = await getPasosByIds(pasoIds);

    // Ordenar pasos según el orden en la coreografía
    coreo.pasosCompletos = [];
    for (final pasoCoreografia in coreo.pasosIds) {
      final paso = pasos.firstWhere(
        (p) => p.id == pasoCoreografia.pasoId,
        orElse: () => Paso(nombre: 'Paso eliminado'),
      );
      coreo.pasosCompletos.add(paso);
    }

    return coreo;
  }

  Future<int> updateCoreografia(Coreografia coreo) async {
    final db = await database;
    return await db.update(
      'coreografias',
      coreo.toMap(),
      where: 'id = ?',
      whereArgs: [coreo.id],
    );
  }

  Future<int> deleteCoreografia(int id) async {
    final db = await database;
    return await db.delete(
      'coreografias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}