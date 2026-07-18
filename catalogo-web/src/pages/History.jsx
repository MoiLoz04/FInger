import { useEffect, useState } from "react";
import { supabase } from "../lib/supabaseClient";
import { useAuth } from "../context/AuthContext";

const statusStyles = {
  borrador: "bg-amber-500/10 text-amber-600",
  enviada: "bg-brand-50 text-brand-600",
};

const origenLabel = {
  web: "Web",
  watch: "Smartwatch",
};

export default function History() {
  const { user } = useAuth();
  const [quotes, setQuotes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    async function load() {
      setLoading(true);
      const { data } = await supabase
        .from("quotes")
        .select("*")
        .eq("user_id", user.id)
        .order("created_at", { ascending: false });
      setQuotes(data || []);
      setLoading(false);
    }
    load();

    // Realtime: si el watch envía una cotización, aparece aquí sin recargar
    const channel = supabase
      .channel(`quotes_history_${user.id}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "quotes",
          filter: `user_id=eq.${user.id}`,
        },
        () => load()
      )
      .subscribe();

    return () => supabase.removeChannel(channel);
  }, [user]);

  return (
    <div className="max-w-5xl mx-auto px-4 lg:px-6 py-8">
      <h1 className="font-display text-2xl font-semibold text-graphite mb-6">
        Historial de Cotizaciones
      </h1>

      <div className="bg-white border border-black/5 rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-bone text-left text-steel text-xs font-mono uppercase">
              <th className="px-5 py-3">Referencia</th>
              <th className="px-5 py-3">Fecha</th>
              <th className="px-5 py-3">Estado</th>
              <th className="px-5 py-3">Origen</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={4} className="px-5 py-8 text-center text-steel">
                  Cargando...
                </td>
              </tr>
            ) : quotes.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-5 py-8 text-center text-steel">
                  Aún no tienes cotizaciones.
                </td>
              </tr>
            ) : (
              quotes.map((q) => (
                <tr key={q.id} className="border-t border-black/5">
                  <td className="px-5 py-3 font-mono text-graphite">
                    {q.referencia}
                  </td>
                  <td className="px-5 py-3 text-steel">
                    {new Date(q.created_at).toLocaleDateString("es-MX", {
                      day: "2-digit",
                      month: "short",
                      year: "numeric",
                    })}
                  </td>
                  <td className="px-5 py-3">
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${statusStyles[q.status]}`}
                    >
                      {q.status}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-steel">
                    {origenLabel[q.enviado_desde]}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
