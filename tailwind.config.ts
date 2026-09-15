import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        paper: "var(--paper)",
        ink: "var(--ink)",
        "ink-soft": "var(--ink-soft)",
        teal: "var(--teal)",
        "teal-soft": "var(--teal-soft)",
        gold: "var(--gold)",
        "gold-soft": "var(--gold-soft)",
        rust: "var(--rust)",
        "rust-soft": "var(--rust-soft)",
        grey: "var(--grey)",
        line: "var(--line)",
      },
      borderRadius: {
        sm: "4px",
      },
    },
  },
  plugins: [],
};
export default config;
