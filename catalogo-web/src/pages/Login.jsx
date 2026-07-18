import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Login() {
  const { signIn } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const { error } = await signIn(email, password);
    setLoading(false);
    if (error) {
      setError("Credenciales inválidas. Verifica tu correo y contraseña.");
      return;
    }
    navigate("/");
  }

  return (
    <div className="min-h-screen bg-graphite flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="flex items-center gap-2 justify-center mb-8">
          <span className="w-2.5 h-2.5 rounded-sm bg-brand-500" />
          <span className="font-display font-semibold text-xl text-bone tracking-tight">
            Industr<span className="text-brand-500">IA</span>
          </span>
        </div>

        <div className="bg-graphite2 border border-white/10 rounded-lg p-6">
          <h1 className="font-display text-bone font-semibold text-lg mb-1">
            Inicia sesión
          </h1>
          <p className="text-steel text-sm mb-6">
            Accede a tu catálogo y cotizaciones.
          </p>

          {error && (
            <p className="text-amber-500 text-sm bg-amber-500/10 rounded-md px-3 py-2 mb-4">
              {error}
            </p>
          )}

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <div>
              <label className="text-xs font-mono text-steel uppercase">
                Business email
              </label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full mt-1 bg-white/5 border border-white/10 rounded-md px-3 py-2.5 text-bone outline-none focus:border-brand-500/50"
                placeholder="nombre@empresa.com"
              />
            </div>
            <div>
              <label className="text-xs font-mono text-steel uppercase">
                Contraseña
              </label>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full mt-1 bg-white/5 border border-white/10 rounded-md px-3 py-2.5 text-bone outline-none focus:border-brand-500/50"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="bg-brand-500 text-graphite font-medium py-2.5 rounded-md hover:bg-brand-400 transition-colors disabled:opacity-50"
            >
              {loading ? "Entrando..." : "Entrar"}
            </button>
          </form>

          <p className="text-steel text-sm mt-5 text-center">
            ¿No tienes cuenta?{" "}
            <Link to="/register" className="text-brand-500 hover:underline">
              Regístrate
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
