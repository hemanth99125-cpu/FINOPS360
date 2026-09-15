import { createClient } from "@/lib/supabase/server";
import SkillBar from "@/components/SkillBar";
import Heatmap from "@/components/Heatmap";
import { readinessLevel } from "@/lib/types";

export const dynamic = "force-dynamic";

const ACTIVITY_LABELS: Record<string, string> = {
  login: "Logged in",
  lesson_started: "Started lesson",
  lesson_resumed: "Resumed lesson",
  lesson_completed: "Completed lesson",
  quiz_started: "Started quiz",
  quiz_completed: "Completed quiz",
  challenge_started: "Started challenge",
  challenge_completed: "Completed challenge",
  simulation_started: "Started simulation",
  simulation_completed: "Completed simulation",
  exercise_completed: "Completed exercise",
  assessment_completed: "Completed assessment",
  project_started: "Started project",
  project_completed: "Completed project",
};

export default async function TrackerPage() {
  const supabase = await createClient();

  // Single-learner deployment: find the one learner profile to report on.
  const { data: learner } = await supabase
    .from("profiles")
    .select("id, full_name")
    .eq("role", "learner")
    .order("created_at", { ascending: true })
    .limit(1)
    .maybeSingle();

  if (!learner) {
    return <p className="text-sm text-grey">No learner account exists yet.</p>;
  }

  const userId = learner.id;
  const today = new Date().toISOString().slice(0, 10);
  const ninetyDaysAgo = new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10);

  const [
    { data: todayStats },
    { data: recentStats },
    { data: todayActivities },
    { data: userSkills },
    { data: readiness },
    { data: quizHistory },
    { data: inProgress },
  ] = await Promise.all([
    supabase.from("daily_learning_stats").select("*").eq("user_id", userId).eq("date", today).maybeSingle(),
    supabase
      .from("daily_learning_stats")
      .select("date, active_learning_minutes")
      .eq("user_id", userId)
      .gte("date", ninetyDaysAgo),
    supabase
      .from("learning_activities")
      .select("activity_type, created_at, metadata, lesson:lessons(title), duration_seconds")
      .eq("user_id", userId)
      .gte("created_at", `${today}T00:00:00Z`)
      .order("created_at", { ascending: true }),
    supabase
      .from("user_skills")
      .select("skill_score, skill_level, skill:skills(skill_name)")
      .eq("user_id", userId)
      .order("skill_score", { ascending: false }),
    supabase
      .from("readiness_history")
      .select("*")
      .eq("user_id", userId)
      .order("recorded_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
    supabase
      .from("quiz_attempts")
      .select("score, completed_at, quiz:quizzes(title)")
      .eq("user_id", userId)
      .order("completed_at", { ascending: true }),
    supabase
      .from("user_lesson_progress")
      .select("progress_percentage, lesson:lessons(title, module:modules(title, course:courses(title)))")
      .eq("user_id", userId)
      .eq("status", "in_progress")
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
  ]);

  const heatmapData: Record<string, number> = {};
  (recentStats ?? []).forEach((d) => (heatmapData[d.date] = d.active_learning_minutes));

  const skills = (userSkills ?? []) as unknown as {
    skill_score: number;
    skill_level: string;
    skill: { skill_name: string };
  }[];
  const strong = skills.filter((s) => s.skill_score >= 75);
  const developing = skills.filter((s) => s.skill_score >= 50 && s.skill_score < 75);
  const weak = skills.filter((s) => s.skill_score < 50);

  const overall = readiness?.overall_score ?? 0;

  const activeDays30 = (recentStats ?? []).filter(
    (d) => d.active_learning_minutes >= 10 && d.date >= new Date(Date.now() - 30 * 86400000).toISOString().slice(0, 10)
  ).length;

  return (
    <div className="space-y-10">
      <div>
        <p className="text-xs text-grey mb-1">Learner</p>
        <h1 className="font-serif-report text-2xl mb-4">{learner.full_name ?? "Learner"}</h1>

        <div className="grid grid-cols-4 gap-6 border border-line rounded-sm bg-white p-5">
          <div>
            <p className="text-xs text-grey mb-1">Industry readiness</p>
            <p className="text-xl font-serif-report tabular">{overall.toFixed(0)}%</p>
            <p className="text-xs text-ink-soft">{readinessLevel(overall)}</p>
          </div>
          <div>
            <p className="text-xs text-grey mb-1">Current focus</p>
            <p className="text-sm text-ink">
              {(inProgress?.lesson as any)?.title ?? "Not started yet"}
            </p>
            <p className="text-xs text-ink-soft">
              {(inProgress?.lesson as any)?.module?.course?.title ?? ""}
            </p>
          </div>
          <div>
            <p className="text-xs text-grey mb-1">Active learning days (30d)</p>
            <p className="text-xl font-serif-report tabular">{activeDays30}</p>
          </div>
          <div>
            <p className="text-xs text-grey mb-1">Today</p>
            <p className="text-sm text-ink tabular">
              {todayStats?.active_learning_minutes ?? 0} min · {todayStats?.lessons_completed ?? 0} lessons ·{" "}
              {todayStats?.quizzes_completed ?? 0} quizzes
              {todayStats?.quiz_average_score != null ? ` (${Math.round(todayStats.quiz_average_score)}%)` : ""}
            </p>
          </div>
        </div>
      </div>

      <div>
        <p className="text-xs text-grey mb-3">Today's activity timeline</p>
        {(!todayActivities || todayActivities.length === 0) && (
          <p className="text-sm text-grey">No recorded activity yet today.</p>
        )}
        <div className="space-y-3">
          {(todayActivities ?? []).map((a, i) => (
            <div key={i} className="flex gap-4 text-sm">
              <span className="text-xs text-grey tabular w-16 shrink-0 pt-0.5">
                {new Date(a.created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              </span>
              <span className="text-ink">
                {ACTIVITY_LABELS[a.activity_type] ?? a.activity_type}
                {(a as any).lesson?.title ? ` — ${(a as any).lesson.title}` : ""}
                {(a.metadata as any)?.score != null ? (
                  <span className="text-ink-soft"> · Score: {(a.metadata as any).score}%</span>
                ) : null}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div>
        <p className="text-xs text-grey mb-3">Learning consistency — last 90 days</p>
        <Heatmap days={90} data={heatmapData} />
      </div>

      <div className="grid grid-cols-3 gap-8 border-t border-line pt-8">
        <div>
          <p className="text-xs text-grey mb-3">Strong skills</p>
          {strong.length === 0 && <p className="text-sm text-grey">None yet.</p>}
          {strong.map((s) => (
            <SkillBar key={s.skill.skill_name} name={s.skill.skill_name} score={s.skill_score} level={s.skill_level} />
          ))}
        </div>
        <div>
          <p className="text-xs text-grey mb-3">Developing skills</p>
          {developing.length === 0 && <p className="text-sm text-grey">None yet.</p>}
          {developing.map((s) => (
            <SkillBar key={s.skill.skill_name} name={s.skill.skill_name} score={s.skill_score} level={s.skill_level} />
          ))}
        </div>
        <div>
          <p className="text-xs text-grey mb-3">Weak skills</p>
          {weak.length === 0 && <p className="text-sm text-grey">None yet.</p>}
          {weak.map((s) => (
            <SkillBar key={s.skill.skill_name} name={s.skill.skill_name} score={s.skill_score} level={s.skill_level} />
          ))}
        </div>
      </div>

      {quizHistory && quizHistory.length > 0 && (
        <div className="border-t border-line pt-8">
          <p className="text-xs text-grey mb-3">Learning insight</p>
          <p className="text-sm text-ink-soft leading-relaxed">
            {(() => {
              const byQuiz: Record<string, number[]> = {};
              quizHistory.forEach((q: any) => {
                const title = q.quiz?.title ?? "Quiz";
                byQuiz[title] = byQuiz[title] || [];
                byQuiz[title].push(q.score);
              });
              const entries = Object.entries(byQuiz).filter(([, scores]) => scores.length > 1);
              if (entries.length === 0) {
                const last = quizHistory[quizHistory.length - 1] as any;
                return `Most recent quiz — ${last.quiz?.title ?? "Quiz"} — scored ${last.score}%.`;
              }
              const [title, scores] = entries[entries.length - 1];
              const improvement = scores[scores.length - 1] - scores[0];
              return `The learner attempted "${title}" ${scores.length} times: ${scores.join("% → ")}%. ${
                improvement >= 0 ? `Improvement: +${improvement}%.` : `Change: ${improvement}%.`
              }`;
            })()}
          </p>
        </div>
      )}
    </div>
  );
}
