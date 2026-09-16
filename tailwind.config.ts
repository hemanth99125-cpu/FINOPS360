import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        paper: "var(--paper)",
        surface: "var(--surface)",
        ink: "var(--ink)",
        "ink-soft": "var(--ink-soft)",
        teal: "var(--teal)",
        "teal-dark": "var(--teal-dark)",
        "teal-soft": "var(--teal-soft)",
        gold: "var(--gold)",
        "gold-soft": "var(--gold-soft)",
        rust: "var(--rust)",
        "rust-soft": "var(--rust-soft)",
        grey: "var(--grey)",
        line: "var(--line)",
      },
      borderRadius: {
        // Bumped from the old 4px "hairline report" look to a real,
        // modern radius. Almost every card/button in the app uses
        // rounded-sm, so this one change restyles the whole UI.
        sm: "10px",
        md: "14px",
        lg: "20px",
      },
      boxShadow: {
        card: "0 1px 2px rgba(16,24,40,0.04), 0 2px 8px rgba(16,24,40,0.06)",
        "card-hover": "0 2px 4px rgba(16,24,40,0.06), 0 8px 20px rgba(16,24,40,0.10)",
      },
    },
  },
  plugins: [],
};
export default config;
