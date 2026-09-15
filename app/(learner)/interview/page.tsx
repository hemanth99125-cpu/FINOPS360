import { createClient } from "@/lib/supabase/server";
import InterviewClient from "./InterviewClient";

export const dynamic = "force-dynamic";

export type InterviewQuestion = {
  id: string;
  category: "behavioral" | "technical" | "scenario";
  question: string;
  skill_category: string | null;
  guidance: string | null;
  difficulty: "easy" | "medium" | "hard";
};

const SESSION_LENGTH = 5;

export default async function InterviewPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // No hidden answer key here (open-ended by nature), so unlike quiz
  // questions this can just be read straight from the client too — but
  // doing the random pick server-side keeps the page load to one query.
  const { data: pool } = await supabase
    .from("interview_questions")
    .select("id, category, question, skill_category, guidance, difficulty");

  const questions: InterviewQuestion[] = shuffle(pool ?? []).slice(0, SESSION_LENGTH);

  const { data: pastSessions } = await supabase
    .from("user_interview_sessions")
    .select("id, status, overall_self_rating, completed_at, started_at")
    .eq("user_id", user!.id)
    .order("started_at", { ascending: false })
    .limit(5);

  return <InterviewClient questions={questions} pastSessions={pastSessions ?? []} />;
}

function shuffle<T>(arr: T[]): T[] {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}
