import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

// Middleware already redirects based on role for any signed-in user; this
// page only ever renders for the brief moment before that resolves, or if
// middleware is bypassed in dev — so keep it a safe, simple fallback.
export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  redirect(profile?.role === "tracker" ? "/tracker" : "/dashboard");
}
