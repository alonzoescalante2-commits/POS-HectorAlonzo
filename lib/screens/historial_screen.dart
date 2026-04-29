import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inovafin/services/db_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final DbService _dbService = DbService();

  final Map<String, Color> _categoriaColores = {
    'Alimentación': const Color(0xFF29B6F6),
    'Transporte': const Color(0xFF0D47A1),
    'Material escolar': const Color(0xFF80CBC4),
    'Entretenimiento': const Color(0xFFFFB74D),
    'Salud': const Color(0xFFEF5350),
    'Ropa': const Color(0xFFAB47BC),
    'Tecnología': const Color(0xFF26A69A),
    'Otros': const Color(0xFF78909C),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, double> _calcularPorCategoria(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> totales = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final categoria = data['categoria'] ?? 'Otros';
      final monto = (data['monto'] ?? 0).toDouble();
      totales[categoria] = (totales[categoria] ?? 0) + monto;
    }
    return totales;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF29B6F6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance,
                  color: Color(0xFF29B6F6), size: 20),
            ),
            const SizedBox(width: 8),
            const Text('INOVAFIN',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.obtenerMovimientos(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF29B6F6)));
          }

          final docs = snapshot.data?.docs ?? [];
          final totalesPorCategoria = _calcularPorCategoria(docs);
          final totalGastos = totalesPorCategoria.values
              .fold(0.0, (sum, val) => sum + val);

          // Filtrar por búsqueda
          final docsFiltrados = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final concepto = (data['concepto'] ?? '').toLowerCase();
            return concepto.contains(_searchQuery.toLowerCase());
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                const Text('Mis Gastos',
                    style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Text('Historial y análisis de consumo',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),

                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar gasto...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF29B6F6)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.black38),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Gráfica de pastel
                if (totalesPorCategoria.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gastos por categoría',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                                fontSize: 16)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: totalesPorCategoria.entries.map((e) {
                                final porcentaje = totalGastos > 0
                                    ? (e.value / totalGastos * 100)
                                    : 0.0;
                                return PieChartSectionData(
                                  value: e.value,
                                  title: '${porcentaje.toStringAsFixed(1)}%',
                                  color: _categoriaColores[e.key] ??
                                      const Color(0xFF78909C),
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Leyenda
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: totalesPorCategoria.entries.map((e) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _categoriaColores[e.key] ??
                                        const Color(0xFF78909C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.key}: \$${e.value.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Lista de movimientos
                const Text('Movimientos',
                    style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (docsFiltrados.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Icon(Icons.receipt_long,
                            size: 60, color: Colors.black12),
                        const SizedBox(height: 12),
                        const Text('No hay movimientos registrados',
                            style: TextStyle(color: Colors.black38)),
                      ],
                    ),
                  )
                else
                  ...docsFiltrados.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final concepto = data['concepto'] ?? 'Sin concepto';
                    final monto = (data['monto'] ?? 0).toDouble();
                    final categoria = data['categoria'] ?? 'Otros';
                    final fecha = data['fecha'] != null
                        ? (data['fecha'] as Timestamp).toDate()
                        : DateTime.now();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_categoriaColores[categoria] ??
                                      const Color(0xFF78909C))
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getIconoCategoria(categoria),
                              color: _categoriaColores[categoria] ??
                                  const Color(0xFF78909C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(concepto,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(categoria,
                                    style: const TextStyle(
                                        color: Colors.black38,
                                        fontSize: 12)),
                                Text(
                                  '${fecha.day}/${fecha.month}/${fecha.year}',
                                  style: const TextStyle(
                                      color: Colors.black38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-\$${monto.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconoCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentación':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Material escolar':
        return Icons.book;
      case 'Entretenimiento':
        return Icons.movie;
      case 'Salud':
        return Icons.local_hospital;
      case 'Ropa':
        return Icons.checkroom;
      case 'Tecnología':
        return Icons.devices;
      default:
        return Icons.attach_money;
    }
  }
}
