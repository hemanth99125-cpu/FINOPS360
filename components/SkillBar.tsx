import { skillTier } from "@/lib/types";

const tierColor = {
  strong: "bg-teal",
  developing: "bg-gold",
  weak: "bg-rust",
};

export default function SkillBar({
  name,
  score,
  level,
}: {
  name: string;
  score: number;
  level?: string;
}) {
  const tier = skillTier(score);
  return (
    <div className="mb-3">
      <div className="flex justify-between items-baseline mb-1">
        <span className="text-sm text-ink">{name}</span>
        <span className="text-sm tabular text-ink-soft">
          {score.toFixed(0)}%{level ? ` · ${level}` : ""}
        </span>
      </div>
      <div className="h-1.5 w-full bg-line/60 rounded-sm overflow-hidden">
        <div
          className={`h-full ${tierColor[tier]} rounded-sm`}
          style={{ width: `${Math.max(2, score)}%` }}
        />
      </div>
    </div>
  );
}
