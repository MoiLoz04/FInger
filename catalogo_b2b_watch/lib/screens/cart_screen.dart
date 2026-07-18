import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../widgets/wearable_widget.dart';
import 'confirm_screen.dart';

/// Pantalla 2 del flujo del reloj: lista scrolleable de los items de
/// la cotización en curso, sincronizados en tiempo real desde
/// Supabase (sin polling, vía Realtime). Al final hay un botón para
/// avanzar a la pantalla de confirmación y envío.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _quote;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quote = await SupabaseService.instance.fetchDraftQuote();
    if (quote == null) {
      setState(() {
        _quote = null;
        _items = [];
        _loading = false;
      });
      return;
    }

    final items = await SupabaseService.instance.fetchQuoteItems(quote['id']);

    setState(() {
      _quote = quote;
      _items = items;
      _loading = false;
    });

    SupabaseService.instance.subscribeToQuoteItems(
      quoteId: quote['id'],
      onChange: _load,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Column(
            children: [
              Text(
                'TU COTIZACIÓN',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF5B6470),
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF22C55E),
                          strokeWidth: 2,
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              'Sin productos\nagregados aún',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF5B6470),
                                fontSize: 12,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return WearableCard(
                                nombre: item['nombre_producto'],
                                cantidad: item['cantidad'],
                              );
                            },
                          ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_quote == null || _items.isEmpty)
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConfirmScreen(quote: _quote!),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    disabledBackgroundColor: const Color(0xFF1C2128),
                    foregroundColor: const Color(0xFF14171C),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Enviar',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
