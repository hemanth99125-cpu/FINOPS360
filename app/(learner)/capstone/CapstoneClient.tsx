"use client";

import { useState } from "react";
import Link from "next/link";
import { submitCapstoneProject } from "@/lib/activity";

type Project = {
  id: string;
  title: string;
  description: string | null;
  scenario: string;
  requirements: string[];
  evaluation_criteria: string[];
};

type Existing = {
  status: string;
  submission_data: { answers?: Record<string, string>; checked_criteria?: string[] };
  score: number | null;
  completed_at: string | null;
} | null;

export default function CapstoneClient({ project, existing }: { project: Project; existing: Existing }) {
  const [answers, setAnswers] = useState<Record<string, string>>(existing?.submission_data?.answers ?? {});
  const [checked, setChecked] = useState<string[]>(existing?.submission_data?.checked_criteria ?? []);
  const [saving, setSaving] = useState<"idle" | "saving" | "saved">("idle");
  const [submitted, setSubmitted] = useState(existing?.status === "completed");
  const [result, setResult] = useState<{ score: number | null } | null>(
    existing?.status === "completed" ? { score: existing.score } : null
  );

  function toggleCriterion(c: string) {
    setChecked((prev) => (prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]));
  }

  async function save(final: boolean) {
    setSaving("saving");
    const res = await submitCapstoneProject({
      projectId: project.id,
      submissionData: { answers, checked_criteria: checked },
      checkedCriteria: checked,
      final,
    });
    setSaving("saved");
    if (final) {
      setSubmitted(true);
      if (!res.queued && res.data) {
        setResult({ score: (res.data as { self_assessed_completeness: number | null }).self_assessed_completeness });
      }
    }
  }

  if (submitted) {
    return (
      <div className="max-w-2xl">
        <p className="text-xs text-gold mb-1">Capstone project</p>
        <h1 className="font-serif-report text-3xl mb-6">{project.title}</h1>
        <div className="border-t border-line pt-6">
          <p className="font-serif-report text-2xl mb-2 tabular">
            Self-assessed completeness: {result?.score ?? "—"}%
          </p>
          <p className="text-sm text-ink-soft mb-6">
            This is a self-assessment against the published evaluation criteria — not an algorithmic
            grade like your quizzes and challenges. Treat it as a checklist for your own portfolio
            deliverable, and revisit any criterion you're not confident you actually addressed.
          </p>
          <div className="space-y-2 mb-6">
            {project.evaluation_criteria.map((c) => (
              <p key={c} className="text-sm flex items-start gap-2">
                <span className={checked.includes(c) ? "text-teal" : "text-rust"}>
                  {checked.includes(c) ? "✓" : "○"}
                </span>
                {c}
              </p>
            ))}
          </div>
          <button
            onClick={() => setSubmitted(false)}
            className="text-sm text-ink-soft hover:text-ink mr-4"
          >
            Keep editing
          </button>
          <Link href="/dashboard" className="text-sm bg-ink text-paper px-4 py-2 rounded-sm">
            Back to dashboard
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl">
      <p className="text-xs text-gold mb-1">Capstone project</p>
      <h1 className="font-serif-report text-3xl mb-3">{project.title}</h1>
      {project.description && <p className="text-sm text-ink-soft mb-4">{project.description}</p>}
      <p className="text-sm text-ink leading-relaxed mb-8">{project.scenario}</p>

      <div className="space-y-8 mb-10">
        {project.requirements.map((req, i) => (
          <div key={i}>
            <label className="block text-sm text-ink mb-2">
              {i + 1}. {req}
            </label>
            <textarea
              value={answers[String(i)] ?? ""}
              onChange={(e) => setAnswers((a) => ({ ...a, [String(i)]: e.target.value }))}
              rows={5}
              className="w-full border border-line rounded-sm p-3 text-sm bg-white"
              placeholder="Write your response here…"
            />
          </div>
        ))}
      </div>

      <div className="report-divider pt-6 mb-8">
        <p className="text-xs text-grey mb-3">
          Self-check: which evaluation criteria does your write-up actually satisfy?
        </p>
        <div className="space-y-2">
          {project.evaluation_criteria.map((c) => (
            <label key={c} className="flex items-start gap-2 text-sm cursor-pointer">
              <input
                type="checkbox"
                checked={checked.includes(c)}
                onChange={() => toggleCriterion(c)}
                className="mt-0.5"
              />
              {c}
            </label>
          ))}
        </div>
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
          disabled={saving === "saving"}
          className="text-sm bg-ink text-paper px-4 py-2 rounded-sm hover:bg-ink/90 disabled:opacity-40"
        >
          Submit capstone
        </button>
        {saving === "saved" && <span className="text-xs text-teal">Saved</span>}
      </div>
    </div>
  );
}
