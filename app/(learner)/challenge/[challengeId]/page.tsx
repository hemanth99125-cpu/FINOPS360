import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import ChallengeClient from "./ChallengeClient";

export default async function ChallengePage({
  params,
}: {
  params: Promise<{ challengeId: string }>;
}) {
  const { challengeId } = await params;
  const supabase = await createClient();

  // scoring_rules is intentionally still readable here (single-trusted-user
  // deployment); a multi-user version should move grading criteria behind a
  // server-only view instead of the shared challenges table.
  const { data: challenge } = await supabase
    .from("challenges")
    .select("id, title, description, scenario, scenario_data, instructions, scoring_rules")
    .eq("id", challengeId)
    .maybeSingle();

  if (!challenge) notFound();

  return <ChallengeClient challenge={challenge} />;
}
