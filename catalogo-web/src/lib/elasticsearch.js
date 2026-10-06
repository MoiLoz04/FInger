const ES_URL = import.meta.env.VITE_ELASTICSEARCH_URL || "http://localhost:9200";

export async function searchProducts(query) {
  if (!query || !query.trim()) return null;

  const body = {
    query: {
      bool: {
        should: [
          {
            match: {
              nombre: {
                query,
                boost: 3,
                fuzziness: "AUTO",
                prefix_length: 1,
              },
            },
          },
          {
            match: {
              descripcion: {
                query,
                boost: 1,
                fuzziness: "AUTO",
              },
            },
          },
          {
            match: {
              categoria: {
                query,
                boost: 2,
                fuzziness: "AUTO",
              },
            },
          },
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

    if (!res.ok) throw new Error(`ES respondió ${res.status}`);

    const data = await res.json();
    return data.hits.hits.map((hit) => ({ id: hit._id, ...hit._source }));
  } catch (err) {
    console.warn("⚠️ Elasticsearch no disponible, usando búsqueda local:", err.message);
    return [];
  }
}