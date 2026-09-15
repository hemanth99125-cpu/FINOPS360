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
    <aside className="w-56 shrink-0 border-r border-line min-h-screen py-8 px-5 flex flex-col justify-between">
      <div>
        <p className="text-xs text-grey mb-1">FinOps Accelerator</p>
        <p className="font-serif-report text-base text-ink mb-8">{name}</p>
        <nav className="space-y-1">
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className={`block text-sm px-2 py-1.5 rounded-sm ${
                pathname === l.href ? "bg-teal-soft text-ink" : "text-ink-soft hover:bg-black/[0.03]"
              }`}
            >
              {l.label}
            </Link>
          ))}
        </nav>
      </div>
      <button onClick={signOut} className="text-xs text-grey hover:text-ink text-left">
        Sign out
      </button>
    </aside>
  );
}
