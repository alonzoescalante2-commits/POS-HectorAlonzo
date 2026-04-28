import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inovafin/services/db_service.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();
  bool _isLoading = false;
  String _categoriaSeleccionada = 'Alimentación';
  final DbService _dbService = DbService();

  final List<String> _categorias = [
    'Alimentación',
    'Transporte',
    'Material escolar',
    'Entretenimiento',
    'Salud',
    'Ropa',
    'Tecnología',
    'Otros',
  ];

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  void _guardarGasto() async {
    if (_montoController.text.isEmpty || _conceptoController.text.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return;
    }

    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      _showError('Ingresa un monto válido mayor a 0.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Registrar el gasto en Firestore
      await _dbService.registrarGasto(
        uid: user.uid,
        monto: monto,
        concepto: _conceptoController.text.trim(),
        categoria: _categoriaSeleccionada,
      );

      // Obtener saldo actual y actualizar
      final doc = await _dbService.obtenerEstudiante(user.uid).first;
      final data = doc.data() as Map<String, dynamic>;
      final saldoActual = (data['saldo_total'] ?? 0).toDouble();
      final nuevoSaldo = saldoActual - monto;

      await _dbService.actualizarSaldo(user.uid, nuevoSaldo);

      setState(() => _isLoading = false);

      // Verificar saldo bajo
      if (nuevoSaldo < 50) {
        _showWarning('⚠️ Saldo bajo: \$${nuevoSaldo.toStringAsFixed(2)}');
      } else {
        _showSuccess('Gasto registrado correctamente.');
      }

      // Limpiar campos
      _montoController.clear();
      _conceptoController.clear();
      setState(() => _categoriaSeleccionada = 'Alimentación');

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al registrar el gasto. Intenta de nuevo.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF80CBC4),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Título
          const Text(
            'Registrar Gasto',
            style: TextStyle(
              color: Color(0xFF0D47A1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Campo Monto
          TextField(
            controller: _montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Monto (\$)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.attach_money,
                  color: Color(0xFF29B6F6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo Concepto
          TextField(
            controller: _conceptoController,
            decoration: InputDecoration(
              hintText: 'Concepto (ej. Lunch, Camión...)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.description,
                  color: Color(0xFF29B6F6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown Categoría
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _categoriaSeleccionada,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF29B6F6)),
                items: _categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _categoriaSeleccionada = value!);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botón Guardar
          SizedBox(
            width: double.infinity,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF29B6F6)))
                : ElevatedButton(
                    onPressed: _guardarGasto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
