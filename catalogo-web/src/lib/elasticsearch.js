/**
 * Búsqueda de productos contra el índice "products" de Elasticsearch.
 *
 * NOTA IMPORTANTE: en este entorno de desarrollo local, el navegador llama
 * directo a Elasticsearch (http://localhost:9200). Para que esto funcione
 * sin errores de CORS, el contenedor de Elasticsearch debe levantarse con
 * CORS habilitado. Ver instrucciones al final del mensaje de esta fase.
 *
 * En producción NUNCA expongas Elasticsearch directo al navegador: esto
 * debe pasar por un backend/proxy que oculte la URL y agregue auth.
 * Para esta fase (entorno local de desarrollo) lo dejamos directo por
 * simplicidad, tal como pide el brief original.
 */

const ES_URL = import.meta.env.VITE_ELASTICSEARCH_URL || "http://localhost:9200";

export async function searchProducts(query) {
  // Sin texto de búsqueda -> no pegamos a ES, el caller debe traer
  // el catálogo completo desde Supabase en ese caso.
  if (!query || !query.trim()) return null;

  const body = {
    query: {
      bool: {
        should: [
          { match: { nombre: { query, boost: 3 } } },
          { match: { descripcion: { query, boost: 1 } } },
          { match: { categoria: { query, boost: 2 } } },
        ],
        minimum_should_match: 1,
      },
    },
    size: 30,
  };

  try {
    const res = await fetch(`${ES_URL}/products/_search`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      throw new Error(`Elasticsearch respondió ${res.status}`);
    }

    const data = await res.json();
    return data.hits.hits.map((hit) => ({ id: hit._id, ...hit._source }));
  } catch (err) {
    console.error("Error buscando en Elasticsearch:", err);
    // Falla silenciosa: el componente que llama decide el fallback
    // (normalmente, mostrar el catálogo completo de Supabase).
    return [];
  }
}
