"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const links = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/curriculum", label: "Curriculum" },
  { href: "/capstone", label: "Capstone Project" },
  { href: "/interview", label: "Mock Interview" },
];

export default function LearnerSidebar({ name }: { name: string }) {
  const pathname = usePathname();
  const router = useRouter();
  const supabase = createClient();

  async function signOut() {
    await supabase.auth.signOut();
    router.push("/login");
  }

  return (
    <aside className="w-60 shrink-0 min-h-screen py-8 px-4 flex flex-col justify-between bg-surface border-r border-line">
      <div>
        <div className="px-2 mb-8">
          <div className="w-8 h-8 rounded-md bg-ink flex items-center justify-center mb-3">
            <span className="text-paper text-sm font-bold">F</span>
          </div>
          <p className="text-xs text-grey mb-0.5">FinOps Accelerator</p>
          <p className="font-serif-report text-base text-ink">{name}</p>
        </div>
        <nav className="space-y-1">
          {links.map((l) => {
            const active = pathname === l.href;
            return (
              <Link
                key={l.href}
                href={l.href}
                className={`relative block text-sm px-3 py-2 rounded-sm font-medium ${
                  active
                    ? "bg-teal-soft text-teal-dark"
                    : "text-ink-soft hover:bg-paper hover:text-ink"
                }`}
              >
                {active && (
                  <span className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-1 h-4 w-1 rounded-full bg-teal" />
                )}
                {l.label}
              </Link>
            );
          })}
        </nav>
      </div>
      <button
        onClick={signOut}
        className="text-xs text-grey hover:text-rust hover:bg-rust-soft text-left px-3 py-2 rounded-sm"
      >
        Sign out
      </button>
    </aside>
  );
}
