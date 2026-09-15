-- ============================================================================
-- The capstone project: a single comprehensive deliverable that draws on
-- every skill built across Levels 2-9 (and beyond, as more levels are added).
-- Unlike quizzes/challenges, there's no hidden correct answer — the learner
-- writes a real deliverable and self-assesses it against the published
-- evaluation_criteria via submit_capstone_project() (migration 0006).
-- ============================================================================
insert into capstone_projects (title, description, scenario, requirements, evaluation_criteria)
values (
  'Build a Cost Optimization & Governance Plan',
  'The final, comprehensive deliverable for this program: a real-shaped consulting engagement, not a quiz.',
  'You have been brought in as a FinOps consultant for a mid-size company (400 engineers) that has grown its cloud spend from $200,000/month to $850,000/month over 18 months with no formal FinOps practice in place. Tagging is inconsistent, there is no budget, no forecast, and leadership has no visibility into which teams or products drive the spend. You have two weeks to produce a plan the CFO and VP of Engineering can both act on.',
  array[
    'A one-page executive summary written for a CFO who has 5 minutes: current state, the single biggest risk, and your top 3 recommendations.',
    'A cost allocation plan: propose the mandatory tag set, how untagged/shared cost will be handled, and how allocated data will be reported to teams (showback, chargeback, or a hybrid — and why).',
    'A trend and driver analysis: using the scenario numbers given, identify the most likely categories driving the 4x spend growth and justify your reasoning.',
    'A budgeting and forecasting approach: propose how next quarter''s budget should be set, and what reforecasting trigger/threshold you would use.',
    'An optimization roadmap: at least 3 concrete, prioritized recommendations (e.g., rightsizing, commitment discounts, storage tiering), each with an estimated impact and what data you would need to confirm it.',
    'A governance plan: what ongoing cadence, ownership, and policies (e.g., tagging enforcement) would keep this from recurring.'
  ],
  array[
    'Executive summary is genuinely written for a non-technical CFO audience, not copy-pasted technical detail.',
    'Allocation plan chooses and justifies showback vs. chargeback vs. hybrid, referencing the company''s current maturity.',
    'Driver analysis references specific, plausible cost categories rather than a vague "cloud costs went up".',
    'Budget/forecast approach includes both a starting number methodology and a concrete reforecast trigger.',
    'At least 3 optimization recommendations are prioritized, not just listed, with a stated estimated impact.',
    'Governance plan proposes a specific ongoing cadence and named ownership, not just "review costs more".'
  ]
);
