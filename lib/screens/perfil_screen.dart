import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inovafin/services/auth_service.dart';
import 'package:inovafin/services/db_service.dart';
import 'package:inovafin/screens/login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DbService();
    final authService = AuthService();

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: dbService.obtenerEstudiante(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF29B6F6)));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final nombre = data?['nombre'] ?? 'Estudiante';
          final correo = data?['correo'] ?? user.email ?? '';
          final saldo = (data?['saldo_total'] ?? 0).toDouble();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header con avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF29B6F6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person,
                            size: 50, color: Color(0xFF29B6F6)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        correo,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tarjeta de saldo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF29B6F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              color: Color(0xFF29B6F6), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saldo disponible',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 13)),
                            Text(
                              '\$${saldo.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: saldo < 0
                                    ? Colors.redAccent
                                    : const Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Opciones del perfil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
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
                      children: [
                        _opcionPerfil(
                          icono: Icons.person_outline,
                          titulo: 'Mi información',
                          subtitulo: nombre,
                          color: const Color(0xFF29B6F6),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        _opcionPerfil(
                          icono: Icons.email_outlined,
                          titulo: 'Correo electrónico',
                          subtitulo: correo,
                          color: const Color(0xFF80CBC4),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        _opcionPerfil(
                          icono: Icons.lock_outline,
                          titulo: 'Cambiar contraseña',
                          subtitulo: 'Enviar correo de recuperación',
                          color: const Color(0xFFFFB74D),
                          onTap: () async {
                            final authService = AuthService();
                            await authService.resetPassword(correo);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Correo de recuperación enviado.'),
                                backgroundColor: Color(0xFF80CBC4),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),
                        _opcionPerfil(
                          icono: Icons.info_outline,
                          titulo: 'Versión de la app',
                          subtitulo: 'INOVAFIN v1.0.0',
                          color: const Color(0xFF78909C),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botón cerrar sesión
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authService.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Cerrar sesión',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _opcionPerfil({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: color, size: 22),
      ),
      title: Text(titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitulo,
          style: const TextStyle(color: Colors.black45, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
    );
  }
}
