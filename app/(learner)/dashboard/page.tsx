import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import SkillBar from "@/components/SkillBar";
import { readinessLevel } from "@/lib/types";

export const dynamic = "force-dynamic";

function computeStreak(days: { date: string; active_learning_minutes: number }[]) {
  const activeDates = new Set(
    days.filter((d) => d.active_learning_minutes >= 10).map((d) => d.date)
  );
  let current = 0;
  let cursor = new Date();
  // walk backwards from today while each day was active
  while (true) {
    const key = cursor.toISOString().slice(0, 10);
    if (activeDates.has(key)) {
      current += 1;
      cursor.setDate(cursor.getDate() - 1);
    } else {
      break;
    }
  }
  let longest = 0;
  let running = 0;
  const sorted = [...days].sort((a, b) => a.date.localeCompare(b.date));
  for (const d of sorted) {
    if (d.active_learning_minutes >= 10) {
      running += 1;
      longest = Math.max(longest, running);
    } else {
      running = 0;
    }
  }
  return { current, longest, activeDays: activeDates.size };
}

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  const userId = user!.id;
  const today = new Date().toISOString().slice(0, 10);

  const [
    { data: inProgress },
    { data: todayStats },
    { data: recentDays },
    { data: userSkills },
    { data: readiness },
  ] = await Promise.all([
    supabase
      .from("user_lesson_progress")
      .select("progress_percentage, lesson:lessons(id, title, module:modules(title, course:courses(title)))")
      .eq("user_id", userId)
      .eq("status", "in_progress")
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
    supabase.from("daily_learning_stats").select("*").eq("user_id", userId).eq("date", today).maybeSingle(),
    supabase
      .from("daily_learning_stats")
      .select("date, active_learning_minutes")
      .eq("user_id", userId)
      .gte("date", new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10)),
    supabase
      .from("user_skills")
      .select("skill_score, skill_level, skill:skills(skill_name)")
      .eq("user_id", userId)
      .order("skill_score", { ascending: true }),
    supabase
      .from("readiness_history")
      .select("*")
      .eq("user_id", userId)
      .order("recorded_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
  ]);

  // If nothing is in progress, find the first not-started lesson in sequence.
  let nextLesson = inProgress?.lesson as unknown as
    | { id: string; title: string; module: { title: string; course: { title: string } } }
    | undefined;
  let nextLessonProgress = inProgress?.progress_percentage ?? 0;

  if (!nextLesson) {
    // Walk the full curriculum in path -> course -> module -> lesson order and
    // land on the first lesson the learner hasn't completed yet. (Lesson
    // sequence_order only resets to 1 within each module, so ordering by it
    // alone breaks as soon as more than one module/level exists.)
    const [{ data: allLessons }, { data: completedRows }] = await Promise.all([
      supabase
        .from("lessons")
        .select(
          "id, title, sequence_order, module:modules(id, title, sequence_order, course:courses(id, title, sequence_order, learning_path:learning_paths(sequence_order)))"
        ),
      supabase.from("user_lesson_progress").select("lesson_id").eq("user_id", userId).eq("status", "completed"),
    ]);

    const completedIds = new Set((completedRows ?? []).map((r) => r.lesson_id));
    type Row = {
      id: string;
      title: string;
      sequence_order: number;
      module: { id: string; title: string; sequence_order: number; course: { id: string; title: string; sequence_order: number; learning_path: { sequence_order: number } } };
    };
    const ordered = ((allLessons ?? []) as unknown as Row[]).sort((a, b) => {
      const ap = a.module.course.learning_path.sequence_order;
      const bp = b.module.course.learning_path.sequence_order;
      if (ap !== bp) return ap - bp;
      const ac = a.module.course.sequence_order;
      const bc = b.module.course.sequence_order;
      if (ac !== bc) return ac - bc;
      const am = a.module.sequence_order;
      const bm = b.module.sequence_order;
      if (am !== bm) return am - bm;
      return a.sequence_order - b.sequence_order;
    });
    const firstIncomplete = ordered.find((l) => !completedIds.has(l.id));
    nextLesson = firstIncomplete
      ? { id: firstIncomplete.id, title: firstIncomplete.title, module: { title: firstIncomplete.module.title, course: { title: firstIncomplete.module.course.title } } }
      : undefined;
    nextLessonProgress = 0;
  }

  const streak = computeStreak(recentDays ?? []);
  const skills = (userSkills ?? []) as unknown as {
    skill_score: number;
    skill_level: string;
    skill: { skill_name: string };
  }[];
  const weak = skills.filter((s) => s.skill_score < 50).slice(0, 3);
  const strong = skills.filter((s) => s.skill_score >= 75).slice(0, 3);
  const overall = readiness?.overall_score ?? 0;

  return (
    <div className="space-y-10">
      <div>
        <p className="text-xs text-grey mb-1">Continue learning</p>
        {nextLesson ? (
          <div className="border border-line rounded-sm p-5 bg-white">
            <p className="text-xs text-teal mb-1">
              {nextLesson.module?.course?.title} · {nextLesson.module?.title}
            </p>
            <h2 className="font-serif-report text-xl mb-3">{nextLesson.title}</h2>
            <div className="flex items-center justify-between">
              <div className="h-1.5 w-40 bg-line/60 rounded-sm overflow-hidden">
                <div
                  className="h-full bg-teal rounded-sm"
                  style={{ width: `${Math.max(4, nextLessonProgress)}%` }}
                />
              </div>
              <Link
                href={`/learn/${nextLesson.id}`}
                className="text-sm bg-ink text-paper px-4 py-2 rounded-sm hover:bg-ink/90"
              >
                Continue Learning →
              </Link>
            </div>
          </div>
        ) : (
          <p className="text-sm text-grey">No curriculum content loaded yet.</p>
        )}
      </div>

      <div className="grid grid-cols-3 gap-6">
        <div>
          <p className="text-xs text-grey mb-2">Today</p>
          <p className="text-2xl font-serif-report tabular">
            {todayStats?.active_learning_minutes ?? 0}
            <span className="text-sm text-grey"> min</span>
          </p>
          <p className="text-xs text-ink-soft mt-1 tabular">
            {todayStats?.lessons_completed ?? 0} lessons · {todayStats?.quizzes_completed ?? 0} quizzes
            {todayStats?.quiz_average_score != null ? ` (${Math.round(todayStats.quiz_average_score)}%)` : ""} ·{" "}
            {todayStats?.challenges_completed ?? 0} challenges
          </p>
        </div>

        <div>
          <p className="text-xs text-grey mb-2">Learning streak</p>
          <p className="text-2xl font-serif-report tabular">🔥 {streak.current}</p>
          <p className="text-xs text-ink-soft mt-1 tabular">
            Longest {streak.longest} · Active days (90d) {streak.activeDays}
          </p>
        </div>

        <div>
          <p className="text-xs text-grey mb-2">Industry readiness</p>
          <p className="text-2xl font-serif-report tabular">{overall.toFixed(0)}%</p>
          <p className="text-xs text-ink-soft mt-1">{readinessLevel(overall)}</p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-10">
        <div>
          <p className="text-xs text-grey mb-3">Strong skills</p>
          {strong.length === 0 && <p className="text-sm text-grey">None yet — keep going.</p>}
          {strong.map((s) => (
            <SkillBar key={s.skill.skill_name} name={s.skill.skill_name} score={s.skill_score} level={s.skill_level} />
          ))}
        </div>
        <div>
          <p className="text-xs text-grey mb-3">Developing / weak skills</p>
          {weak.length === 0 && <p className="text-sm text-grey">None flagged yet.</p>}
          {weak.map((s) => (
            <SkillBar key={s.skill.skill_name} name={s.skill.skill_name} score={s.skill_score} level={s.skill_level} />
          ))}
        </div>
      </div>

      {weak.length > 0 && (
        <div className="border-t border-line pt-6">
          <p className="text-xs text-grey mb-2">Next recommended action</p>
          <h3 className="font-serif-report text-lg mb-2">Improve {weak[0].skill.skill_name}</h3>
          <p className="text-sm text-ink-soft mb-3">
            Your recent performance shows this area needs more practice (currently{" "}
            {weak[0].skill_score.toFixed(0)}%). Revisit the related lesson, then retry the quiz or
            challenge that covers it.
          </p>
        </div>
      )}
    </div>
  );
}
