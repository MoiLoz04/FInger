import {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
} from "react";
import { supabase } from "../lib/supabaseClient";
import { useAuth } from "./AuthContext";

const CartContext = createContext(null);

/**
 * El "carrito" no vive en memoria del navegador: vive como una fila en
 * `quotes` con status = 'borrador' y sus `quote_items` asociados.
 * Esto es intencional: es lo que permite que el smartwatch (Fase 4),
 * suscrito por Realtime a la misma quote, vea los cambios sin polling,
 * y que un producto agregado desde la web aparezca de inmediato en el reloj.
 */
export function CartProvider({ children }) {
  const { user } = useAuth();
  const [draftQuote, setDraftQuote] = useState(null);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  const loadOrCreateDraft = useCallback(async () => {
    if (!user) {
      setDraftQuote(null);
      setItems([]);
      setLoading(false);
      return;
    }
    setLoading(true);

    let { data: existing } = await supabase
      .from("quotes")
      .select("*")
      .eq("user_id", user.id)
      .eq("status", "borrador")
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (!existing) {
      const { data: created, error } = await supabase
        .from("quotes")
        .insert({ user_id: user.id, status: "borrador", enviado_desde: "web" })
        .select()
        .single();
      if (error) {
        console.error("Error creando borrador de cotización:", error);
        setLoading(false);
        return;
      }
      existing = created;
    }

    setDraftQuote(existing);

    const { data: quoteItems } = await supabase
      .from("quote_items")
      .select("*")
      .eq("quote_id", existing.id)
      .order("created_at", { ascending: true });

    setItems(quoteItems || []);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    loadOrCreateDraft();
  }, [loadOrCreateDraft]);

  // Suscripción Realtime: si el item cambia desde otro origen (ej. el
  // smartwatch ajusta cantidades), la web se actualiza sin recargar.
  useEffect(() => {
    if (!draftQuote) return;

    const channel = supabase
      .channel(`quote_items_${draftQuote.id}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "quote_items",
          filter: `quote_id=eq.${draftQuote.id}`,
        },
        () => {
          supabase
            .from("quote_items")
            .select("*")
            .eq("quote_id", draftQuote.id)
            .order("created_at", { ascending: true })
            .then(({ data }) => setItems(data || []));
        }
      )
      .subscribe();

    return () => supabase.removeChannel(channel);
  }, [draftQuote]);

  async function addToCart(product) {
    if (!draftQuote) return;
    const existing = items.find((i) => i.product_id === product.id);

    if (existing) {
      await supabase
        .from("quote_items")
        .update({ cantidad: existing.cantidad + 1 })
        .eq("id", existing.id);
    } else {
      await supabase.from("quote_items").insert({
        quote_id: draftQuote.id,
        product_id: product.id,
        nombre_producto: product.nombre,
        cantidad: 1,
      });
    }
  }

  async function updateQuantity(itemId, cantidad) {
    if (cantidad <= 0) return removeItem(itemId);
    await supabase.from("quote_items").update({ cantidad }).eq("id", itemId);
  }

  async function removeItem(itemId) {
    await supabase.from("quote_items").delete().eq("id", itemId);
  }

  async function submitQuote({ instrucciones_default }) {
    if (!draftQuote) return null;

    if (instrucciones_default !== undefined && user) {
      await supabase
        .from("profiles")
        .update({ instrucciones_default })
        .eq("id", user.id);
    }

    const { data, error } = await supabase
      .from("quotes")
      .update({ status: "enviada" })
      .eq("id", draftQuote.id)
      .select()
      .single();

    if (error) throw error;

    // Después de enviar, arrancamos un borrador nuevo y vacío
    await loadOrCreateDraft();
    return data;
  }

  const totalItems = items.reduce((acc, i) => acc + i.cantidad, 0);

  return (
    <CartContext.Provider
      value={{
        draftQuote,
        items,
        loading,
        totalItems,
        addToCart,
        updateQuantity,
        removeItem,
        submitQuote,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  return useContext(CartContext);
}
