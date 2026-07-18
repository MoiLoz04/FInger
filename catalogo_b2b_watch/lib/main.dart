import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/supabase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const CatalogoWatchApp());
}

/// App raíz del cotizador industrial B2B para smartwatch.
///
/// Pensada para un emulador de Android Studio que simula un Galaxy
/// Watch 8 de 44mm: pantalla circular AMOLED, fondo negro puro
/// (`#000000`, no gris oscuro, para aprovechar el ahorro de batería
/// real en pantallas AMOLED), acento verde corporativo `#22c55e`.
class CatalogoWatchApp extends StatelessWidget {
  const CatalogoWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo B2B Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
          brightness: Brightness.dark,
          surface: const Color(0xFF000000),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: SupabaseService.instance.isLoggedIn
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
