import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../widgets/stats_widget.dart';
import 'cart_screen.dart';

const _diasSemana = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Pantalla 1 del flujo del reloj: hora en vivo, fecha en español, y
/// el total de items que hay actualmente en la cotización en curso
/// (leído y mantenido en tiempo real desde Supabase).
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

    // Realtime: si se agrega algo desde la web, este número se
    // actualiza solo, sin que el usuario tenga que recargar.
    SupabaseService.instance.subscribeToQuoteItems(
      quoteId: quote['id'],
      onChange: _loadCart,
    );
  }

  String get _fechaFormateada {
    final dia = _diasSemana[_now.weekday - 1];
    final mes = _meses[_now.month - 1];
    return '$dia ${_now.day} de $mes';
  }

  String get _horaFormateada {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _fechaFormateada,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF5B6470),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _horaFormateada,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFF7F7F4),
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2128),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF22C55E),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _loading ? '...' : '$_totalItems en cotización',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF22C55E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StatsWidget(
                  totalTareas: _totalItems,
                  enProgreso: _draftQuote != null ? _totalItems : 0,
                  completadas: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
