import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import LessonClient from "./LessonClient";
import type { LessonContent } from "@/lib/types";

export default async function LessonPage({ params }: { params: Promise<{ lessonId: string }> }) {
  const { lessonId } = await params;
  const supabase = await createClient();

  const { data: lesson } = await supabase
    .from("lessons")
    .select(
      "id, title, description, content, lesson_type, module:modules(id, title, course:courses(id, title), quizzes(id, title), challenges(id, title))"
    )
    .eq("id", lessonId)
    .maybeSingle();

  if (!lesson) notFound();

  const { data: siblingLessons } = await supabase
    .from("lessons")
    .select("id, title, sequence_order")
    .eq("module_id", (lesson.module as any).id)
    .order("sequence_order", { ascending: true });

  const challenges = (lesson.module as any).challenges as { id: string; title: string }[] | null;

  return (
    <LessonClient
      lesson={lesson as unknown as { id: string; title: string; content: LessonContent }}
      moduleTitle={(lesson.module as any).title}
      courseTitle={(lesson.module as any).course.title}
      quiz={(lesson.module as any).quizzes?.[0] ?? null}
      siblingLessons={siblingLessons ?? []}
      challenge={challenges?.[0] ?? null}
    />
  );
}
