"use client";

import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export default function TrackerSignOut() {
  const router = useRouter();
  const supabase = createClient();

  return (
    <button
      onClick={async () => {
        await supabase.auth.signOut();
        router.push("/login");
      }}
      className="text-xs text-grey hover:text-ink"
    >
      Sign out
    </button>
  );
}
