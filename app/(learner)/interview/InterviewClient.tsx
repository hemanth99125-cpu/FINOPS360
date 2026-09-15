"use client";

import { useState } from "react";
import Link from "next/link";
import { startInterviewSession, submitInterviewSession, InterviewResponse } from "@/lib/activity";
import type { InterviewQuestion } from "./page";

type PastSession = {
  id: string;
  status: string;
  overall_self_rating: number | null;
  completed_at: string | null;
  started_at: string;
};

type Result = {
  overall_self_rating: number | null;
  strengths: string[];
  weaknesses: string[];
  recommendations: string[];
};

const CATEGORY_LABEL: Record<InterviewQuestion["category"], string> = {
  behavioral: "Behavioral",
  technical: "Technical",
  scenario: "Scenario",
};

export default function InterviewClient({
  questions,
  pastSessions,
}: {
  questions: InterviewQuestion[];
  pastSessions: PastSession[];
}) {
  const [phase, setPhase] = useState<"intro" | "active" | "done">("intro");
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [ratings, setRatings] = useState<Record<string, number | null>>({});
  const [saving, setSaving] = useState<"idle" | "saving" | "saved">("idle");
  const [result, setResult] = useState<Result | null>(null);
  const [starting, setStarting] = useState(false);

  function buildResponses(): InterviewResponse[] {
    return questions.map((q) => ({
      question_id: q.id,
      answer_text: answers[q.id] ?? "",
      self_rating: ratings[q.id] ?? null,
    }));
  }

  async function start() {
    setStarting(true);
    const res = await startInterviewSession(questions.map((q) => q.id));
    setStarting(false);
    if (!res.queued && res.data) {
      setSessionId(res.data as string);
      setPhase("active");
    }
  }

  async function save(final: boolean) {
    if (!sessionId) return;
    setSaving("saving");
    const res = await submitInterviewSession({ sessionId, responses: buildResponses(), final });
    setSaving("saved");
    if (final && !res.queued && res.data) {
      setResult(res.data as Result);
      setPhase("done");
    }
  }

  const allRated = questions.every((q) => ratings[q.id] != null);

  if (phase === "done" && result) {
    return (
      <div className="max-w-2xl">
        <p className="text-xs text-gold mb-1">Mock interview</p>
        <h1 className="font-serif-report text-3xl mb-6">Session complete</h1>
        <p className="font-serif-report text-2xl mb-2 tabular">
          Self-rated average: {result.overall_self_rating ?? "—"} / 5
        </p>
        <p className="text-sm text-ink-soft mb-6">
          This is your own confidence rating per answer, not a graded score — there's no correct
          answer to interview questions to grade against. Treat the breakdown below as a prompt for
          what to practice next, not a verdict.
        </p>
        {result.strengths.length > 0 && (
          <div className="mb-4">
            <p className="text-xs text-grey mb-1">Areas you rated yourself confident in</p>
            <p className="text-sm text-teal">{result.strengths.join(", ")}</p>
          </div>
        )}
        {result.weaknesses.length > 0 && (
          <div className="mb-4">
            <p className="text-xs text-grey mb-1">Areas you rated yourself weaker on</p>
            <p className="text-sm text-rust">{result.weaknesses.join(", ")}</p>
          </div>
        )}
        {result.recommendations.length > 0 && (
          <div className="mb-6">
            <p className="text-xs text-grey mb-1">Worth revisiting</p>
            <ul className="text-sm text-ink-soft list-disc pl-5 space-y-1">
              {result.recommendations.map((r, i) => (
                <li key={i}>{r}</li>
              ))}
            </ul>
          </div>
        )}
        <Link href="/dashboard" className="text-sm bg-ink text-paper px-4 py-2 rounded-sm">
          Back to dashboard
        </Link>
      </div>
    );
  }

  if (phase === "active") {
    return (
      <div className="max-w-2xl">
        <p className="text-xs text-gold mb-1">Mock interview</p>
        <h1 className="font-serif-report text-3xl mb-6">Practice session</h1>
        <div className="space-y-10 mb-10">
          {questions.map((q, i) => (
            <div key={q.id}>
              <p className="text-xs text-grey mb-1">
                {i + 1}. {CATEGORY_LABEL[q.category]}
                {q.skill_category ? ` · ${q.skill_category}` : ""}
              </p>
              <p className="text-sm text-ink mb-3">{q.question}</p>
              <textarea
                value={answers[q.id] ?? ""}
                onChange={(e) => setAnswers((a) => ({ ...a, [q.id]: e.target.value }))}
                rows={4}
                className="w-full border border-line rounded-sm p-3 text-sm bg-white mb-3"
                placeholder="Answer as you would out loud — write it out here…"
              />
              <p className="text-xs text-grey mb-1">How confident are you in that answer?</p>
              <div className="flex gap-2">
                {[1, 2, 3, 4, 5].map((n) => (
                  <button
                    key={n}
                    onClick={() => setRatings((r) => ({ ...r, [q.id]: n }))}
                    className={`w-8 h-8 text-sm rounded-sm border border-line ${
                      ratings[q.id] === n ? "bg-ink text-paper" : "hover:bg-black/[0.03]"
                    }`}
                  >
                    {n}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={() => save(false)}
            disabled={saving === "saving"}
            className="text-sm border border-line px-4 py-2 rounded-sm hover:bg-black/[0.03] disabled:opacity-40"
          >
            {saving === "saving" ? "Saving…" : "Save draft"}
          </button>
          <button
            onClick={() => save(true)}
            disabled={saving === "saving" || !allRated}
            title={!allRated ? "Rate every answer before submitting" : undefined}
            className="text-sm bg-ink text-paper px-4 py-2 rounded-sm hover:bg-ink/90 disabled:opacity-40"
          >
            Finish session
          </button>
          {saving === "saved" && <span className="text-xs text-teal">Saved</span>}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl">
      <p className="text-xs text-gold mb-1">Mock interview</p>
      <h1 className="font-serif-report text-3xl mb-3">Practice for the real thing</h1>
      <p className="text-sm text-ink-soft leading-relaxed mb-8">
        A {questions.length}-question mix of behavioral, technical, and scenario questions pulled
        from a bank covering the whole curriculum. Write out a real answer to each, then rate your
        own confidence — there's no correct-answer key, so this is entirely self-assessed practice,
        not a graded exercise.
      </p>
      <button
        onClick={start}
        disabled={starting || questions.length === 0}
        className="text-sm bg-ink text-paper px-4 py-2 rounded-sm hover:bg-ink/90 disabled:opacity-40 mb-10"
      >
        {starting ? "Starting…" : "Start mock interview"}
      </button>

      {pastSessions.length > 0 && (
        <div className="report-divider pt-6">
          <p className="text-xs text-grey mb-3">Past sessions</p>
          <div className="space-y-2">
            {pastSessions.map((s) => (
              <p key={s.id} className="text-sm text-ink-soft flex items-center justify-between">
                <span>{new Date(s.started_at).toLocaleDateString()}</span>
                <span>
                  {s.status === "completed"
                    ? `Rated ${s.overall_self_rating ?? "—"} / 5`
                    : "In progress"}
                </span>
              </p>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
