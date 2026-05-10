import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inovafin/services/db_service.dart';
import 'package:inovafin/screens/gastos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _mostrarAgregarSaldo(BuildContext context, String uid, double saldoActual) {
    final controller = TextEditingController();
    final dbService = DbService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        title: const Text(
          'Agregar saldo',
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Monto a agregar (\$)',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF29B6F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(controller.text);
              if (monto != null && monto > 0) {
                await dbService.actualizarSaldo(uid, saldoActual + monto);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF29B6F6)),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarCrearMeta(BuildContext context, String uid) {
    final descripcionController = TextEditingController();
    final montoController = TextEditingController();
    DateTime? fechaSeleccionada;
    final dbService = DbService();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFFF5F0E8),
          title: const Text(
            'Nueva meta de ahorro',
            style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(
                  hintText: 'Ej: Audífonos, Laptop...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.flag, color: Color(0xFF29B6F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Monto objetivo (\$)',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF29B6F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (fecha != null) setState(() => fechaSeleccionada = fecha);
                },
                icon: const Icon(Icons.calendar_today, color: Color(0xFF29B6F6)),
                label: Text(
                  fechaSeleccionada == null
                      ? 'Seleccionar fecha límite'
                      : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                  style: const TextStyle(color: Color(0xFF0D47A1)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF80CBC4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                final monto = double.tryParse(montoController.text);
                if (descripcionController.text.isEmpty || monto == null || monto <= 0 || fechaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos.'), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                await dbService.crearMeta(
                  uid: uid,
                  descripcion: descripcionController.text.trim(),
                  montoObjetivo: monto,
                  fechaLimite: fechaSeleccionada!,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF29B6F6)),
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAbonarMeta(BuildContext context, String uid, String metaId, double montoActual, double montoObjetivo, String descripcion) {
    final controller = TextEditingController();
    final dbService = DbService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F0E8),
        title: Text(
          'Abonar a: $descripcion',
          style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Monto a abonar (\$)',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.savings, color: Color(0xFF29B6F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(controller.text);
              if (monto != null && monto > 0) {
                await dbService.abonarMeta(
                  uid: uid,
                  metaId: metaId,
                  montoAbono: monto,
                  montoActual: montoActual,
                  descripcionMeta: descripcion,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF29B6F6)),
            child: const Text('Abonar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DbService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF29B6F6),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance, color: Color(0xFF29B6F6), size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'INOVAFIN',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: dbService.obtenerEstudiante(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF29B6F6)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = data['nombre'] ?? 'Estudiante';
          final saldo = (data['saldo_total'] ?? 0).toDouble();

          return StreamBuilder<QuerySnapshot>(
            stream: dbService.obtenerGastosMes(user.uid),
            builder: (context, snapshotGastos) {
              final gastosMes = snapshotGastos.hasData ? snapshotGastos.data!.docs.length : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, $nombre 👋',
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Estado de tus operaciones', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 16),

                    // Badge ACTIVA
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80CBC4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('ACTIVA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Gastos del mes
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFF29B6F6), size: 32),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gastos del mes', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('ACTIVOS', style: TextStyle(color: Colors.black38, fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Text('$gastosMes', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Saldo disponible
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Color(0xFF29B6F6), size: 32),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Saldo disponible', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('ACTIVO', style: TextStyle(color: Colors.black38, fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '\$${saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: saldo < 0 ? Colors.redAccent : const Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── SECCIÓN METAS DE AHORRO ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🎯 Metas de Ahorro',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _mostrarCrearMeta(context, user.uid),
                          icon: const Icon(Icons.add, color: Color(0xFF29B6F6), size: 18),
                          label: const Text('Nueva', style: TextStyle(color: Color(0xFF29B6F6))),
                        ),
                      ],
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: dbService.obtenerMetas(user.uid),
                      builder: (context, snapshotMetas) {
                        if (snapshotMetas.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF29B6F6)));
                        }
                        if (!snapshotMetas.hasData || snapshotMetas.data!.docs.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF80CBC4), width: 1),
                            ),
                            child: const Text(
                              'Aún no tienes metas. ¡Crea una!',
                              style: TextStyle(color: Colors.black38),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return Column(
                          children: snapshotMetas.data!.docs.map((doc) {
                            final meta = doc.data() as Map<String, dynamic>;
                            final descripcion = meta['descripcion'] ?? '';
                            final montoObjetivo = (meta['monto_objetivo'] ?? 0).toDouble();
                            final montoActual = (meta['monto_actual'] ?? 0).toDouble();
                            final fechaLimite = (meta['fecha_limite'] as Timestamp).toDate();
                            final progreso = montoObjetivo > 0 ? (montoActual / montoObjetivo).clamp(0.0, 1.0) : 0.0;
                            final completada = montoActual >= montoObjetivo;

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                                border: completada ? Border.all(color: const Color(0xFF80CBC4), width: 2) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        completada ? Icons.check_circle : Icons.flag,
                                        color: completada ? const Color(0xFF80CBC4) : const Color(0xFF29B6F6),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          descripcion,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      // Botón eliminar
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.black26, size: 20),
                                        onPressed: () async {
                                          await dbService.eliminarMeta(doc.id);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Barra de progreso
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progreso,
                                      backgroundColor: const Color(0xFFE0E0E0),
                                      color: completada ? const Color(0xFF80CBC4) : const Color(0xFF29B6F6),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${montoActual.toStringAsFixed(2)} / \$${montoObjetivo.toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                                      ),
                                      Text(
                                        completada
                                            ? '¡Meta cumplida! 🎉'
                                            : 'Vence ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                        style: TextStyle(
                                          color: completada ? const Color(0xFF80CBC4) : Colors.black38,
                                          fontSize: 12,
                                          fontWeight: completada ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!completada) ...[
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _mostrarAbonarMeta(
                                          context, user.uid, doc.id,
                                          montoActual, montoObjetivo, descripcion,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF29B6F6)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        child: const Text('Abonar', style: TextStyle(color: Color(0xFF29B6F6))),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Sincronización
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.sync, color: Colors.black38, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Última sincronización: ${TimeOfDay.now().format(context)}',
                          style: const TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Botones inferiores
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _mostrarAgregarSaldo(context, user.uid, saldo),
                            icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                            label: const Text('Agregar saldo', style: TextStyle(color: Color(0xFF0D47A1))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF80CBC4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const GastosScreen(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF80CBC4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Registrar gastos', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
