-- ============================================================================
-- Levels 14-16: FinOps Governance & Policy -> FinOps KPIs & Scorecards ->
-- Data Analysis for FinOps (Excel & SQL foundations for billing data).
-- Same shape as every prior level.
-- ============================================================================

-- ============================================================================
-- LEVEL 14 — FinOps Governance & Policy
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('FinOps Governance & Policy', 'Making the Optimize-phase wins permanent through ownership, policy, and enforcement.', 'Advanced', 14, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Operationalizing FinOps',
  'The Operate phase of the lifecycle: ownership models, policy-as-code guardrails, and review cadences.',
  'Advanced', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Ownership, Policy, and Guardrails', 'Turning one-time cleanups into a permanent, governed practice.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Optimization Wins Erode Without Governance',
  'The recurring pattern of cost creeping back after a cleanup.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Governance is the set of ongoing policies, ownership assignments, and review processes that keep a one-time optimization win from silently reversing over the following months.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A rightsizing project or tagging cleanup is a snapshot in time. Without governance, new resources get provisioned the old, wasteful way again within a few months, and the exact same cleanup has to be repeated — governance is what breaks that cycle.'),
    jsonb_build_object('heading','How does it work?','body',
      'Governance typically combines named ownership (who is accountable for a policy staying enforced), automated guardrails (systems that prevent or flag policy violations at creation time), and a recurring review cadence that catches whatever guardrails miss.'),
    jsonb_build_object('heading','Real company example','body',
      'A company ran the same tagging cleanup project three years in a row because nobody owned keeping tag coverage high after each cleanup — the fourth year, adding an automated enforcement policy finally broke the cycle for good.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Policy-as-Code Guardrails',
  'Preventing waste at creation time instead of finding it after the fact.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Policy-as-code guardrails are automated rules — enforced by code, not a document — that block or flag a resource at the moment it is created if it violates a cost or governance policy, such as missing a required tag or exceeding an approved instance size.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A policy written in a wiki page that nobody reads has essentially no enforcement power. A policy enforced automatically at resource-creation time cannot be accidentally skipped.'),
    jsonb_build_object('heading','How does it work?','body',
      'Guardrails range from "hard blocks" (the resource simply cannot be created without meeting policy) to "soft flags" (the resource is created but immediately surfaced for review) — the right choice depends on how confident the organization is in the policy and how much it trusts engineers'' judgment for exceptions.'),
    jsonb_build_object('heading','Real company example','body',
      'After repeatedly finding forgotten, oversized development environments during manual reviews, a company added a guardrail blocking any environment tagged "dev" from using production-tier instance sizes — the problem stopped recurring immediately, with zero ongoing manual effort.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Building a Review Cadence and RACI',
  'Deciding who reviews what, how often, and who is actually accountable.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A review cadence is the recurring schedule (weekly, monthly, quarterly) at which cost data, budget variance, and policy compliance actually get looked at by a human. A RACI (Responsible, Accountable, Consulted, Informed) model names who does what in that process.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Without a defined cadence and named owners, "someone should look at this eventually" reliably becomes "nobody looked at this in six months" — governance intentions without an operating rhythm rarely survive contact with everyone''s busy calendar.'),
    jsonb_build_object('heading','How does it work?','body',
      'A simple, effective structure assigns one person as accountable for each governance policy (e.g., tagging), a recurring calendar slot for review, and a clear escalation path for what happens when the review finds a violation that guardrails did not catch.'),
    jsonb_build_object('heading','Real company example','body',
      'A quarterly, calendar-invited FinOps review with one named accountable owner per policy area outlived two reorganizations that would have otherwise let the practice quietly lapse — because the meeting, not any one person''s memory, was what kept it running.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'FinOps Governance & Policy Quiz', 'Checks understanding of governance, guardrails, and review cadence design.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'Why do optimization wins tend to erode over time without governance?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Cloud providers automatically undo optimizations'),
   jsonb_build_object('id','b','text','New resources keep getting provisioned the same wasteful way without enforcement'),
   jsonb_build_object('id','c','text','Optimization only ever works for one month'),
   jsonb_build_object('id','d','text','It never actually erodes')),
 'b', 'Without ongoing enforcement, the same patterns that caused waste originally simply repeat with new resources.', 'Beginner', 'FinOps Governance', 1),
(v_quiz_id, 'True or False: A policy documented only in a wiki page, with no automated enforcement, is generally as effective as an automated guardrail.', 'true_false', null, 'false',
 'Undocumented enforcement relies on people remembering and following the policy manually — automated guardrails cannot be accidentally skipped.', 'Beginner', 'FinOps Governance', 2),
(v_quiz_id, 'What is the difference between a "hard block" and a "soft flag" guardrail?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A hard block prevents resource creation entirely; a soft flag allows creation but surfaces it for review'),
   jsonb_build_object('id','b','text','They are identical in every way'),
   jsonb_build_object('id','c','text','A soft flag is always stricter than a hard block'),
   jsonb_build_object('id','d','text','Hard blocks only apply to storage')),
 'a', 'Hard blocks stop non-compliant resources outright; soft flags let them through but flag them for a human to review.', 'Advanced', 'FinOps Governance', 3),
(v_quiz_id, 'What is the purpose of a RACI model in a FinOps governance practice?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','To name who is responsible, accountable, consulted, and informed for each policy area'),
   jsonb_build_object('id','b','text','To calculate cloud bills automatically'),
   jsonb_build_object('id','c','text','To replace the need for any review meetings'),
   jsonb_build_object('id','d','text','It has no practical use in FinOps')),
 'a', 'RACI clarifies exactly who owns and is involved in each governance area, preventing ambiguity about accountability.', 'Advanced', 'FinOps Governance', 4),
(v_quiz_id, 'A company runs the same tagging cleanup every year with no lasting improvement. What is the most likely missing piece?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','A bigger cleanup effort each year'),
   jsonb_build_object('id','b','text','An automated enforcement guardrail and a named accountable owner'),
   jsonb_build_object('id','c','text','Switching cloud providers'),
   jsonb_build_object('id','d','text','Nothing is missing — this is expected behavior')),
 'b', 'Recurring, unenforced cleanups are the classic symptom of missing governance — automated enforcement plus ownership breaks the cycle.', 'Advanced', 'FinOps Governance', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Design a Guardrail for a Recurring Problem',
  'Turn a recurring manual finding into a permanent, automated fix.', 'Advanced',
  'For the third consecutive quarterly review, the FinOps team manually finds and shuts down several forgotten development environments running on expensive, production-tier instance sizes.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','Same finding recurs every quarter'),
    jsonb_build_object('signal','Currently caught only through manual review'),
    jsonb_build_object('signal','Pattern is specific and consistent: dev environments on production-tier sizes')
  )),
  'Recommend the most durable fix for this recurring problem, and specify whether it should be a hard block or a soft flag.',
  array['FinOps Governance','Problem Solving'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','fix','label','Most durable fix','expected','an automated policy-as-code guardrail','weight',3,'skill','FinOps Governance',
      'options', jsonb_build_array('an automated policy-as-code guardrail','a stricter manual review checklist','a strongly worded email to engineering','hiring more reviewers')),
    jsonb_build_object('key','guardrail_type','label','Guardrail type','expected','hard block','weight',2,'skill','Problem Solving',
      'options', jsonb_build_array('hard block','soft flag'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 15 — FinOps KPIs & Building a Scorecard
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('FinOps KPIs & Scorecards', 'The core metrics that summarize whether a FinOps practice is actually working.', 'Advanced', 15, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Measuring FinOps Success',
  'Choosing the handful of KPIs that matter, and combining them into a single, honest scorecard.',
  'Advanced', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Core KPIs and the FinOps Scorecard', 'The small set of metrics every mature practice tracks.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'The Core FinOps KPIs',
  'A short list of metrics that summarize the whole practice.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A small set of KPIs — commitment coverage and utilization, percentage of spend allocated (tagged), forecast accuracy, and rate of identified savings actually realized — together summarize whether a FinOps practice is functioning well, without requiring a full report to be read.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Leadership rarely has time to read a detailed cost report every month. A small, consistent scorecard lets them see practice health at a glance, and know when to ask for more detail.'),
    jsonb_build_object('heading','How does it work?','body',
      'Each KPI should have a target, a current value, and a trend direction, tracked consistently period over period — a single snapshot number, without trend or target, is far less useful than the same number shown against where it should be and where it was last quarter.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that used to present a 40-slide monthly cost deck replaced it with a single-page, 5-KPI scorecard — leadership engagement with the topic went up, not down, once the presentation stopped requiring 40 slides of context just to find the signal.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Savings Realization: The KPI Most Practices Skip',
  'The difference between identifying savings and actually capturing them.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Savings realization tracks what percentage of identified optimization opportunities (from rightsizing reviews, commitment recommendations, etc.) were actually implemented and produced measurable savings, as opposed to simply being reported and forgotten.'),
    jsonb_build_object('heading','Why is it important?','body',
      'It is common for a FinOps team to proudly report "$500,000 in identified savings opportunities" every quarter, while the actual implemented savings are a small fraction of that — savings realization is the metric that catches this gap.'),
    jsonb_build_object('heading','How does it work?','body',
      'Tracking realization requires following up on every recommendation made in a prior period — not just making new recommendations — and reporting the ratio of dollars actually saved to dollars identified as a distinct, visible metric.'),
    jsonb_build_object('heading','Real company example','body',
      'A team discovered their savings realization rate was only 30% — most identified opportunities were never actually implemented by the owning engineering teams — and shifted focus from finding more opportunities to closing the loop on ones already identified.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Building a One-Page Scorecard',
  'Combining several KPIs into a single view leadership will actually read.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A scorecard combines the core KPIs — coverage, utilization, allocation percentage, forecast accuracy, and savings realization — into one consistent, recurring, single-page view, rather than scattering them across separate reports.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A scorecard is what makes FinOps legible to an audience that does not have time to dig into raw billing data — it is the translation layer between detailed analysis and an executive''s five minutes of attention.'),
    jsonb_build_object('heading','How does it work?','body',
      'Each metric on the scorecard should have a simple visual status (on track, needs attention, off track) rather than just a raw number, so a reader can scan the whole page in seconds and know exactly where to focus their questions.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s first one-page scorecard immediately surfaced that forecast accuracy had been quietly declining for two quarters — a trend invisible in any single month''s report, but obvious once tracked consistently on the same page over time.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'FinOps KPIs Quiz', 'Checks understanding of core KPIs, savings realization, and scorecard design.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What does "savings realization" measure?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','The total dollar amount ever spent on cloud'),
   jsonb_build_object('id','b','text','What percentage of identified savings opportunities were actually implemented'),
   jsonb_build_object('id','c','text','How many meetings were held about cost'),
   jsonb_build_object('id','d','text','The number of cloud providers used')),
 'b', 'Savings realization tracks the gap between identified opportunities and ones actually implemented.', 'Advanced', 'FinOps KPIs', 1),
(v_quiz_id, 'True or False: A KPI shown as a single snapshot number, without a target or trend, is generally as useful as one shown with both.', 'true_false', null, 'false',
 'Target and trend context are what make a KPI actionable — a bare snapshot number tells you far less on its own.', 'Beginner', 'FinOps KPIs', 2),
(v_quiz_id, 'A team reports $500,000 in identified savings opportunities, but its savings realization rate is only 30%. What does this reveal?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','The team is performing extremely well'),
   jsonb_build_object('id','b','text','Most identified opportunities were never actually implemented'),
   jsonb_build_object('id','c','text','The $500,000 figure must be wrong'),
   jsonb_build_object('id','d','text','Realization rate is not a meaningful metric')),
 'b', 'A low realization rate on a large identified-savings figure means most opportunities are being reported but not acted on.', 'Advanced', 'FinOps KPIs', 3),
(v_quiz_id, 'What is the main purpose of a one-page FinOps scorecard?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','To replace all detailed cost analysis entirely'),
   jsonb_build_object('id','b','text','To give leadership a legible, at-a-glance view of practice health'),
   jsonb_build_object('id','c','text','To make the report as long as possible'),
   jsonb_build_object('id','d','text','It serves no real purpose')),
 'b', 'A scorecard translates detailed data into something leadership can scan quickly and act on.', 'Advanced', 'FinOps KPIs', 4),
(v_quiz_id, 'Which of these is a recommended way to present each metric on a scorecard?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','As a raw number with no other context'),
   jsonb_build_object('id','b','text','With a simple status like on track / needs attention / off track'),
   jsonb_build_object('id','c','text','Buried in a footnote'),
   jsonb_build_object('id','d','text','Only reported once a year')),
 'b', 'A simple status indicator lets a reader scan the whole scorecard in seconds and know where to focus.', 'Beginner', 'FinOps KPIs', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Diagnose a Gap in a FinOps Scorecard',
  'Spot the trend a single month''s report would have missed.', 'Advanced',
  'A quarterly scorecard shows forecast accuracy at 88% this month, 84% last month, and 79% the month before — coverage and utilization are both healthy and stable across the same three months.',
  jsonb_build_object('history', jsonb_build_array(
    jsonb_build_object('month','Month 1','forecast_accuracy',79),
    jsonb_build_object('month','Month 2','forecast_accuracy',84),
    jsonb_build_object('month','Month 3','forecast_accuracy',88)
  )),
  'Identify which KPI shows a trend worth flagging to leadership, and state whether that trend is improving or declining.',
  array['FinOps KPIs','Data Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','flagged_kpi','label','KPI worth flagging','expected','forecast accuracy','weight',3,'skill','FinOps KPIs',
      'options', jsonb_build_array('forecast accuracy','commitment coverage','commitment utilization','none of them')),
    jsonb_build_object('key','trend_direction','label','Trend direction','expected','improving','weight',2,'skill','Data Analysis',
      'options', jsonb_build_array('improving','declining','flat'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 16 — Data Analysis for FinOps (Excel & SQL Foundations)
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Data Analysis for FinOps', 'The Excel and SQL foundations needed to actually work with a raw billing dataset.', 'Advanced', 16, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Working With Billing Data Directly',
  'Moving from summarized dashboards to the raw Cost and Usage Report data underneath them.',
  'Advanced', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Excel and SQL for Cost Data', 'The two core tools for analyzing a raw billing dataset.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Every FinOps Analyst Needs Excel Fluency',
  'Pivot tables and formulas as the fastest path from raw export to an answer.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Despite dashboards and BI tools, a huge share of real FinOps analysis still happens in a spreadsheet — pulling a raw billing export, building a pivot table, and answering a specific question a dashboard was never built to answer.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Dashboards answer the questions someone anticipated when building them. A one-off question from a VP ("how much did we spend on this specific new feature last month, broken down by region?") often has no existing dashboard — Excel fluency is what lets an analyst answer it same-day instead of filing a ticket for a new dashboard.'),
    jsonb_build_object('heading','How does it work?','body',
      'The core skills are pivot tables (grouping and summarizing large datasets by any dimension), VLOOKUP/XLOOKUP (joining data from separate sheets), and basic formulas for period-over-period comparison — the same operations a database query performs, just accessible without writing code.'),
    jsonb_build_object('heading','Real company example','body',
      'A same-day answer to a VP''s ad hoc cost question, built entirely from a pivot table on a raw CUR export, built more trust in the FinOps team than months of polished recurring dashboards had — speed and correctness on unanticipated questions is what earns credibility.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Reading a Real Cost and Usage Report (CUR)',
  'What the raw, granular billing export actually looks like, and how to navigate it.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A Cost and Usage Report is a raw, line-by-line export where every single billable event is its own row — often millions of rows per month for a large company — with columns for service, resource ID, usage type, tags, and cost.'),
    jsonb_build_object('heading','Why is it important?','body',
      'The summarized invoice from earlier in this program hides the detail needed for real investigation. Answering "why did this specific resource''s cost change" requires the raw CUR, not the summary.'),
    jsonb_build_object('heading','How does it work?','body',
      'Given the row volume, a CUR is rarely opened directly in a spreadsheet at full size — it is typically filtered, aggregated, or queried (with SQL, covered in the next level) before analysis, using the tag and resource-ID columns to answer allocation and driver-analysis questions from earlier levels.'),
    jsonb_build_object('heading','Real company example','body',
      'An anomaly traced to "Compute" at the service level in a dashboard was only fully explained once the analyst filtered the raw CUR down to the exact resource ID responsible — the dashboard could say what changed, but only the raw data could say precisely why.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'From Spreadsheet to Query: Knowing When to Switch',
  'The point where a dataset gets too large or complex for Excel alone.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Excel handles most day-to-day FinOps analysis well, but has real limits: row-count ceilings, slow performance on very large pivot tables, and difficulty joining many data sources together cleanly.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Recognizing when a question has outgrown Excel — rather than forcing it to work anyway — saves significant time and avoids subtly wrong answers from a spreadsheet silently truncating data it couldn''t fully load.'),
    jsonb_build_object('heading','How does it work?','body',
      'A rough rule of thumb: a single month of one company''s raw CUR, multiple joined data sources, or any recurring analysis that needs to run automatically every month, is a sign it belongs in SQL rather than a manually rebuilt spreadsheet each time — the topic of the next level.'),
    jsonb_build_object('heading','Real company example','body',
      'A recurring monthly report built manually in Excel silently dropped rows once the dataset grew past Excel''s comfortable working size, understating spend for two months before anyone noticed the gap — a SQL-based version rebuilt the same report reliably regardless of size.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Data Analysis for FinOps Quiz', 'Checks understanding of Excel fluency, CUR structure, and knowing when to move to SQL.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'Why is Excel fluency still valuable even when dashboards exist?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','It lets an analyst answer one-off questions a dashboard was never built for'),
   jsonb_build_object('id','b','text','Dashboards are always wrong'),
   jsonb_build_object('id','c','text','Excel is required by law for billing analysis'),
   jsonb_build_object('id','d','text','It has no ongoing value once dashboards exist')),
 'a', 'Ad hoc, unanticipated questions are where spreadsheet fluency earns its keep — dashboards only answer what they were built to answer.', 'Beginner', 'Excel', 1),
(v_quiz_id, 'True or False: A summarized monthly invoice contains the same level of detail as a raw Cost and Usage Report.', 'true_false', null, 'false',
 'The CUR is far more granular, with a row for nearly every billable event — the summarized invoice hides that detail.', 'Beginner', 'Cloud Billing', 2),
(v_quiz_id, 'What is a strong signal that an analysis has outgrown Excel and belongs in SQL?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','The dataset is small and simple'),
   jsonb_build_object('id','b','text','It needs to join multiple large data sources or run automatically every month'),
   jsonb_build_object('id','c','text','It is a one-time, very small question'),
   jsonb_build_object('id','d','text','The analyst prefers spreadsheets')),
 'b', 'Recurring, large, or multi-source analyses are the classic case for moving from spreadsheets to queries.', 'Advanced', 'SQL Fundamentals', 3),
(v_quiz_id, 'A recurring Excel-built monthly report silently understates spend once the dataset grows too large. What is the likely cause?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','The cloud provider changed its prices'),
   jsonb_build_object('id','b','text','Excel silently truncated rows it could not fully load'),
   jsonb_build_object('id','c','text','The report was intentionally falsified'),
   jsonb_build_object('id','d','text','Nothing is wrong with the report')),
 'b', 'Spreadsheets can silently drop data past their comfortable working size, producing an understated but plausible-looking result.', 'Advanced', 'Cloud Cost Data Analysis', 4),
(v_quiz_id, 'What column type in a raw CUR is most useful for answering "why did this specific resource''s cost change"?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Resource ID and tags'),
   jsonb_build_object('id','b','text','The invoice date only'),
   jsonb_build_object('id','c','text','The company''s stock ticker'),
   jsonb_build_object('id','d','text','None — the CUR cannot answer this')),
 'a', 'Resource-level granularity and tags are exactly what let an analyst trace a change down to a specific cause.', 'Advanced', 'Cloud Cost Data Analysis', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Choose the Right Tool for a Billing Question',
  'Decide whether a question belongs in a spreadsheet or a query.', 'Advanced',
  'A VP asks two questions: (1) "What did we spend on the Payments team last month?" — answerable from a small, already-tagged monthly summary. (2) "Build a report that automatically joins three years of raw CUR data across two cloud providers every month going forward."',
  jsonb_build_object('questions', jsonb_build_array(
    jsonb_build_object('question','Payments team spend last month','data_size','small, already summarized'),
    jsonb_build_object('question','Automated 3-year, multi-provider recurring join','data_size','very large, recurring, multi-source')
  )),
  'For each question, recommend whether Excel or SQL is the appropriate tool, and justify each choice.',
  array['Excel','SQL Fundamentals','Data Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','question_1_tool','label','Tool for question 1','expected','Excel','weight',2,'skill','Excel',
      'options', jsonb_build_array('Excel','SQL')),
    jsonb_build_object('key','question_2_tool','label','Tool for question 2','expected','SQL','weight',3,'skill','SQL Fundamentals',
      'options', jsonb_build_array('Excel','SQL'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
