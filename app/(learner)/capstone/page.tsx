import { createClient } from "@/lib/supabase/server";
import CapstoneClient from "./CapstoneClient";

export const dynamic = "force-dynamic";

export default async function CapstonePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: project } = await supabase
    .from("capstone_projects")
    .select("id, title, description, scenario, requirements, evaluation_criteria")
    .limit(1)
    .maybeSingle();

  if (!project) {
    return <p className="text-sm text-grey">No capstone project loaded yet.</p>;
  }

  const { data: existing } = await supabase
    .from("user_capstone_projects")
    .select("status, submission_data, score, completed_at")
    .eq("user_id", user!.id)
    .eq("project_id", project.id)
    .maybeSingle();

  return <CapstoneClient project={project} existing={existing ?? null} />;
}
