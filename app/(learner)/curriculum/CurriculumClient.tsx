"use client";

import { useState } from "react";
import Link from "next/link";
import type { CurriculumLevel } from "./page";

export default function CurriculumClient({ levels }: { levels: CurriculumLevel[] }) {
  const [openId, setOpenId] = useState<string | null>(levels[0]?.path_id ?? null);

  const totalLessons = levels.reduce((sum, l) => sum + l.lessons.length, 0);
  const doneLessons = levels.reduce((sum, l) => sum + l.lessons.filter((x) => x.completed).length, 0);
  const overallPct = totalLessons ? Math.round((doneLessons / totalLessons) * 100) : 0;

  return (
    <div className="max-w-3xl">
      <p className="text-xs text-gold font-medium mb-1">Curriculum</p>
      <h1 className="font-serif-report text-3xl mb-2">All {levels.length} levels</h1>
      <p className="text-sm text-ink-soft mb-6">
        Jump to any level below — your progress carries over whether you go in order or not.
      </p>

      <div className="card p-5 mb-8 flex items-center gap-5">
        <div className="relative w-16 h-16 shrink-0">
          <svg viewBox="0 0 36 36" className="w-16 h-16 -rotate-90">
            <circle cx="18" cy="18" r="15.5" fill="none" stroke="var(--line)" strokeWidth="3.5" />
            <circle
              cx="18" cy="18" r="15.5" fill="none" stroke="var(--teal)" strokeWidth="3.5"
              strokeDasharray={`${overallPct * 0.974} 200`} strokeLinecap="round"
            />
          </svg>
          <span className="absolute inset-0 flex items-center justify-center text-sm font-serif-report">
            {overallPct}%
          </span>
        </div>
        <div>
          <p className="text-sm font-medium text-ink">Overall progress</p>
          <p className="text-xs text-ink-soft tabular mt-0.5">{doneLessons} of {totalLessons} lessons complete</p>
        </div>
      </div>

      <div className="grid gap-3">
        {levels.map((level) => {
          const doneCount = level.lessons.filter((l) => l.completed).length;
          const total = level.lessons.length;
          const pct = total ? Math.round((doneCount / total) * 100) : 0;
          const status = pct === 100 ? "done" : pct > 0 ? "active" : "new";
          const isOpen = openId === level.path_id;

          return (
            <div key={level.path_id} className="card card-hover overflow-hidden">
              <button
                onClick={() => setOpenId(isOpen ? null : level.path_id)}
                className="w-full flex items-center gap-4 px-5 py-4 text-left"
              >
                <span
                  className={`shrink-0 w-9 h-9 rounded-full flex items-center justify-center text-sm font-semibold tabular ${
                    status === "done"
                      ? "bg-teal text-surface"
                      : status === "active"
                      ? "bg-gold-soft text-gold"
                      : "bg-paper text-grey"
                  }`}
                >
                  {status === "done" ? "✓" : level.sequence_order}
                </span>
                <span className="flex-1 min-w-0">
                  <span className="flex items-center gap-2">
                    <span className="text-sm font-medium text-ink truncate">{level.path_title}</span>
                    <span className="text-xs text-teal shrink-0">{level.path_level}</span>
                  </span>
                  <span className="block h-1.5 w-full max-w-[10rem] bg-line rounded-full overflow-hidden mt-1.5">
                    <span
                      className={`block h-full rounded-full ${status === "done" ? "bg-teal" : "bg-gold"}`}
                      style={{ width: `${Math.max(pct, pct > 0 ? 6 : 0)}%` }}
                    />
                  </span>
                </span>
                <span className="text-xs text-grey tabular shrink-0">
                  {doneCount}/{total}
                </span>
              </button>

              {isOpen && (
                <div className="px-5 pb-4 pt-1 border-t border-line space-y-1 bg-paper/40">
                  {level.lessons.map((l) => (
                    <Link
                      key={l.id}
                      href={`/learn/${l.id}`}
                      className="flex items-center gap-2.5 text-sm py-2 hover:bg-surface rounded-sm px-2.5 -mx-2.5"
                    >
                      <span className={l.completed ? "text-teal" : "text-grey"}>
                        {l.completed ? "✓" : "○"}
                      </span>
                      <span className={l.completed ? "text-ink-soft" : "text-ink font-medium"}>{l.title}</span>
                    </Link>
                  ))}
                  {level.quiz && (
                    <Link
                      href={`/quiz/${level.quiz.id}`}
                      className="flex items-center gap-2.5 text-sm py-2 hover:bg-surface rounded-sm px-2.5 -mx-2.5 text-ink-soft"
                    >
                      <span className="text-gold">▸</span> Quiz: {level.quiz.title}
                    </Link>
                  )}
                  {level.challenge && (
                    <Link
                      href={`/challenge/${level.challenge.id}`}
                      className="flex items-center gap-2.5 text-sm py-2 hover:bg-surface rounded-sm px-2.5 -mx-2.5 text-ink-soft"
                    >
                      <span className="text-gold">▸</span> Challenge: {level.challenge.title}
                    </Link>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
