import 'package:flutter/foundation.dart';
import '../models/paso.dart';
import '../models/coreografia.dart';
import '../database/database_helper.dart';

class BachataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Paso> _pasos = [];
  List<Coreografia> _coreografias = [];
  bool _isLoading = false;

  List<Paso> get pasos => _pasos;
  List<Coreografia> get coreografias => _coreografias;
  bool get isLoading => _isLoading;

  Future<void> loadPasos() async {
    _isLoading = true;
    notifyListeners();

    _pasos = await _db.getAllPasos();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCoreografias() async {
    _isLoading = true;
    notifyListeners();

    _coreografias = await _db.getAllCoreografias();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await loadPasos();
    await loadCoreografias();
  }

  // ==================== PASOS ====================

  Future<int> agregarPaso(Paso paso) async {
    final id = await _db.insertPaso(paso);
    await loadPasos();
    return id;
  }

  Future<void> actualizarPaso(Paso paso) async {
    await _db.updatePaso(paso);
    await loadPasos();
  }

  Future<void> eliminarPaso(int id) async {
    await _db.deletePaso(id);
    await loadPasos();
  }

  Paso? getPasoById(int id) {
    try {
      return _pasos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==================== COREOGRAFÍAS ====================

  Future<int> agregarCoreografia(Coreografia coreo) async {
    final id = await _db.insertCoreografia(coreo);
    await loadCoreografias();
    return id;
  }

  Future<void> actualizarCoreografia(Coreografia coreo) async {
    await _db.updateCoreografia(coreo);
    await loadCoreografias();
  }

  Future<void> eliminarCoreografia(int id) async {
    await _db.deleteCoreografia(id);
    await loadCoreografias();
  }

  Future<Coreografia?> getCoreografiaConPasos(int id) async {
    return await _db.getCoreografiaConPasos(id);
  }
}