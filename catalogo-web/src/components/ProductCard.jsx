import { Plus } from "lucide-react";
import { useCart } from "../context/CartContext";

export default function ProductCard({ product }) {
  const { addToCart } = useCart();
  const specs = product.especificaciones_json || {};
  const specEntries = Object.entries(specs).slice(0, 3);

  return (
    <div className="bg-white rounded-lg border border-black/5 overflow-hidden flex flex-col group hover:shadow-lg hover:-translate-y-0.5 transition-all">
      <div className="aspect-[4/3] bg-graphite2 overflow-hidden">
        {product.imagen_url ? (
          <img
            src={product.imagen_url}
            alt={product.nombre}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-steel text-xs font-mono">
            SIN IMAGEN
          </div>
        )}
      </div>

      <div className="p-4 flex flex-col gap-3 flex-1">
        <div>
          <span className="text-[10px] font-mono uppercase tracking-wider text-brand-600">
            {product.categoria}
          </span>
          <h3 className="font-display font-semibold text-graphite leading-snug mt-1">
            {product.nombre}
          </h3>
        </div>

        <p className="text-sm text-steel line-clamp-2">{product.descripcion}</p>

        {specEntries.length > 0 && (
          <div className="bg-bone rounded-md p-2.5 font-mono text-[11px] text-graphite/80 space-y-1">
            {specEntries.map(([key, value]) => (
              <div key={key} className="flex justify-between gap-2">
                <span className="text-steel uppercase">{key.replace(/_/g, " ")}</span>
                <span className="text-right">{String(value)}</span>
              </div>
            ))}
          </div>
        )}

        <div className="mt-auto flex items-center justify-between pt-2">
          <span className="font-mono font-semibold text-lg text-graphite">
            ${Number(product.precio || 0).toLocaleString("es-MX")}
          </span>
          <button
            onClick={() => addToCart(product)}
            className="flex items-center gap-1.5 bg-brand-500 text-graphite font-medium text-sm px-3 py-2 rounded-md hover:bg-brand-600 hover:text-white transition-colors"
          >
            <Plus size={16} />
            Add to Quote
          </button>
        </div>
      </div>
    </div>
  );
}
