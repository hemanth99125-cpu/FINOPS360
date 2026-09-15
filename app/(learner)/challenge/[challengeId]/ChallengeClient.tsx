"use client";

import { useState } from "react";
import Link from "next/link";
import { submitChallengeAttempt } from "@/lib/activity";
import type { ChallengeCriterion } from "@/lib/types";

type LineItem = { service: string; last_month: number; this_month: number };

export default function ChallengeClient({
  challenge,
}: {
  challenge: {
    id: string;
    title: string;
    description: string | null;
    scenario: string;
    scenario_data: { line_items: LineItem[] };
    instructions: string;
    scoring_rules: { criteria: ChallengeCriterion[] };
  };
}) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [result, setResult] = useState<{ score: number; feedback: string } | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [startedAt] = useState(() => new Date().toISOString());
  const criteria = challenge.scoring_rules.criteria;

  async function handleSubmit() {
    setSubmitting(true);
    const res = await submitChallengeAttempt({
      challengeId: challenge.id,
      answers,
      decisions: answers,
      startedAt,
    });
    setSubmitting(false);
    if (!res.queued && res.data) {
      setResult(res.data as { score: number; feedback: string });
    } else {
      alert("You're offline — this attempt is saved and will sync automatically once you're back online.");
    }
  }

  const total = challenge.scenario_data.line_items.reduce((a, li) => a + li.this_month, 0);
  const totalLast = challenge.scenario_data.line_items.reduce((a, li) => a + li.last_month, 0);

  return (
    <div className="max-w-2xl">
      <p className="text-xs text-gold mb-1">Practical challenge</p>
      <h1 className="font-serif-report text-3xl mb-3">{challenge.title}</h1>
      <p className="text-sm text-ink-soft mb-6">{challenge.scenario}</p>

      <table className="w-full text-sm mb-8">
        <thead>
          <tr className="text-left text-xs text-grey report-divider">
            <th className="py-2 font-normal">Service</th>
            <th className="py-2 font-normal text-right">Last month</th>
            <th className="py-2 font-normal text-right">This month</th>
            <th className="py-2 font-normal text-right">Change</th>
          </tr>
        </thead>
        <tbody>
          {challenge.scenario_data.line_items.map((li) => (
            <tr key={li.service} className="border-b border-line/60">
              <td className="py-2">{li.service}</td>
              <td className="py-2 text-right tabular">${li.last_month.toLocaleString()}</td>
              <td className="py-2 text-right tabular">${li.this_month.toLocaleString()}</td>
              <td className="py-2 text-right tabular text-rust">
                +${(li.this_month - li.last_month).toLocaleString()}
              </td>
            </tr>
          ))}
          <tr className="font-medium">
            <td className="py-2">Total</td>
            <td className="py-2 text-right tabular">${totalLast.toLocaleString()}</td>
            <td className="py-2 text-right tabular">${total.toLocaleString()}</td>
            <td className="py-2 text-right tabular text-rust">
              +${(total - totalLast).toLocaleString()}
            </td>
          </tr>
        </tbody>
      </table>

      <p className="text-sm text-ink mb-6">{challenge.instructions}</p>

      {result ? (
        <div className="border-t border-line pt-6">
          <p className="font-serif-report text-2xl mb-2 tabular">Score: {result.score}%</p>
          <p className="text-sm text-ink-soft whitespace-pre-line mb-6">{result.feedback}</p>
          <Link href="/dashboard" className="text-sm bg-ink text-paper px-4 py-2 rounded-sm">
            Back to dashboard
          </Link>
        </div>
      ) : (
        <div className="space-y-6">
          {criteria.map((c) => (
            <div key={c.key}>
              <label className="block text-sm text-ink mb-2">{c.label}</label>
              <div className="flex flex-wrap gap-2">
                {c.options?.map((opt) => (
                  <button
                    key={opt}
                    onClick={() => setAnswers((a) => ({ ...a, [c.key]: opt }))}
                    className={`px-3 py-1.5 text-sm rounded-sm border ${
                      answers[c.key] === opt ? "border-teal bg-teal-soft" : "border-line"
                    }`}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            </div>
          ))}
          <button
            onClick={handleSubmit}
            disabled={submitting || Object.keys(answers).length < criteria.length}
            className="text-sm bg-ink text-paper px-4 py-2 rounded-sm disabled:opacity-40"
          >
            {submitting ? "Scoring…" : "Submit recommendation"}
          </button>
        </div>
      )}
    </div>
  );
}
