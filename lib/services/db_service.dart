import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear perfil del estudiante al registrarse
  Future<void> crearEstudiante({
  required String uid,
  required String nombre,
  required String correo,
  double saldoInicial = 0.0,
}) async {
  await _db.collection('users').doc(uid).set({
    'nombre': nombre,
    'correo': correo,
    'saldo_total': saldoInicial,
    'fecha_creacion': FieldValue.serverTimestamp(),
  });
}

  // Obtener datos del estudiante
  Stream<DocumentSnapshot> obtenerEstudiante(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> registrarGastoYActualizarSaldo({
  required String uid,
  required double monto,
  required String concepto,
  required String categoria,
}) async {
  await _db.runTransaction((transaction) async {
    // 1. Leer saldo actual
    final userRef = _db.collection('users').doc(uid);
    final userDoc = await transaction.get(userRef);
    final saldoActual = (userDoc.data()!['saldo_total'] ?? 0).toDouble();

    // 2. Registrar el movimiento
    final gastoRef = _db.collection('movimientos').doc();
    transaction.set(gastoRef, {
      'id_estudiante': uid,
      'monto': monto,
      'concepto': concepto,
      'categoria': categoria,
      'fecha': FieldValue.serverTimestamp(),
    });

    // 3. Actualizar saldo atomicamente
    transaction.update(userRef, {
      'saldo_total': saldoActual - monto,
    });
  });
}

  // Obtener movimientos del estudiante
  Stream<QuerySnapshot> obtenerMovimientos(String uid) {
  return _db
      .collection('movimientos')
      .where('id_estudiante', isEqualTo: uid)
      .snapshots();
}

  // Obtener gastos del mes actual
  Stream<QuerySnapshot> obtenerGastosMes(String uid) {
  final ahora = DateTime.now();
  final inicioMes = DateTime(ahora.year, ahora.month, 1);

  return _db
      .collection('movimientos')
      .where('id_estudiante', isEqualTo: uid)
      .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioMes))
      .snapshots();
}
// Actualizar saldo
Future<void> actualizarSaldo(String uid, double nuevoSaldo) async {
  await _db.collection('users').doc(uid).update({
    'saldo_total': nuevoSaldo,
  });
}
}
