import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import LearnerSidebar from "@/components/LearnerSidebar";

export default async function LearnerLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, role")
    .eq("id", user.id)
    .single();

  if (profile?.role === "tracker") redirect("/tracker");

  return (
    <div className="flex min-h-screen bg-paper">
      <LearnerSidebar name={profile?.full_name ?? "Learner"} />
      <main className="flex-1 px-10 py-10 max-w-4xl mx-auto w-full">{children}</main>
    </div>
  );
}
