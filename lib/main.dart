import 'package:flutter/material.dart';
import 'package:inovafin/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

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
      home: LoginScreen(),
    );
  }
}
