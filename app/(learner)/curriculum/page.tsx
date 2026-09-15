import { createClient } from "@/lib/supabase/server";
import CurriculumClient from "./CurriculumClient";

export const dynamic = "force-dynamic";

export type CurriculumLevel = {
  path_id: string;
  path_title: string;
  path_level: string;
  sequence_order: number;
  lessons: { id: string; title: string; completed: boolean }[];
  quiz: { id: string; title: string } | null;
  challenge: { id: string; title: string } | null;
};

// QA note: before this page existed, the only way to reach curriculum
// content was the dashboard's single "Continue Learning" lesson — there was
// no way to see the other 20 levels, jump ahead, or revisit a completed one.
// That was a minor gap at 9 levels; at 21 it's a real navigation problem, so
// this page lists every level with per-lesson completion status.
export default async function CurriculumPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  const userId = user!.id;

  const [{ data: paths }, { data: completedRows }] = await Promise.all([
    supabase
      .from("learning_paths")
      .select(
        "id, title, level, sequence_order, courses(modules(lessons(id, title, sequence_order), quizzes(id, title), challenges(id, title)))"
      )
      .order("sequence_order", { ascending: true }),
    supabase.from("user_lesson_progress").select("lesson_id").eq("user_id", userId).eq("status", "completed"),
  ]);

  const completedIds = new Set((completedRows ?? []).map((r) => r.lesson_id));

  const levels: CurriculumLevel[] = (paths ?? []).map((p: any) => {
    const module = p.courses?.[0]?.modules?.[0];
    const lessons = (module?.lessons ?? [])
      .slice()
      .sort((a: any, b: any) => a.sequence_order - b.sequence_order)
      .map((l: any) => ({ id: l.id, title: l.title, completed: completedIds.has(l.id) }));
    return {
      path_id: p.id,
      path_title: p.title,
      path_level: p.level,
      sequence_order: p.sequence_order,
      lessons,
      quiz: module?.quizzes?.[0] ?? null,
      challenge: module?.challenges?.[0] ?? null,
    };
  });

  return <CurriculumClient levels={levels} />;
}
