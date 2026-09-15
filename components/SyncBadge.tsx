"use client";

import { useEffect, useState } from "react";

export type SyncState = "saved" | "syncing" | "pending" | "offline";

const config: Record<SyncState, { label: string; dot: string }> = {
  saved: { label: "All progress saved", dot: "bg-teal" },
  syncing: { label: "Syncing…", dot: "bg-gold animate-pulse" },
  pending: { label: "Sync pending", dot: "bg-gold" },
  offline: { label: "Offline", dot: "bg-rust" },
};

export default function SyncBadge({ state }: { state: SyncState }) {
  const [online, setOnline] = useState(true);

  useEffect(() => {
    setOnline(navigator.onLine);
    const on = () => setOnline(true);
    const off = () => setOnline(false);
    window.addEventListener("online", on);
    window.addEventListener("offline", off);
    return () => {
      window.removeEventListener("online", on);
      window.removeEventListener("offline", off);
    };
  }, []);

  const effective = !online ? "offline" : state;
  const c = config[effective];

  return (
    <div className="flex items-center gap-1.5 text-xs text-grey">
      <span className={`inline-block w-1.5 h-1.5 rounded-full ${c.dot}`} />
      {c.label}
    </div>
  );
}
