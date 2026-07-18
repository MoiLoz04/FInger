import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Register() {
  const { signUp } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ nombre: "", email: "", password: "" });
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);

  function update(field, value) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const { error } = await signUp(form.email, form.password, form.nombre);
    setLoading(false);

    if (error) {
      setError(error.message);
      return;
    }
    setSuccess(true);
    setTimeout(() => navigate("/login"), 2000);
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
            Crea tu cuenta
          </h1>
          <p className="text-steel text-sm mb-6">
            Regístrate para empezar a cotizar.
          </p>

          {success ? (
            <p className="text-brand-500 text-sm bg-brand-500/10 rounded-md px-3 py-3">
              Cuenta creada. Redirigiendo a inicio de sesión...
            </p>
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col gap-4">
              {error && (
                <p className="text-amber-500 text-sm bg-amber-500/10 rounded-md px-3 py-2">
                  {error}
                </p>
              )}
              <div>
                <label className="text-xs font-mono text-steel uppercase">
                  Nombre completo
                </label>
                <input
                  type="text"
                  required
                  value={form.nombre}
                  onChange={(e) => update("nombre", e.target.value)}
                  className="w-full mt-1 bg-white/5 border border-white/10 rounded-md px-3 py-2.5 text-bone outline-none focus:border-brand-500/50"
                />
              </div>
              <div>
                <label className="text-xs font-mono text-steel uppercase">
                  Business email
                </label>
                <input
                  type="email"
                  required
                  value={form.email}
                  onChange={(e) => update("email", e.target.value)}
                  className="w-full mt-1 bg-white/5 border border-white/10 rounded-md px-3 py-2.5 text-bone outline-none focus:border-brand-500/50"
                />
              </div>
              <div>
                <label className="text-xs font-mono text-steel uppercase">
                  Contraseña
                </label>
                <input
                  type="password"
                  required
                  minLength={6}
                  value={form.password}
                  onChange={(e) => update("password", e.target.value)}
                  className="w-full mt-1 bg-white/5 border border-white/10 rounded-md px-3 py-2.5 text-bone outline-none focus:border-brand-500/50"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="bg-brand-500 text-graphite font-medium py-2.5 rounded-md hover:bg-brand-400 transition-colors disabled:opacity-50"
              >
                {loading ? "Creando cuenta..." : "Crear cuenta"}
              </button>
            </form>
          )}

          <p className="text-steel text-sm mt-5 text-center">
            ¿Ya tienes cuenta?{" "}
            <Link to="/login" className="text-brand-500 hover:underline">
              Inicia sesión
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
