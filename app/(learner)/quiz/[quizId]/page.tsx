import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import QuizClient from "./QuizClient";

export default async function QuizPage({ params }: { params: Promise<{ quizId: string }> }) {
  const { quizId } = await params;
  const supabase = await createClient();

  const { data: quiz } = await supabase
    .from("quizzes")
    .select("id, title, description, passing_score")
    .eq("id", quizId)
    .maybeSingle();

  if (!quiz) notFound();

  // Deliberately NOT selecting correct_answer/explanation here — grading happens
  // server-side via the submit_quiz_attempt RPC, which returns per-question
  // explanations only after the learner has answered.
  const { data: questions } = await supabase
    .from("quiz_questions")
    .select("id, question, question_type, options, skill_category")
    .eq("quiz_id", quizId)
    .order("sequence_order", { ascending: true });

  const { data: challenges } = await supabase.from("challenges").select("id, title").limit(1);

  return (
    <QuizClient
      quiz={quiz}
      questions={questions ?? []}
      challenge={challenges?.[0] ?? null}
    />
  );
}
