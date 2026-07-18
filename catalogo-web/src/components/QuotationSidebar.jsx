import { Link } from "react-router-dom";
import { Minus, Plus, Trash2 } from "lucide-react";
import { useCart } from "../context/CartContext";

export default function QuotationSidebar() {
  const { items, updateQuantity, removeItem, totalItems } = useCart();

  return (
    <aside className="hidden lg:flex flex-col w-80 shrink-0 bg-white border border-black/5 rounded-lg h-fit sticky top-24 p-5">
      <div className="flex items-center justify-between mb-4">
        <h2 className="font-display font-semibold text-graphite">
          Quotation Summary
        </h2>
        <span className="font-mono text-xs text-brand-600 bg-brand-50 px-2 py-1 rounded">
          {totalItems} {totalItems === 1 ? "item" : "items"}
        </span>
      </div>

      {items.length === 0 ? (
        <p className="text-sm text-steel">
          Aún no agregas productos. Explora el catálogo y dale "Add to Quote".
        </p>
      ) : (
        <ul className="flex flex-col gap-3 max-h-[420px] overflow-y-auto pr-1">
          {items.map((item) => (
            <li
              key={item.id}
              className="flex items-center justify-between gap-2 border-b border-black/5 pb-3"
            >
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-graphite truncate">
                  {item.nombre_producto}
                </p>
                <div className="flex items-center gap-2 mt-1">
                  <button
                    onClick={() => updateQuantity(item.id, item.cantidad - 1)}
                    className="p-1 rounded bg-bone hover:bg-black/5"
                    aria-label="Disminuir cantidad"
                  >
                    <Minus size={12} />
                  </button>
                  <span className="font-mono text-xs w-6 text-center">
                    {item.cantidad}
                  </span>
                  <button
                    onClick={() => updateQuantity(item.id, item.cantidad + 1)}
                    className="p-1 rounded bg-bone hover:bg-black/5"
                    aria-label="Aumentar cantidad"
                  >
                    <Plus size={12} />
                  </button>
                </div>
              </div>
              <button
                onClick={() => removeItem(item.id)}
                className="p-1.5 text-steel hover:text-amber-500"
                aria-label="Quitar producto"
              >
                <Trash2 size={14} />
              </button>
            </li>
          ))}
        </ul>
      )}

      <Link
        to="/quote-form"
        className="mt-5 text-center bg-graphite text-bone font-medium text-sm py-2.5 rounded-md hover:bg-graphite2 transition-colors"
      >
        Proceed to Quote Form
      </Link>
    </aside>
  );
}
