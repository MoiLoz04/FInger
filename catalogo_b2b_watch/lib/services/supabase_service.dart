import 'package:supabase_flutter/supabase_flutter.dart';

/// Reemplaza estos valores con los de tu proyecto Supabase
/// (Project Settings → API). Usa la ANON KEY, nunca la service_role
/// en una app cliente.
const String supabaseUrl = 'https://psgyneqlcxzecujbfrdh.supabase.co';
const String supabaseAnonKey = 'sb_publishable_ksDm1BMx4kkFbbx-0cAMEA_QKVaK97s';

/// Capa única de acceso a Supabase para la app de smartwatch.
///
/// Centraliza tres responsabilidades:
/// 1. Autenticación de la sesión activa en el reloj.
/// 2. Localizar la cotización en estado `borrador` del usuario
///    autenticado (la misma que arma la web).
/// 3. Escuchar cambios en tiempo real sobre `quote_items` de esa
///    cotización, para que el carrito del reloj se actualice solo
///    cuando se agrega un producto desde la web.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  /// Inicializa el SDK de Supabase. Debe llamarse una sola vez,
  /// antes de runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  bool get isLoggedIn => client.auth.currentSession != null;

  String? get currentUserId => client.auth.currentUser?.id;

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  /// Busca la cotización más reciente en estado 'borrador' del
  /// usuario autenticado. Esta es la misma fila que la web crea o
  /// reutiliza como carrito (ver CartContext.jsx, Fase 3).
  Future<Map<String, dynamic>?> fetchDraftQuote() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await client
        .from('quotes')
        .select()
        .eq('user_id', userId)
        .eq('status', 'borrador')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  /// Trae los items asociados a una cotización.
  Future<List<Map<String, dynamic>>> fetchQuoteItems(String quoteId) async {
    final response = await client
        .from('quote_items')
        .select()
        .eq('quote_id', quoteId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Se suscribe en tiempo real a cambios de `quote_items` para una
  /// cotización específica. Llama a [onChange] cada vez que algo
  /// cambia (insert/update/delete), sin necesidad de hacer polling.
  RealtimeChannel subscribeToQuoteItems({
    required String quoteId,
    required void Function() onChange,
  }) {
    final channel = client
        .channel('watch_quote_items_$quoteId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'quote_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'quote_id',
            value: quoteId,
          ),
          callback: (payload) => onChange(),
        )
        .subscribe();

    return channel;
  }

  /// Marca la cotización como enviada desde el reloj. No pide datos
  /// de contacto (esos ya quedaron pre-llenados desde el perfil web);
  /// solo actualiza status y origen, y Supabase regresa la fila con
  /// la referencia COT-XXXXX ya generada por el trigger.
  Future<Map<String, dynamic>> submitQuoteFromWatch(String quoteId) async {
    final response = await client
        .from('quotes')
        .update({'status': 'enviada', 'enviado_desde': 'watch'})
        .eq('id', quoteId)
        .select()
        .single();

    return response;
  }
}
