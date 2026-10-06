import { useState } from "react";
import { Link } from 'react-router-dom';

import { MapPin, Phone, Mail, Linkedin, Twitter, Facebook } from "lucide-react";

export default function Footer() {
  const [leadEmail, setLeadEmail] = useState("");
  const [sent, setSent] = useState(false);

  function handleLeadSubmit(e) {
    e.preventDefault();
    // Captura simple de lead corporativo; en producción esto insertaría
    // en una tabla `leads` de Supabase o dispararía un webhook a CRM.
    setSent(true);
    setLeadEmail("");
  }

  return (
    <footer id="soporte" className="bg-graphite text-bone/80 mt-auto">
      <div className="flex gap-4 text-xs text-steel mt-4">
  <Link to="/terminos" className="hover:text-brand-500">Términos de Uso</Link>
  <Link to="/privacidad" className="hover:text-brand-500">Aviso de Privacidad</Link>
</div>
      <div className="max-w-7xl mx-auto px-4 lg:px-6 py-12 grid grid-cols-1 md:grid-cols-4 gap-10">
        {/* Contacto */}
        <div>
          <h3 className="font-display text-bone font-semibold mb-4">Contacto</h3>
          <ul className="space-y-3 text-sm">
            <li className="flex items-start gap-2">
              <MapPin size={16} className="mt-0.5 text-brand-500 shrink-0" />
              <span>Parque Industrial Querétaro, Bernardo Quintana 1500</span>
            </li>
            <li className="flex items-center gap-2">
              <Phone size={16} className="text-brand-500 shrink-0" />
              <span className="font-mono">+52 442 555 0199</span>
            </li>
            <li className="flex items-center gap-2">
              <Mail size={16} className="text-brand-500 shrink-0" />
              <span className="font-mono">ventas@industria-b2b.mx</span>
            </li>
          </ul>
        </div>

        {/* Mapa esquematizado */}
        <div>
          <h3 className="font-display text-bone font-semibold mb-4">Ubicación</h3>
          <div className="rounded-md border border-white/10 bg-graphite2 h-32 relative overflow-hidden">
            <svg viewBox="0 0 200 100" className="w-full h-full opacity-70">
              <line x1="0" y1="30" x2="200" y2="30" stroke="#5b6470" strokeWidth="1" />
              <line x1="0" y1="70" x2="200" y2="70" stroke="#5b6470" strokeWidth="1" />
              <line x1="60" y1="0" x2="60" y2="100" stroke="#5b6470" strokeWidth="1" />
              <line x1="140" y1="0" x2="140" y2="100" stroke="#5b6470" strokeWidth="1" />
              <circle cx="140" cy="30" r="5" fill="#22c55e" />
            </svg>
            <span className="absolute bottom-2 left-2 text-[10px] font-mono text-steel">
              MAPA ESQUEMÁTICO · ZONA INDUSTRIAL
            </span>
          </div>
        </div>

        {/* Lead form */}
        <div>
          <h3 className="font-display text-bone font-semibold mb-4">
            ¿Eres comprador corporativo?
          </h3>
          {sent ? (
            <p className="text-sm text-brand-500">
              Gracias, un asesor te contactará pronto.
            </p>
          ) : (
            <form onSubmit={handleLeadSubmit} className="flex flex-col gap-2">
              <input
                type="email"
                required
                value={leadEmail}
                onChange={(e) => setLeadEmail(e.target.value)}
                placeholder="Tu correo corporativo"
                className="bg-white/5 border border-white/10 rounded-md px-3 py-2 text-sm placeholder:text-steel outline-none focus:border-brand-500/50"
              />
              <button
                type="submit"
                className="bg-brand-500 text-graphite font-medium text-sm rounded-md py-2 hover:bg-brand-400 transition-colors"
              >
                Solicitar contacto
              </button>
            </form>
          )}
        </div>

        {/* Redes */}
        <div>
          <h3 className="font-display text-bone font-semibold mb-4">Síguenos</h3>
          <div className="flex gap-3">
            <a
              href="#"
              aria-label="LinkedIn"
              className="p-2 rounded-md bg-white/5 hover:bg-brand-500 hover:text-graphite transition-colors"
            >
              <Linkedin size={16} />
            </a>
            <a
              href="#"
              aria-label="Twitter"
              className="p-2 rounded-md bg-white/5 hover:bg-brand-500 hover:text-graphite transition-colors"
            >
              <Twitter size={16} />
            </a>
            <a
              href="#"
              aria-label="Facebook"
              className="p-2 rounded-md bg-white/5 hover:bg-brand-500 hover:text-graphite transition-colors"
            >
              <Facebook size={16} />
            </a>
          </div>
        </div>
      </div>
      
      <div className="border-t border-white/10 py-4 text-center text-xs text-steel font-mono">
        © {new Date().getFullYear()} INDUSTRIA B2B · TODOS LOS DERECHOS RESERVADOS
      </div>
    </footer>
  );
}
