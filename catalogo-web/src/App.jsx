import { useState } from "react";
import { Routes, Route } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/AuthContext";
import { CartProvider } from "./context/CartContext";
import ProtectedRoute from "./components/ProtectedRoute";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Catalog from "./pages/Catalog";
import QuoteForm from "./pages/QuoteForm";
import History from "./pages/History";

function AppShell() {
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <div className="min-h-screen flex flex-col bg-bone">
      <Header onSearch={setSearchQuery} />
      <main className="flex-1">
        <Routes>
          <Route path="/" element={<Catalog searchQuery={searchQuery} />} />
          <Route path="/quote-form" element={<QuoteForm />} />
          <Route path="/historial" element={<History />} />
        </Routes>
      </main>
      <Footer />
    </div>
  );
}

function AuthGate() {
  const { loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-graphite text-bone font-mono text-sm">
        Cargando...
      </div>
    );
  }

  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route
        path="/*"
        element={
          <ProtectedRoute>
            <CartProvider>
              <AppShell />
            </CartProvider>
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AuthGate />
    </AuthProvider>
  );
}
