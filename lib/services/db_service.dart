import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear perfil del estudiante al registrarse
  Future<void> crearEstudiante({
    required String uid,
    required String nombre,
    required String correo,
  }) async {
    await _db.collection('users').doc(uid).set({
      'nombre': nombre,
      'correo': correo,
      'saldo_total': 0.0,
      'fecha_creacion': FieldValue.serverTimestamp(),
    });
  }

  // Obtener datos del estudiante
  Stream<DocumentSnapshot> obtenerEstudiante(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Actualizar saldo
  Future<void> actualizarSaldo(String uid, double nuevoSaldo) async {
    await _db.collection('users').doc(uid).update({
      'saldo_total': nuevoSaldo,
    });
  }

  // Registrar un gasto
  Future<void> registrarGasto({
    required String uid,
    required double monto,
    required String concepto,
    required String categoria,
  }) async {
    await _db.collection('movimientos').add({
      'id_estudiante': uid,
      'monto': monto,
      'concepto': concepto,
      'categoria': categoria,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Obtener movimientos del estudiante
  Stream<QuerySnapshot> obtenerMovimientos(String uid) {
    return _db
        .collection('movimientos')
        .where('id_estudiante', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Obtener gastos del mes actual
  Stream<QuerySnapshot> obtenerGastosMes(String uid) {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    return _db
        .collection('movimientos')
        .where('id_estudiante', isEqualTo: uid)
        .where('fecha', isGreaterThanOrEqualTo: inicioMes)
        .snapshots();
  }
}
