export type LessonContent = {
  sections: { heading: string; body: string }[];
  simulator?: { instances: SimInstance[] };
  tokenSimulator?: { config: TokenSimConfig };
};

export type TokenSimConfig = {
  modelTier: "small" | "medium" | "frontier";
  monthlyRequestsThousands: number;
  avgInputTokens: number;
  avgOutputTokens: number;
  cachingEnabled: boolean;
  cacheHitRatePct: number;
};

// Illustrative per-1M-token rates for teaching purposes, not a live provider
// price list — real rates vary by provider and change over time.
export const TOKEN_RATES: Record<TokenSimConfig["modelTier"], { input: number; output: number }> = {
  small: { input: 0.15, output: 0.6 },
  medium: { input: 1.0, output: 4.0 },
  frontier: { input: 3.0, output: 15.0 },
};

// Cached input tokens are billed at a steep discount versus a fresh read —
// illustrative of how provider prompt-caching discounts work in practice.
export const CACHE_DISCOUNT_MULTIPLIER = 0.1;

export function tokenMonthlyCost(cfg: TokenSimConfig): number {
  const rate = TOKEN_RATES[cfg.modelTier];
  const requests = cfg.monthlyRequestsThousands * 1000;
  const totalInputTokens = requests * cfg.avgInputTokens;
  const totalOutputTokens = requests * cfg.avgOutputTokens;

  let inputCost: number;
  if (cfg.cachingEnabled) {
    const cachedTokens = totalInputTokens * (cfg.cacheHitRatePct / 100);
    const freshTokens = totalInputTokens - cachedTokens;
    inputCost =
      (freshTokens / 1_000_000) * rate.input +
      (cachedTokens / 1_000_000) * rate.input * CACHE_DISCOUNT_MULTIPLIER;
  } else {
    inputCost = (totalInputTokens / 1_000_000) * rate.input;
  }

  const outputCost = (totalOutputTokens / 1_000_000) * rate.output;
  return inputCost + outputCost;
}

export type SimInstance = {
  id: string;
  name: string;
  size: "small" | "medium" | "large" | "xlarge";
  quantity: number;
  avg_utilization_pct: number;
  commitment: "on_demand" | "reserved_1yr" | "reserved_3yr";
};

export const INSTANCE_HOURLY_RATES: Record<SimInstance["size"], number> = {
  small: 0.05,
  medium: 0.192,
  large: 0.384,
  xlarge: 0.768,
};

export const COMMITMENT_DISCOUNTS: Record<SimInstance["commitment"], number> = {
  on_demand: 0,
  reserved_1yr: 0.32,
  reserved_3yr: 0.54,
};

export const HOURS_PER_MONTH = 730;

export function monthlyCost(inst: Pick<SimInstance, "size" | "quantity" | "commitment">): number {
  const rate = INSTANCE_HOURLY_RATES[inst.size] * (1 - COMMITMENT_DISCOUNTS[inst.commitment]);
  return rate * HOURS_PER_MONTH * inst.quantity;
}

export function suggestedSize(current: SimInstance["size"], utilizationPct: number): SimInstance["size"] {
  const order: SimInstance["size"][] = ["small", "medium", "large", "xlarge"];
  const idx = order.indexOf(current);
  // Rule of thumb: consistently low utilization means the instance is bigger
  // than it needs to be. Every ~25 points of headroom below 50% supports
  // dropping one size tier, down to a floor of "small".
  if (utilizationPct >= 50 || idx === 0) return current;
  const stepsDown = utilizationPct < 15 ? 2 : 1;
  return order[Math.max(0, idx - stepsDown)];
}

export type QuizOption = { id: string; text: string };

/** What the learner sees before answering — correct_answer/explanation are
 * withheld until the server-side submit_quiz_attempt RPC grades the attempt. */
export type QuizQuestion = {
  id: string;
  question: string;
  question_type: string;
  options: QuizOption[] | null;
  skill_category: string | null;
};

export type ChallengeCriterion = {
  key: string;
  label: string;
  expected: string;
  weight: number;
  skill: string;
  options?: string[];
};

export type Profile = {
  id: string;
  full_name: string | null;
  email: string | null;
  role: "learner" | "tracker";
};

export const READINESS_LEVELS = [
  { min: 86, label: "Industry Ready" },
  { min: 71, label: "FinOps Practitioner" },
  { min: 51, label: "Intermediate FinOps Learner" },
  { min: 31, label: "Foundation Learner" },
  { min: 0, label: "Beginner" },
] as const;

export function readinessLevel(score: number): string {
  return READINESS_LEVELS.find((l) => score >= l.min)?.label ?? "Beginner";
}

export function skillTier(score: number): "strong" | "developing" | "weak" {
  if (score >= 75) return "strong";
  if (score >= 50) return "developing";
  return "weak";
}
