"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

type Mode = "sign_in" | "sign_up";

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();
  const [mode, setMode] = useState<Mode>("sign_in");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [role, setRole] = useState<"learner" | "tracker">("learner");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    if (mode === "sign_up") {
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { full_name: fullName, role } },
      });
      if (error) setError(error.message);
      else {
        router.push("/");
        router.refresh();
      }
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) setError(error.message);
      else router.refresh();
    }
    setLoading(false);
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-paper px-6">
      <div className="w-full max-w-sm">
        <div className="mb-10">
          <p className="text-xs tracking-wide text-grey mb-1">Private access</p>
          <h1 className="font-serif-report text-2xl text-ink leading-tight">
            FinOps Career Accelerator
          </h1>
        </div>

        <div className="flex gap-6 mb-6 report-divider pt-4">
          <button
            className={`text-sm pb-1 ${mode === "sign_in" ? "text-ink border-b-2 border-teal" : "text-grey"}`}
            onClick={() => setMode("sign_in")}
            type="button"
          >
            Sign in
          </button>
          <button
            className={`text-sm pb-1 ${mode === "sign_up" ? "text-ink border-b-2 border-teal" : "text-grey"}`}
            onClick={() => setMode("sign_up")}
            type="button"
          >
            Create account
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {mode === "sign_up" && (
            <div>
              <label className="block text-xs text-grey mb-1">Full name</label>
              <input
                className="w-full border border-line bg-white px-3 py-2 text-sm rounded-sm focus:outline-none focus:ring-2 focus:ring-teal"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required
              />
            </div>
          )}

          <div>
            <label className="block text-xs text-grey mb-1">Email</label>
            <input
              type="email"
              className="w-full border border-line bg-white px-3 py-2 text-sm rounded-sm focus:outline-none focus:ring-2 focus:ring-teal"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-xs text-grey mb-1">Password</label>
            <input
              type="password"
              className="w-full border border-line bg-white px-3 py-2 text-sm rounded-sm focus:outline-none focus:ring-2 focus:ring-teal"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              minLength={6}
              required
            />
          </div>

          {mode === "sign_up" && (
            <div>
              <label className="block text-xs text-grey mb-1">Role</label>
              <div className="flex gap-2">
                {(["learner", "tracker"] as const).map((r) => (
                  <button
                    type="button"
                    key={r}
                    onClick={() => setRole(r)}
                    className={`flex-1 border rounded-sm px-3 py-2 text-sm capitalize ${
                      role === r
                        ? "border-teal bg-teal-soft text-ink"
                        : "border-line text-grey"
                    }`}
                  >
                    {r}
                  </button>
                ))}
              </div>
              <p className="text-xs text-grey mt-1">
                Learner does the coursework. Tracker only sees the private progress dashboard.
              </p>
            </div>
          )}

          {error && (
            <p className="text-sm text-rust bg-rust-soft px-3 py-2 rounded-sm">{error}</p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-ink text-paper text-sm py-2.5 rounded-sm hover:bg-ink/90 disabled:opacity-60"
          >
            {loading ? "Please wait…" : mode === "sign_up" ? "Create account" : "Sign in"}
          </button>
        </form>
      </div>
    </div>
  );
}
