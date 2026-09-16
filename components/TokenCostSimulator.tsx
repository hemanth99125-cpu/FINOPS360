"use client";

import { useMemo, useState } from "react";
import { TOKEN_RATES, tokenMonthlyCost, type TokenSimConfig } from "@/lib/types";

const TIER_LABELS: Record<TokenSimConfig["modelTier"], string> = {
  small: "Small / fast model",
  medium: "Mid-size model",
  frontier: "Frontier model",
};

function currency(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

function tokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(0)}K`;
  return `${n}`;
}

export default function TokenCostSimulator({ initialConfig }: { initialConfig: TokenSimConfig }) {
  const [cfg, setCfg] = useState<TokenSimConfig>(initialConfig);

  const baseline = useMemo(() => tokenMonthlyCost(initialConfig), [initialConfig]);
  const current = useMemo(() => tokenMonthlyCost(cfg), [cfg]);
  const savings = baseline - current;
  const savingsPct = baseline > 0 ? (savings / baseline) * 100 : 0;

  const requests = cfg.monthlyRequestsThousands * 1000;
  const totalInputTokens = requests * cfg.avgInputTokens;
  const totalOutputTokens = requests * cfg.avgOutputTokens;

  function update(patch: Partial<TokenSimConfig>) {
    setCfg((prev) => ({ ...prev, ...patch }));
  }

  function reset() {
    setCfg(initialConfig);
  }

  return (
    <div className="card overflow-hidden">
      <div className="p-5 border-b border-line flex items-center justify-between">
        <div>
          <p className="text-xs text-teal font-medium mb-1">Interactive</p>
          <h3 className="font-serif-report text-lg">Token Cost Simulator</h3>
        </div>
        <button onClick={reset} className="text-xs text-ink-soft hover:text-ink px-3 py-1.5">
          Reset
        </button>
      </div>

      <div className="p-5 grid grid-cols-2 gap-x-8 gap-y-5">
        <div>
          <label className="block text-xs text-grey mb-1.5">Model tier</label>
          <select
            value={cfg.modelTier}
            onChange={(e) => update({ modelTier: e.target.value as TokenSimConfig["modelTier"] })}
            className="w-full border border-line rounded-sm px-3 py-2 bg-paper text-sm"
          >
            {(Object.keys(TIER_LABELS) as TokenSimConfig["modelTier"][]).map((t) => (
              <option key={t} value={t}>
                {TIER_LABELS[t]} (${TOKEN_RATES[t].input}/${TOKEN_RATES[t].output} per 1M in/out)
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-xs text-grey mb-1.5">
            Monthly requests: <span className="tabular text-ink font-medium">{tokens(requests)}</span>
          </label>
          <input
            type="range"
            min={10}
            max={5000}
            step={10}
            value={cfg.monthlyRequestsThousands}
            onChange={(e) => update({ monthlyRequestsThousands: Number(e.target.value) })}
            className="w-full accent-teal"
          />
        </div>

        <div>
          <label className="block text-xs text-grey mb-1.5">
            Avg. input tokens / request:{" "}
            <span className="tabular text-ink font-medium">{tokens(cfg.avgInputTokens)}</span>
          </label>
          <input
            type="range"
            min={100}
            max={20000}
            step={100}
            value={cfg.avgInputTokens}
            onChange={(e) => update({ avgInputTokens: Number(e.target.value) })}
            className="w-full accent-teal"
          />
        </div>

        <div>
          <label className="block text-xs text-grey mb-1.5">
            Avg. output tokens / request:{" "}
            <span className="tabular text-ink font-medium">{tokens(cfg.avgOutputTokens)}</span>
          </label>
          <input
            type="range"
            min={50}
            max={4000}
            step={50}
            value={cfg.avgOutputTokens}
            onChange={(e) => update({ avgOutputTokens: Number(e.target.value) })}
            className="w-full accent-teal"
          />
        </div>

        <div className="col-span-2 flex items-center gap-4 bg-paper rounded-sm p-3">
          <label className="flex items-center gap-2 text-sm font-medium text-ink cursor-pointer">
            <input
              type="checkbox"
              checked={cfg.cachingEnabled}
              onChange={(e) => update({ cachingEnabled: e.target.checked })}
              className="accent-teal w-4 h-4"
            />
            Enable prompt caching
          </label>
          {cfg.cachingEnabled && (
            <div className="flex items-center gap-2 flex-1">
              <span className="text-xs text-grey shrink-0">Cache hit rate</span>
              <input
                type="range"
                min={0}
                max={95}
                value={cfg.cacheHitRatePct}
                onChange={(e) => update({ cacheHitRatePct: Number(e.target.value) })}
                className="w-full accent-teal"
              />
              <span className="text-xs tabular text-ink font-medium w-10 text-right">
                {cfg.cacheHitRatePct}%
              </span>
            </div>
          )}
        </div>
      </div>

      <div className="px-5 pb-2 flex gap-6 text-xs text-ink-soft tabular">
        <span>Total input: {tokens(totalInputTokens)} tokens/mo</span>
        <span>Total output: {tokens(totalOutputTokens)} tokens/mo</span>
      </div>

      <div className="p-5 grid grid-cols-3 gap-6 border-t border-line mt-3">
        <div>
          <p className="text-xs text-grey mb-1">Baseline monthly cost</p>
          <p className="text-xl font-serif-report tabular">{currency(baseline)}</p>
        </div>
        <div>
          <p className="text-xs text-grey mb-1">Simulated monthly cost</p>
          <p className="text-xl font-serif-report tabular">{currency(current)}</p>
        </div>
        <div>
          <p className="text-xs text-grey mb-1">Monthly savings</p>
          <p
            className={`text-xl font-serif-report tabular ${
              savings > 0 ? "text-teal" : savings < 0 ? "text-rust" : ""
            }`}
          >
            {currency(savings)} {baseline > 0 && `(${savingsPct.toFixed(0)}%)`}
          </p>
        </div>
      </div>
      <p className="px-5 pb-5 text-xs text-ink-soft">
        Rates are simplified illustrative figures for this exercise, not a live provider price list.
        The point of this tool is the shape of the tradeoff: model tier, output length, and caching
        are usually the three biggest levers on an AI token bill.
      </p>
    </div>
  );
}
