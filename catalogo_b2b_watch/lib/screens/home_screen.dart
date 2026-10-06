import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart'; // Importa tu servicio de autenticación
import '../widgets/stats_widget.dart';
import 'cart_screen.dart';
import 'pin_login_screen.dart'; // Importa tu pantalla de login

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  Map<String, dynamic>? _draftQuote;
  int _totalItems = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _loadCart();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCart() async {
    final quote = await SupabaseService.instance.fetchDraftQuote();
    if (quote == null) {
      setState(() {
        _draftQuote = null;
        _totalItems = 0;
        _loading = false;
      });
      return;
    }

    final items = await SupabaseService.instance.fetchQuoteItems(quote['id']);
    final total = items.fold<int>(0, (sum, i) => sum + (i['cantidad'] as int));

    setState(() {
      _draftQuote = quote;
      _totalItems = total;
      _loading = false;
    });

    SupabaseService.instance.subscribeToQuoteItems(
      quoteId: quote['id'],
      onChange: _loadCart,
    );
  }

  // --- LÓGICA DE CIERRE DE SESIÓN ---
  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PinLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFF5B6470), size: 20),
            onPressed: _handleLogout, // Botón de Logout añadido
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (tu diseño existente de hora y stats)
                Text('$_totalItems en cotización', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF22C55E))),
                StatsWidget(totalTareas: _totalItems, enProgreso: _totalItems, completadas: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}