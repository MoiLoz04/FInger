import { useEffect, useState, useCallback } from "react";
import { supabase } from "../lib/supabaseClient";
import { searchProducts } from "../lib/elasticsearch";
import ProductCard from "../components/ProductCard";
import QuotationSidebar from "../components/QuotationSidebar";

export default function Catalog({ searchQuery }) {
  const [allProducts, setAllProducts] = useState([]);
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [usedFallback, setUsedFallback] = useState(false);

  const loadCatalog = useCallback(async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from("products")
      .select("*")
      .eq("activo", true)
      .order("created_at", { ascending: false });

    if (!error) {
      setAllProducts(data || []);
      setResults(data || []);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    loadCatalog();
  }, [loadCatalog]);

  useEffect(() => {
    let active = true;

    async function runSearch() {
      if (!searchQuery || !searchQuery.trim()) {
        setResults(allProducts);
        setUsedFallback(false);
        return;
      }
      setSearching(true);
      const esResults = await searchProducts(searchQuery);
      if (!active) return;

      if (esResults && esResults.length > 0) {
        setResults(esResults);
        setUsedFallback(false);
      } else {
        // Fallback: si Elasticsearch no responde o no hay resultados,
        // filtramos localmente sobre el catálogo ya cargado de Supabase.
        const lower = searchQuery.toLowerCase();
        setResults(
          allProducts.filter(
            (p) =>
              p.nombre.toLowerCase().includes(lower) ||
              p.categoria.toLowerCase().includes(lower) ||
              (p.descripcion || "").toLowerCase().includes(lower)
          )
        );
        setUsedFallback(true);
      }
      setSearching(false);
    }

    const debounce = setTimeout(runSearch, 300);
    return () => {
      active = false;
      clearTimeout(debounce);
    };
  }, [searchQuery, allProducts]);

  return (
    <div className="max-w-7xl mx-auto px-4 lg:px-6 py-8 flex gap-8">
      <div className="flex-1">
        <div className="mb-6">
          <h1 className="font-display text-2xl font-semibold text-graphite">
            Catálogo Industrial
          </h1>
          <p className="text-steel text-sm mt-1">
            {searching
              ? "Buscando..."
              : `${results.length} producto${results.length !== 1 ? "s" : ""} disponibles`}
            {usedFallback && (
              <span className="ml-2 text-amber-500 text-xs font-mono">
                (búsqueda local — Elasticsearch no respondió)
              </span>
            )}
          </p>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="aspect-[3/4] bg-white border border-black/5 rounded-lg animate-pulse"
              />
            ))}
          </div>
        ) : results.length === 0 ? (
          <p className="text-steel text-sm py-12 text-center">
            No encontramos productos para "{searchQuery}".
          </p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {results.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        )}
      </div>

      <QuotationSidebar />
    </div>
  );
}
