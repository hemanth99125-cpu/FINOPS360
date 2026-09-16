"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useActiveTime } from "@/lib/useActiveTime";
import { trackLessonProgress, flushPendingSync } from "@/lib/activity";
import SyncBadge, { SyncState } from "@/components/SyncBadge";
import CostSimulator from "@/components/CostSimulator";
import TokenCostSimulator from "@/components/TokenCostSimulator";
import type { LessonContent } from "@/lib/types";

export default function LessonClient({
  lesson,
  moduleTitle,
  courseTitle,
  quiz,
  siblingLessons,
  challenge,
}: {
  lesson: { id: string; title: string; content: LessonContent };
  moduleTitle: string;
  courseTitle: string;
  quiz: { id: string; title: string } | null;
  siblingLessons: { id: string; title: string; sequence_order: number }[];
  challenge: { id: string; title: string } | null;
}) {
  const router = useRouter();
  const activeSecondsRef = useActiveTime();
  const [sync, setSync] = useState<SyncState>("saved");
  const [completed, setCompleted] = useState(false);
  const [sectionsRead, setSectionsRead] = useState(1);

  // Mark the lesson "in progress" once, when the page mounts.
  useEffect(() => {
    trackLessonProgress({ lessonId: lesson.id, status: "in_progress", progressPercentage: 10, activeSeconds: 0 });
  }, [lesson.id]);

  // Periodically flush active-learning-seconds so progress survives a closed tab.
  useEffect(() => {
    const interval = setInterval(async () => {
      const seconds = activeSecondsRef.current;
      if (seconds === 0) return;
      setSync("syncing");
      const pct = Math.min(90, Math.round((sectionsRead / lesson.content.sections.length) * 100));
      await trackLessonProgress({
        lessonId: lesson.id,
        status: "in_progress",
        progressPercentage: pct,
        activeSeconds: seconds,
      });
      activeSecondsRef.current = 0;
      setSync(navigator.onLine ? "saved" : "offline");
    }, 20000);
    return () => clearInterval(interval);
  }, [lesson.id, sectionsRead, lesson.content.sections.length, activeSecondsRef]);

  useEffect(() => {
    const onOnline = async () => {
      setSync("syncing");
      await flushPendingSync();
      setSync("saved");
    };
    window.addEventListener("online", onOnline);
    return () => window.removeEventListener("online", onOnline);
  }, []);

  async function handleComplete() {
    setSync("syncing");
    await trackLessonProgress({
      lessonId: lesson.id,
      status: "completed",
      progressPercentage: 100,
      activeSeconds: activeSecondsRef.current,
    });
    activeSecondsRef.current = 0;
    setSync("saved");
    setCompleted(true);
  }

  const currentIndex = siblingLessons.findIndex((l) => l.id === lesson.id);
  const nextLesson = siblingLessons[currentIndex + 1];
  const readPct = Math.round((sectionsRead / lesson.content.sections.length) * 100);

  return (
    <div className="max-w-2xl">
      <div className="flex items-center justify-between mb-1">
        <p className="text-xs text-teal font-medium">
          {courseTitle} · {moduleTitle}
        </p>
        <SyncBadge state={sync} />
      </div>
      <h1 className="font-serif-report text-3xl mb-3 leading-tight">{lesson.title}</h1>

      <div className="h-1.5 w-full bg-line rounded-full overflow-hidden mb-8">
        <div
          className="h-full bg-teal rounded-full"
          style={{ width: `${completed ? 100 : Math.max(6, readPct)}%` }}
        />
      </div>

      <div className="space-y-4">
        {lesson.content.sections.map((s, i) => (
          <div
            key={i}
            className={`card p-5 ${i < sectionsRead ? "" : "opacity-50"}`}
            onMouseEnter={() => setSectionsRead((n) => Math.max(n, i + 1))}
          >
            <h3 className="font-serif-report text-lg mb-2 text-ink">{s.heading}</h3>
            <p className="text-sm leading-7 text-ink-soft">{s.body}</p>
          </div>
        ))}
      </div>

      {lesson.content.simulator && (
        <div className="mt-6">
          <CostSimulator initialInstances={lesson.content.simulator.instances} />
        </div>
      )}

      {lesson.content.tokenSimulator && (
        <div className="mt-6">
          <TokenCostSimulator initialConfig={lesson.content.tokenSimulator.config} />
        </div>
      )}

      {completed && (
        <div className="mt-8 card p-4 bg-teal-soft border-teal/20 flex items-center gap-3">
          <span className="w-8 h-8 rounded-full bg-teal text-surface flex items-center justify-center text-sm shrink-0">✓</span>
          <p className="text-sm text-teal-dark font-medium">Nice work — lesson complete.</p>
        </div>
      )}

      <div className="mt-6 flex items-center justify-between">
        {!completed ? (
          <button onClick={handleComplete} className="btn btn-primary">
            Mark lesson complete
          </button>
        ) : quiz ? (
          <Link href={`/quiz/${quiz.id}`} className="btn btn-secondary">
            Take the module quiz
          </Link>
        ) : nextLesson ? (
          <Link href={`/learn/${nextLesson.id}`} className="text-sm text-teal font-medium hover:text-teal-dark">
            Next lesson →
          </Link>
        ) : (
          <p className="text-sm text-grey">Lesson complete.</p>
        )}

        {completed && challenge && (
          <Link href={`/challenge/${challenge.id}`} className="text-sm text-ink-soft hover:text-ink">
            Skip to practical challenge →
          </Link>
        )}
      </div>
    </div>
  );
}
