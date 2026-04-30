import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inovafin/screens/home_screen.dart';
import 'package:inovafin/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCfbGk8iW8b6aDdKh9Zjcp5lkIKoQpqpkU",
      authDomain: "inovafin-68212.firebaseapp.com",
      projectId: "inovafin-68212",
      storageBucket: "inovafin-68212.firebasestorage.app",
      messagingSenderId: "787078460532",
      appId: "1:787078460532:web:2622027c55385b9e688d21",
    ),
  );
  runApp(const InovafinApp());
}

class InovafinApp extends StatelessWidget {
  const InovafinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INOVAFIN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF29B6F6),
          primary: const Color(0xFF29B6F6),
          secondary: const Color(0xFF80CBC4),
          surface: const Color(0xFFF5F0E8),
        ),
        scaffoldBackgroundColor: const Color(0xFF29B6F6),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F0E8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5F0E8),
            foregroundColor: const Color(0xFF0D47A1),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF29B6F6),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance,
                      color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'INOVAFIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 32),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          );
        }

        // Si hay sesión activa → Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Si no hay sesión → Login
        return const LoginScreen();
      },
    );
  }
}
