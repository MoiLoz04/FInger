/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        graphite: "#14171c",
        graphite2: "#1c2128",
        bone: "#f7f7f4",
        steel: "#5b6470",
        brand: {
          50: "#eafff1",
          400: "#4ade80",
          500: "#22c55e",
          600: "#16a34a",
        },
        amber: {
          500: "#f59e0b",
        },
      },
      fontFamily: {
        display: ["Space Grotesk", "sans-serif"],
        body: ["Inter", "sans-serif"],
        mono: ["JetBrains Mono", "monospace"],
      },
    },
  },
  plugins: [],
};
