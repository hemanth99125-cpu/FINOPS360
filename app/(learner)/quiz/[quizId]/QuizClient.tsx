"use client";

import { useState } from "react";
import Link from "next/link";
import { submitQuizAttempt } from "@/lib/activity";
import type { QuizQuestion } from "@/lib/types";

type GradedQuestion = {
  question_id: string;
  given_answer: string | null;
  correct: boolean;
  correct_answer: string;
  explanation: string;
  skill_category: string | null;
};

export default function QuizClient({
  quiz,
  questions,
  challenge,
}: {
  quiz: { id: string; title: string; description: string | null; passing_score: number };
  questions: QuizQuestion[];
  challenge: { id: string; title: string } | null;
}) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<{ score: number; graded: GradedQuestion[] } | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [startedAt] = useState(() => new Date().toISOString());

  async function handleSubmit() {
    setSubmitting(true);
    const payload = questions.map((q) => ({ question_id: q.id, given_answer: answers[q.id] ?? "" }));
    const res = await submitQuizAttempt({ quizId: quiz.id, answers: payload, startedAt });
    setSubmitting(false);
    if (!res.queued && res.data) {
      setResult(res.data as { score: number; graded: GradedQuestion[] });
    } else {
      alert("You're offline — this attempt is saved and will sync automatically once you're back online.");
    }
  }

  if (result) {
    const passed = result.score >= quiz.passing_score;
    return (
      <div className="max-w-2xl">
        <p className="text-xs text-grey mb-1">{quiz.title}</p>
        <h1 className="font-serif-report text-3xl mb-2">
          Score: <span className="tabular">{result.score}%</span>
        </h1>
        <p className={`text-sm mb-8 ${passed ? "text-teal" : "text-rust"}`}>
          {passed ? "Passed" : "Below passing score"} — {quiz.passing_score}% required
        </p>

        <div className="space-y-6">
          {result.graded.map((g, i) => (
            <div key={g.question_id} className="border-b border-line pb-4">
              <p className="text-sm text-ink mb-1">
                {i + 1}. {questions[i]?.question}
              </p>
              <p className={`text-xs mb-1 ${g.correct ? "text-teal" : "text-rust"}`}>
                {g.correct ? "Correct" : `Incorrect — correct answer: ${g.correct_answer}`}
              </p>
              <p className="text-xs text-ink-soft">{g.explanation}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 flex gap-4">
          <Link href="/dashboard" className="text-sm bg-ink text-paper px-4 py-2 rounded-sm">
            Back to dashboard
          </Link>
          {challenge && (
            <Link href={`/challenge/${challenge.id}`} className="text-sm text-teal">
              Try the practical challenge →
            </Link>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl">
      <p className="text-xs text-grey mb-1">Quiz</p>
      <h1 className="font-serif-report text-3xl mb-2">{quiz.title}</h1>
      {quiz.description && <p className="text-sm text-ink-soft mb-8">{quiz.description}</p>}

      <div className="space-y-8">
        {questions.map((q, i) => (
          <div key={q.id}>
            <p className="text-sm text-ink mb-3">
              {i + 1}. {q.question}
            </p>
            {q.question_type === "true_false" ? (
              <div className="flex gap-2">
                {["true", "false"].map((v) => (
                  <button
                    key={v}
                    onClick={() => setAnswers((a) => ({ ...a, [q.id]: v }))}
                    className={`px-3 py-1.5 text-sm rounded-sm border capitalize ${
                      answers[q.id] === v ? "border-teal bg-teal-soft" : "border-line"
                    }`}
                  >
                    {v}
                  </button>
                ))}
              </div>
            ) : (
              <div className="space-y-2">
                {q.options?.map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setAnswers((a) => ({ ...a, [q.id]: opt.id }))}
                    className={`w-full text-left px-3 py-2 text-sm rounded-sm border ${
                      answers[q.id] === opt.id ? "border-teal bg-teal-soft" : "border-line"
                    }`}
                  >
                    {opt.text}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      <button
        onClick={handleSubmit}
        disabled={submitting || Object.keys(answers).length < questions.length}
        className="mt-8 text-sm bg-ink text-paper px-4 py-2 rounded-sm disabled:opacity-40"
      >
        {submitting ? "Scoring…" : "Submit quiz"}
      </button>
    </div>
  );
}
