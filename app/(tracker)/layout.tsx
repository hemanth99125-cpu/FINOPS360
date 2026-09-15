import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import TrackerSignOut from "@/components/TrackerSignOut";

export default async function TrackerLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).single();
  if (profile?.role !== "tracker") redirect("/dashboard");

  return (
    <div className="min-h-screen bg-paper">
      <header className="border-b border-line px-10 py-5 flex items-center justify-between">
        <div>
          <p className="text-xs text-grey">Private tracker</p>
          <p className="font-serif-report text-lg">FinOps Career Accelerator</p>
        </div>
        <TrackerSignOut />
      </header>
      <main className="px-10 py-8 max-w-5xl mx-auto">{children}</main>
    </div>
  );
}
