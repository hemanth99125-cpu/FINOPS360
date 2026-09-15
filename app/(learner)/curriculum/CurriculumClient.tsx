"use client";

import { useState } from "react";
import Link from "next/link";
import type { CurriculumLevel } from "./page";

export default function CurriculumClient({ levels }: { levels: CurriculumLevel[] }) {
  const [openId, setOpenId] = useState<string | null>(levels[0]?.path_id ?? null);

  return (
    <div className="max-w-2xl">
      <p className="text-xs text-gold mb-1">Curriculum</p>
      <h1 className="font-serif-report text-3xl mb-2">All 21 levels</h1>
      <p className="text-sm text-ink-soft mb-8">
        Jump to any level below — your progress carries over whether you go in order or not.
      </p>

      <div className="space-y-2">
        {levels.map((level) => {
          const doneCount = level.lessons.filter((l) => l.completed).length;
          const isOpen = openId === level.path_id;
          return (
            <div key={level.path_id} className="border border-line rounded-sm bg-white">
              <button
                onClick={() => setOpenId(isOpen ? null : level.path_id)}
                className="w-full flex items-center justify-between px-4 py-3 text-left"
              >
                <span className="flex items-center gap-3">
                  <span className="text-xs text-grey tabular w-6">{level.sequence_order}</span>
                  <span className="text-sm text-ink">{level.path_title}</span>
                  <span className="text-xs text-teal">{level.path_level}</span>
                </span>
                <span className="text-xs text-grey tabular">
                  {doneCount}/{level.lessons.length} lessons
                </span>
              </button>

              {isOpen && (
                <div className="px-4 pb-4 pt-1 border-t border-line space-y-1">
                  {level.lessons.map((l) => (
                    <Link
                      key={l.id}
                      href={`/learn/${l.id}`}
                      className="flex items-center gap-2 text-sm py-1.5 hover:bg-black/[0.03] rounded-sm px-2 -mx-2"
                    >
                      <span className={l.completed ? "text-teal" : "text-grey"}>
                        {l.completed ? "✓" : "○"}
                      </span>
                      <span className={l.completed ? "text-ink-soft" : "text-ink"}>{l.title}</span>
                    </Link>
                  ))}
                  {level.quiz && (
                    <Link
                      href={`/quiz/${level.quiz.id}`}
                      className="flex items-center gap-2 text-sm py-1.5 hover:bg-black/[0.03] rounded-sm px-2 -mx-2 text-ink-soft"
                    >
                      <span className="text-grey">▸</span> Quiz: {level.quiz.title}
                    </Link>
                  )}
                  {level.challenge && (
                    <Link
                      href={`/challenge/${level.challenge.id}`}
                      className="flex items-center gap-2 text-sm py-1.5 hover:bg-black/[0.03] rounded-sm px-2 -mx-2 text-ink-soft"
                    >
                      <span className="text-grey">▸</span> Challenge: {level.challenge.title}
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
