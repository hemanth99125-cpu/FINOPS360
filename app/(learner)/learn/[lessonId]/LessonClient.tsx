"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useActiveTime } from "@/lib/useActiveTime";
import { trackLessonProgress, flushPendingSync } from "@/lib/activity";
import SyncBadge, { SyncState } from "@/components/SyncBadge";
import CostSimulator from "@/components/CostSimulator";
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

  return (
    <div className="max-w-2xl">
      <div className="flex items-center justify-between mb-1">
        <p className="text-xs text-teal">
          {courseTitle} · {moduleTitle}
        </p>
        <SyncBadge state={sync} />
      </div>
      <h1 className="font-serif-report text-3xl mb-8 leading-tight">{lesson.title}</h1>

      <div className="space-y-8">
        {lesson.content.sections.map((s, i) => (
          <div
            key={i}
            className={i < sectionsRead ? "" : "opacity-40"}
            onMouseEnter={() => setSectionsRead((n) => Math.max(n, i + 1))}
          >
            <h3 className="font-serif-report text-lg mb-2">{s.heading}</h3>
            <p className="text-sm leading-relaxed text-ink-soft">{s.body}</p>
          </div>
        ))}
      </div>

      {lesson.content.simulator && (
        <div className="mt-8">
          <CostSimulator initialInstances={lesson.content.simulator.instances} />
        </div>
      )}

      <div className="report-divider mt-10 pt-6 flex items-center justify-between">
        {!completed ? (
          <button
            onClick={handleComplete}
            className="text-sm bg-ink text-paper px-4 py-2 rounded-sm hover:bg-ink/90"
          >
            Mark lesson complete
          </button>
        ) : quiz ? (
          <Link
            href={`/quiz/${quiz.id}`}
            className="text-sm bg-teal text-paper px-4 py-2 rounded-sm hover:bg-teal/90"
          >
            Take the module quiz →
          </Link>
        ) : nextLesson ? (
          <Link href={`/learn/${nextLesson.id}`} className="text-sm text-teal">
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
