# FinOps Career Accelerator

A private, single-learner career-development platform for building real FinOps
capability — not a course-completion tracker. Two roles: **learner** (does the
work) and **tracker** (private read-only dashboard on real activity/skill/
readiness data).

This build is **fully complete**: full schema, RLS, auth for both roles, a
real scoring/readiness engine running in Postgres, an interactive Cloud Cost
Simulator, all 21 curriculum levels wired end-to-end, a capstone project, and
a mock interview system. Every level has the same shape — 3 lessons -> a
quiz -> a practical challenge:

1. Introduction to FinOps
2. Cloud Computing Foundations
3. FinOps Fundamentals
4. Cloud Billing
5. Cost Allocation & Tagging
6. Showback & Chargeback
7. Cost Analysis & Anomaly Detection
8. Budgeting
9. Forecasting (includes the interactive Cloud Cost Simulator)
10. Cost Optimization Strategies (rightsizing, storage, network)
11. Commitment Discounts Deep Dive
12. Multi-Cloud FinOps
13. Unit Economics & Cloud ROI
14. FinOps Governance & Policy
15. FinOps KPIs & Scorecards
16. Data Analysis for FinOps (Excel/CUR foundations)
17. SQL for Cost Analysis
18. Executive Reporting & Stakeholder Communication
19. Container & Kubernetes Cost Management
20. Negotiating Enterprise Agreements
21. Building a Continuous FinOps Operating Model

Levels 1 and 10-21 have no original-spec document to draw exact titles
from — see "Known scope notes" below for how those topics were chosen.

## Stack

- Next.js 14 (App Router) + TypeScript + Tailwind
- Supabase (Postgres + Auth + RLS) — no separate backend server
- Deploy target: Vercel

No paid APIs, no AWS/Azure/GCP accounts, no payment/subscription code — all
scoring and grading happens locally in Postgres functions.

## 1. Set up Supabase

You said you already have a project. In the Supabase dashboard:

1. **Project Settings -> API** — copy the **Project URL** and **anon public key**.
2. **SQL Editor** — run the migration files **in order**, each as its own query:
   - `supabase/migrations/0001_schema.sql`
   - `supabase/migrations/0002_rls.sql`
   - `supabase/migrations/0003_functions.sql`
   - `supabase/migrations/0004_grants.sql`
   - `supabase/migrations/0005_challenge_module_link.sql`
   - `supabase/migrations/0006_capstone_submit_function.sql`
   - `supabase/migrations/0007_mock_interview.sql`
   - `supabase/migrations/0008_pin_function_search_path.sql`
3. Then run the seed files, also in order:
   - `supabase/seed/01_skills.sql`
   - `supabase/seed/02_sample_level.sql`
   - `supabase/seed/03_levels_3_8.sql`
   - `supabase/seed/04_level_9_forecasting.sql`
   - `supabase/seed/05_capstone_project.sql`
   - `supabase/seed/06_interview_questions.sql`
   - `supabase/seed/07_level_10_optimization.sql`
   - `supabase/seed/08_level_1_introduction.sql`
   - `supabase/seed/09_levels_11_13.sql`
   - `supabase/seed/10_levels_14_16.sql`
   - `supabase/seed/11_levels_17_19.sql`
   - `supabase/seed/12_levels_20_21.sql`

   (If you have the Supabase CLI installed instead, `supabase db push` after
   linking the project will apply everything in `supabase/migrations`
   automatically — just run the two seed files manually afterward, since seeds
   aren't auto-applied by `db push`.)

4. **Authentication -> Providers** — Email provider should already be on by
   default. For a private single-user app it's worth turning off public
   sign-ups later (Authentication -> Settings -> "Allow new users to sign up")
   once you and your tracker have both created accounts — see step 3 below.

## 2. Configure environment variables

```bash
cp .env.example .env.local
```

Fill in:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-public-key
```

## 3. Run it locally

```bash
npm install
npm run dev
```

Open http://localhost:3000 -> redirects to `/login`. Click **Create account**:

- Create **one account with role "learner"** (this is you, doing the coursework).
- Create **one account with role "tracker"** (this is the person/you monitoring
  progress) — use a different email.

Each role is routed to its own area (`/dashboard` vs `/tracker`) and the
middleware enforces that a learner can never see `/tracker` and vice versa.

Once both accounts exist, go back to Supabase **Authentication -> Settings**
and turn off "Allow new users to sign up" so no one else can register.

## 4. Deploy to Vercel

1. Push this project to a GitHub repo (or `vercel` CLI directly from this folder).
2. Import it in Vercel.
3. Add the same two environment variables (`NEXT_PUBLIC_SUPABASE_URL`,
   `NEXT_PUBLIC_SUPABASE_ANON_KEY`) in Vercel's Project Settings -> Environment
   Variables.
4. Deploy. `vercel.json` is already configured for the Next.js framework preset.

## How the capability engine works

- **Nothing is scored client-side.** Quiz/challenge grading happens inside
  Postgres functions (`submit_quiz_attempt`, `submit_challenge_attempt`) that
  the client calls via `supabase.rpc(...)`. The client never sees a correct
  answer before submitting.
- **Skill score != lesson completion.** Each skill's score is a weighted blend
  of knowledge (quizzes, 30%), practical (challenges, 40%), assessment (20%),
  and confidence/consistency (10%), using a recency-weighted moving average so
  one lucky guess can't fake mastery.
- **Readiness score** follows the exact weighting from the original spec:
  cloud 15% / finops 20% / practical 20% / problem-solving 15% / data analysis
  10% / communication 10% / consistency 10%.
- **Every tracker metric is real.** The tracker dashboard only ever reads
  `learning_activities`, `daily_learning_stats`, `user_skills`, and
  `readiness_history` — there is no synthetic/random data anywhere.

## Adding curriculum beyond Level 21

Follow the pattern in `supabase/seed/02_sample_level.sql`:

1. Insert a `learning_paths` row (or reuse an existing one) with the right
   `sequence_order`.
2. Insert `courses` -> `modules` -> `lessons` under it. Lesson `content` is a
   JSON object: `{ "sections": [{ "heading": "...", "body": "..." }] }`.
3. Insert a `quizzes` row + `quiz_questions` rows. Set each question's
   `skill_category` to an exact `skills.skill_name` value (see
   `supabase/seed/01_skills.sql` for the full list) so answering it actually
   moves that skill's score.
4. Insert a `challenges` row. `scenario_data` holds whatever simulated dataset
   the learner needs to see; `scoring_rules.criteria` is an array of
   `{ key, label, expected, weight, skill, options }` — the grading function
   matches the learner's answer for each `key` against `expected`.

No code changes are needed to add content — it's all data.

## The Cloud Cost Simulator

Level 9's third lesson ("Modeling 'What If': The Cloud Cost Simulator") embeds
a live, interactive `<CostSimulator>` component (`components/CostSimulator.tsx`).
It renders whenever a lesson's `content` JSON includes a `simulator` key —
`{ "sections": [...], "simulator": { "instances": [...] } }` — so any future
lesson can drop the same widget in just by including that key. Each instance
has a size, quantity, average utilization, and commitment type; the learner
can edit any of these and watch monthly cost recalculate live (rates and
discount percentages are simplified, illustrative figures defined in
`lib/types.ts`, not a live provider price feed). It also flags
under-utilized fleets with a rightsizing suggestion and has a one-click
"apply all suggestions" button. This is a client-side sandbox tool, not a
graded exercise — the graded practical for that skill is the challenge that
follows it, which asks the learner to make and justify a specific
recommendation from a similar scenario.

## QA pass: added a curriculum browse page

Before this pass, the only way to reach curriculum content was the
dashboard's single "Continue Learning" card — there was no way to see the
other levels, jump ahead, or revisit a completed one. That was a minor gap
at 9 levels; at 21 it's a real navigation problem. `/curriculum` (linked from
the learner sidebar) lists all 21 levels with per-lesson completion status,
each expandable to its 3 lessons, quiz, and challenge — no new tables or
migrations, just a page querying the existing schema.

## The Capstone Project

`/capstone` (linked from the learner sidebar) is a single comprehensive
deliverable seeded in `05_capstone_project.sql` — a realistic FinOps
consulting scenario with six open-ended requirements and six published
evaluation criteria. Unlike quizzes and challenges, there's no hidden
correct answer to grade against, so this is intentionally **not** algorithmic
scoring: the learner writes a real response to each requirement, then
self-checks which evaluation criteria their write-up actually satisfies. The
`submit_capstone_project()` function (migration 0006) saves the submission
and computes a transparent "self-assessed completeness" percentage from that
checklist — the UI is explicit that this isn't the same rigor as the
server-graded quiz/challenge scores, precisely so it can't be mistaken for
one. `user_capstone_projects` was also missing a `unique(user_id, project_id)`
constraint (unlike every other per-user-per-item progress table) — fixed in
the same migration. Progress and completion log to `learning_activities`
exactly like every other activity type, so the tracker dashboard's existing
activity timeline picks it up automatically — no tracker-side changes needed.

## The Mock Interview System

`/interview` (linked from the learner sidebar) is a self-serve practice tool,
not a graded exercise — genuinely couldn't be one, since interview answers
have no single correct answer to grade against any more than the capstone
does. `interview_questions` (seeded in `06_interview_questions.sql`) is a
bank of behavioral/technical/scenario questions across the curriculum's skill
areas, each with `guidance` (talking points a strong answer would hit, not a
hidden key) rather than a `correct_answer`. Because there's no key to
protect, the question bank is readable directly by the client, unlike
`quiz_questions`.

A session (`start_interview_session`, migration `0007`) is a fixed set of
questions picked at page-load time; the learner writes a real answer to each
and self-rates their own confidence 1-5, then `submit_interview_session`
saves drafts or, on final submission, summarizes the self-ratings into
`capability_assessments` — an existing table from the original schema that
had RLS enabled from day one but nothing writing to it yet, so this reuses it
rather than adding a new results table. It's the same "transparent
self-assessment, not an algorithmic grade" pattern as the capstone. A session
is repeatable practice rather than a one-off deliverable, so unlike the
capstone there's no `unique(user_id, ...)` constraint — a learner can run as
many sessions as they want.

Completion logs to `learning_activities` using the existing
`assessment_completed` type (no new activity type, no tracker page changes
needed) — but only on final submission; starting a practice session isn't
logged, since it's not a curriculum milestone the way finishing a lesson or
quiz is.

## Known scope notes for this pass

- All 21 curriculum levels are seeded end-to-end, along with the interactive
  Cloud Cost Simulator, the capstone project, and the mock interview system —
  there is nothing left unbuilt from the original spec's structure.
- There is no original-spec document in this repo listing exact titles for
  Level 1 or Levels 10-21 — those topics were chosen deliberately rather than
  copied from a source: Level 1 fills in the true entry point the numbering
  implied but Level 2 skipped past; Level 10 (Cost Optimization Strategies)
  fills the one FinOps lifecycle phase (Optimize) that Levels 3-9 hadn't
  covered; Levels 11-21 build out the remaining skill_category values already
  seeded in 01_skills.sql (commitment strategy, multi-cloud, unit economics,
  governance, KPIs, Excel/SQL, executive communication, Kubernetes,
  negotiation) that no quiz or challenge had exercised until now, ending with
  Level 21 explicitly closing the loop back to the Crawl/Walk/Run maturity
  model introduced in Level 3.
- **Fixed two correctness bugs that only surfaced once a second level of
  content existed:**
  - `challenges` had no link to a module — the lesson page grabbed
    *any* challenge from the whole table (`.limit(1)`), which happened to
    work with exactly one challenge in the database but would have shown
    the wrong challenge everywhere once more were added. Migration
    `0005_challenge_module_link.sql` adds `challenges.module_id`, backfills
    the existing challenge, and the lesson page now reads the challenge
    through its module relation instead.
  - The dashboard's "next lesson" query ordered only by `lessons.sequence_order`,
    which resets to 1/2/3 within every module — so with more than one module
    it could land on an arbitrary lesson instead of the true next one, and it
    never excluded already-completed lessons. It now walks the full
    path -> course -> module -> lesson order and skips anything the learner
    has completed.
- `quiz_questions.correct_answer` and `challenges.scoring_rules` are technically
  readable by the authenticated Postgres role via RLS (any signed-in user could
  query the table directly, bypassing the app's UI, and see answers). For a
  single trusted learner this is a non-issue; if this ever becomes multi-user,
  move `correct_answer`/`scoring_rules` behind a `security definer` view or a
  service-role-only table.
- Offline support is queue-and-replay (localStorage) for RPC calls, not full
  offline content caching — lesson text still needs an initial load while online.
