"use client";

import { useMemo, useState } from "react";
import {
  COMMITMENT_DISCOUNTS,
  INSTANCE_HOURLY_RATES,
  monthlyCost,
  suggestedSize,
  type SimInstance,
} from "@/lib/types";

const SIZE_LABELS: Record<SimInstance["size"], string> = {
  small: "Small (2 vCPU)",
  medium: "Medium (4 vCPU)",
  large: "Large (8 vCPU)",
  xlarge: "X-Large (16 vCPU)",
};

const COMMITMENT_LABELS: Record<SimInstance["commitment"], string> = {
  on_demand: "On-Demand",
  reserved_1yr: "Reserved (1yr)",
  reserved_3yr: "Reserved (3yr)",
};

function currency(n: number): string {
  return n.toLocaleString("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
}

export default function CostSimulator({ initialInstances }: { initialInstances: SimInstance[] }) {
  const [instances, setInstances] = useState<SimInstance[]>(initialInstances);

  const baseline = useMemo(
    () => initialInstances.reduce((sum, i) => sum + monthlyCost(i), 0),
    [initialInstances]
  );
  const current = useMemo(() => instances.reduce((sum, i) => sum + monthlyCost(i), 0), [instances]);
  const savings = baseline - current;
  const savingsPct = baseline > 0 ? (savings / baseline) * 100 : 0;

  function update(id: string, patch: Partial<SimInstance>) {
    setInstances((prev) => prev.map((i) => (i.id === id ? { ...i, ...patch } : i)));
  }

  function applyAllSuggestions() {
    setInstances((prev) =>
      prev.map((i) => ({
        ...i,
        size: suggestedSize(i.size, i.avg_utilization_pct),
      }))
    );
  }

  function reset() {
    setInstances(initialInstances);
  }

  return (
    <div className="border border-line rounded-sm bg-white">
      <div className="p-5 border-b border-line flex items-center justify-between">
        <div>
          <p className="text-xs text-teal mb-1">Interactive</p>
          <h3 className="font-serif-report text-lg">Cloud Cost Simulator</h3>
        </div>
        <div className="flex gap-2">
          <button
            onClick={applyAllSuggestions}
            className="text-xs bg-teal text-paper px-3 py-1.5 rounded-sm hover:bg-teal/90"
          >
            Apply rightsizing suggestions
          </button>
          <button onClick={reset} className="text-xs text-ink-soft hover:text-ink px-3 py-1.5">
            Reset
          </button>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs text-grey border-b border-line">
              <th className="p-3 font-normal">Fleet</th>
              <th className="p-3 font-normal">Size</th>
              <th className="p-3 font-normal">Qty</th>
              <th className="p-3 font-normal">Avg. utilization</th>
              <th className="p-3 font-normal">Commitment</th>
              <th className="p-3 font-normal text-right">Monthly cost</th>
            </tr>
          </thead>
          <tbody>
            {instances.map((inst) => {
              const suggestion = suggestedSize(inst.size, inst.avg_utilization_pct);
              const isOversized = suggestion !== inst.size;
              return (
                <tr key={inst.id} className="border-b border-line/60 align-middle">
                  <td className="p-3">
                    <p className="font-medium">{inst.name}</p>
                    {isOversized && (
                      <p className="text-xs text-rust mt-0.5">
                        Low utilization — consider {SIZE_LABELS[suggestion]}
                      </p>
                    )}
                  </td>
                  <td className="p-3">
                    <select
                      value={inst.size}
                      onChange={(e) => update(inst.id, { size: e.target.value as SimInstance["size"] })}
                      className="border border-line rounded-sm px-2 py-1 bg-paper text-sm"
                    >
                      {(Object.keys(SIZE_LABELS) as SimInstance["size"][]).map((s) => (
                        <option key={s} value={s}>
                          {SIZE_LABELS[s]}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td className="p-3">
                    <input
                      type="number"
                      min={0}
                      value={inst.quantity}
                      onChange={(e) => update(inst.id, { quantity: Math.max(0, Number(e.target.value)) })}
                      className="w-16 border border-line rounded-sm px-2 py-1 bg-paper text-sm tabular"
                    />
                  </td>
                  <td className="p-3 tabular">{inst.avg_utilization_pct}%</td>
                  <td className="p-3">
                    <select
                      value={inst.commitment}
                      onChange={(e) =>
                        update(inst.id, { commitment: e.target.value as SimInstance["commitment"] })
                      }
                      className="border border-line rounded-sm px-2 py-1 bg-paper text-sm"
                    >
                      {(Object.keys(COMMITMENT_LABELS) as SimInstance["commitment"][]).map((c) => (
                        <option key={c} value={c}>
                          {COMMITMENT_LABELS[c]}
                          {COMMITMENT_DISCOUNTS[c] > 0 ? ` (-${Math.round(COMMITMENT_DISCOUNTS[c] * 100)}%)` : ""}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td className="p-3 text-right tabular">{currency(monthlyCost(inst))}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="p-5 grid grid-cols-3 gap-6">
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
          <p className={`text-xl font-serif-report tabular ${savings > 0 ? "text-teal" : savings < 0 ? "text-rust" : ""}`}>
            {currency(savings)} {baseline > 0 && `(${savingsPct.toFixed(0)}%)`}
          </p>
        </div>
      </div>
      <p className="px-5 pb-5 text-xs text-ink-soft">
        Rates are simplified illustrative figures for this exercise, not a live provider price list. The
        point of this tool is the shape of the tradeoff: size and commitment level are usually the two
        biggest levers on a compute bill.
      </p>
    </div>
  );
}
