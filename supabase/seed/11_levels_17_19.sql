-- ============================================================================
-- Levels 17-19: SQL for Cost Analysis -> Executive Reporting & Stakeholder
-- Communication -> Container & Kubernetes Cost Management.
-- Same shape as every prior level.
-- ============================================================================

-- ============================================================================
-- LEVEL 17 — SQL for Cost Analysis
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('SQL for Cost Analysis', 'Querying a raw billing dataset directly, for the analyses that have outgrown a spreadsheet.', 'Advanced', 17, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Querying Billing Data With SQL',
  'The handful of SQL patterns that cover almost every recurring FinOps analysis.',
  'Advanced', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Core SQL Patterns for Billing Data', 'GROUP BY, JOIN, and window functions applied to a Cost and Usage Report.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'GROUP BY: The Single Most Useful SQL Pattern in FinOps',
  'Turning millions of billing rows into one summarized answer.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'GROUP BY aggregates many rows into one summary row per distinct value of a chosen column — for example, summing cost for every row, grouped by team tag, to get one total per team from a dataset with millions of individual line items.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Nearly every recurring FinOps report — cost by team, cost by service, cost by day — is fundamentally a GROUP BY query. It is the single highest-leverage SQL pattern for this discipline.'),
    jsonb_build_object('heading','How does it work?','body',
      'A typical pattern looks like: `select team_tag, sum(cost) from billing_data group by team_tag order by sum(cost) desc` — group by the dimension you want to break cost down by, aggregate the cost column, and sort to surface the biggest contributors first.'),
    jsonb_build_object('heading','Real company example','body',
      'A report that used to take an analyst half a day to rebuild manually in a spreadsheet each month became a five-line SQL query that ran automatically — the underlying logic was a GROUP BY the whole time, just done by hand before.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'JOIN: Connecting Billing Data to Business Context',
  'Combining raw cost data with the team, product, or customer information it needs to be meaningful.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A JOIN combines rows from two tables based on a shared key — for example, connecting raw billing rows (keyed by account ID) to a separate table mapping account IDs to team names, so the report can show team names instead of opaque account numbers.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Raw billing data alone rarely has the business context (team ownership, product line, customer) needed for allocation and unit economics — that context usually lives in a separate table that has to be joined in.'),
    jsonb_build_object('heading','How does it work?','body',
      'A typical pattern looks like: `select t.team_name, sum(b.cost) from billing_data b join team_mapping t on b.account_id = t.account_id group by t.team_name` — joining first, then grouping and aggregating, is the standard shape of most cost-allocation queries.'),
    jsonb_build_object('heading','Real company example','body',
      'A cost report that only ever showed raw, unreadable account IDs became genuinely useful to non-technical stakeholders once a simple JOIN mapped those IDs to the human-readable team and product names everyone actually recognized.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Window Functions for Trend and Period-Over-Period Analysis',
  'Comparing this month to last month without a separate, manually-joined query.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A window function calculates a value across a set of related rows — like the prior month''s cost for the same team — without collapsing the result into a single summary row the way GROUP BY does, making period-over-period comparisons much simpler to write.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Trend and variance analysis (from earlier levels) fundamentally requires comparing a value to its own prior period — window functions are the SQL feature purpose-built for exactly that comparison.'),
    jsonb_build_object('heading','How does it work?','body',
      'A common pattern uses `LAG()` to pull the previous period''s value into the same row as the current period, so the percentage change can be calculated directly in a single query: `cost - LAG(cost) OVER (PARTITION BY team ORDER BY month)`.'),
    jsonb_build_object('heading','Real company example','body',
      'An anomaly-detection query that once required exporting two separate monthly reports and comparing them by hand in a spreadsheet became a single automated query using a window function — turning a monthly manual chore into something that runs unattended.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'SQL for Cost Analysis Quiz', 'Checks understanding of GROUP BY, JOIN, and window functions applied to billing data.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the primary purpose of a GROUP BY clause in a cost analysis query?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','To aggregate many rows into one summary row per distinct value of a chosen column'),
   jsonb_build_object('id','b','text','To delete rows from a table'),
   jsonb_build_object('id','c','text','To rename a column'),
   jsonb_build_object('id','d','text','To connect to a different database entirely')),
 'a', 'GROUP BY is the standard way to summarize many billing rows into totals by team, service, or any other dimension.', 'Beginner', 'SQL Fundamentals', 1),
(v_quiz_id, 'True or False: Raw billing data typically already includes readable team and product names with no need for a JOIN.', 'true_false', null, 'false',
 'Raw billing data is usually keyed by account/resource IDs — a JOIN to a separate mapping table is typically needed to get readable team or product names.', 'Advanced', 'SQL Fundamentals', 2),
(v_quiz_id, 'What SQL feature is purpose-built for comparing a value to its own value from a prior period, within the same query?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Window functions (e.g., LAG)'),
   jsonb_build_object('id','b','text','DELETE statements'),
   jsonb_build_object('id','c','text','CREATE TABLE statements'),
   jsonb_build_object('id','d','text','Comments')),
 'a', 'Window functions like LAG() pull a prior period''s value into the current row, enabling direct period-over-period comparison.', 'Advanced', 'SQL Fundamentals', 3),
(v_quiz_id, 'A recurring monthly cost-by-team report currently takes an analyst half a day to rebuild manually each month. What SQL approach would most directly solve this?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','A GROUP BY query aggregating cost by team, run automatically'),
   jsonb_build_object('id','b','text','Deleting the billing data'),
   jsonb_build_object('id','c','text','Manually retyping the numbers each month'),
   jsonb_build_object('id','d','text','Switching to a different cloud provider')),
 'a', 'This is a textbook GROUP BY use case — automating it removes the recurring manual effort entirely.', 'Advanced', 'SQL Fundamentals', 4),
(v_quiz_id, 'In `select team_tag, sum(cost) from billing_data group by team_tag order by sum(cost) desc`, what does the ORDER BY clause accomplish?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Surfaces the highest-cost teams first'),
   jsonb_build_object('id','b','text','Deletes the lowest-cost teams'),
   jsonb_build_object('id','c','text','Groups the data (duplicating GROUP BY)'),
   jsonb_build_object('id','d','text','Has no effect on the output')),
 'a', 'Sorting descending by the summed cost puts the largest contributors at the top of the result, which is usually what a reader wants first.', 'Advanced', 'SQL Fundamentals', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Design a Query for a Recurring Report',
  'Choose the right SQL pattern for a real recurring reporting need.', 'Advanced',
  'Leadership wants a report showing each team''s cost this month next to their cost last month, with the percentage change, generated automatically every month with no manual spreadsheet work.',
  jsonb_build_object('requirement', jsonb_build_array(
    jsonb_build_object('need','Aggregate cost by team'),
    jsonb_build_object('need','Compare each team''s current month to their own prior month'),
    jsonb_build_object('need','Run automatically every month')
  )),
  'Identify which two SQL patterns from this lesson are both required to build this report, given the requirements listed.',
  array['SQL Fundamentals','Cloud Cost Data Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','pattern_1','label','First required pattern','expected','GROUP BY','weight',2,'skill','SQL Fundamentals',
      'options', jsonb_build_array('GROUP BY','DELETE','CREATE TABLE')),
    jsonb_build_object('key','pattern_2','label','Second required pattern','expected','a window function like LAG','weight',3,'skill','SQL Fundamentals',
      'options', jsonb_build_array('a window function like LAG','a comment','an index'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 18 — Executive Reporting & Stakeholder Communication
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Executive Reporting & Stakeholder Communication', 'Translating detailed cost analysis into something each audience actually acts on.', 'Professional', 18, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Communicating Cost to Different Audiences',
  'The same underlying finding, reshaped for an engineer, a finance partner, and a CFO.',
  'Professional', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Audience-Aware Cost Communication', 'Tailoring the same finding to engineering, finance, and executive audiences.', 1, 'Professional')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'One Finding, Three Audiences',
  'Why the same cost finding needs to be written three different ways.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'The same underlying finding — say, an oversized database tier — needs a completely different level of detail and framing depending on whether it is going to the engineer who owns it, a finance partner tracking budget, or a CFO reading an executive summary.'),
    jsonb_build_object('heading','Why is it important?','body',
      'An engineer needs specific technical detail to act (which instance, what utilization data). A CFO needs the opposite — the dollar impact and the recommendation, with technical detail actively removed as noise. Sending the wrong version to the wrong audience undermines the finding, however correct it is.'),
    jsonb_build_object('heading','How does it work?','body',
      'A practical habit is writing the technical, detailed version first (since that''s where the analysis actually happened), then deliberately rewriting — not just trimming — a second, business-framed version for less technical audiences, leading with impact and recommendation rather than method.'),
    jsonb_build_object('heading','Real company example','body',
      'An analyst who sent the same detailed technical writeup to both engineering and the CFO got a great response from engineering and total silence from the CFO — the CFO version needed to be rewritten from scratch, not just shortened.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Leading With the Answer',
  'Executive communication puts the conclusion first, not last.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Leading with the answer means opening a report or message with the conclusion and recommendation immediately, rather than building up to it through the methodology — the opposite order from how the analysis itself was often done.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A busy executive reading the first two sentences should already know what happened and what you recommend — they will ask for detail only if they want it, and burying the answer under methodology risks it never being read at all.'),
    jsonb_build_object('heading','How does it work?','body',
      'A strong executive opening states the finding and the recommendation in one or two sentences, then offers supporting detail below for whoever wants to read further — never the reverse order of building suspense toward a conclusion.'),
    jsonb_build_object('heading','Real company example','body',
      'A report that opened with three paragraphs of methodology before finally stating its recommendation on the second page was skimmed and misunderstood by leadership — a rewritten version leading with the recommendation in the first sentence got immediate, correct engagement.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Handling Pushback and Disagreement',
  'What to do when a stakeholder disagrees with a cost recommendation.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Pushback is a normal, expected part of stakeholder communication — a team disputing a cost allocation, or an executive questioning a recommendation''s assumptions. How this moment is handled matters as much as the original analysis.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Defensive or dismissive responses to legitimate pushback damage trust in the FinOps function far more than being wrong about a number once — credibility is built by how disagreements get resolved, not by never being challenged.'),
    jsonb_build_object('heading','How does it work?','body',
      'A good response to pushback starts by genuinely checking whether the stakeholder has a point (they often know their own workload better than the analyst does), and separates "here is the data" from "here is my recommendation" so a disagreement about the recommendation doesn''t have to mean disputing the underlying data.'),
    jsonb_build_object('heading','Real company example','body',
      'An engineering team pushed back hard on a rightsizing recommendation, correctly pointing out that the utilization data window used had missed a legitimate seasonal peak — updating the analysis to reflect that feedback, rather than defending the original number, produced a better final recommendation and a stronger working relationship.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Executive Reporting & Stakeholder Communication Quiz', 'Checks understanding of audience-aware communication, leading with the answer, and handling pushback.', 'Professional', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'Why might the same cost finding need to be written differently for an engineer versus a CFO?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Because each audience needs a different level of technical detail and framing to act on it'),
   jsonb_build_object('id','b','text','Because CFOs cannot read technical documents at all'),
   jsonb_build_object('id','c','text','There is no real reason — one version always works for everyone'),
   jsonb_build_object('id','d','text','Because engineers do not care about cost')),
 'a', 'Different audiences act on different levels of detail — an engineer needs specifics, a CFO needs impact and recommendation.', 'Beginner', 'Executive Reporting', 1),
(v_quiz_id, 'True or False: A strong executive report should build up to its recommendation gradually, ending with the conclusion.', 'true_false', null, 'false',
 'Executive communication should lead with the answer/recommendation first, not save it for the end.', 'Beginner', 'Executive Reporting', 2),
(v_quiz_id, 'What should the first sentence of an executive-facing cost report typically contain?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A detailed description of the analysis methodology'),
   jsonb_build_object('id','b','text','The finding and the recommendation'),
   jsonb_build_object('id','c','text','A joke to lighten the mood'),
   jsonb_build_object('id','d','text','The full raw dataset')),
 'b', 'Leading with the answer means the finding and recommendation come first, with detail available below for those who want it.', 'Professional', 'Executive Reporting', 3),
(v_quiz_id, 'An engineering team pushes back on a rightsizing recommendation, correctly pointing out a missed seasonal peak. What is the best response?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Defend the original recommendation without reviewing their point'),
   jsonb_build_object('id','b','text','Update the analysis to reflect the valid feedback'),
   jsonb_build_object('id','c','text','Escalate immediately to leadership without discussion'),
   jsonb_build_object('id','d','text','Ignore the pushback entirely')),
 'b', 'Legitimate pushback that improves the accuracy of an analysis should be incorporated, not defended against.', 'Professional', 'Stakeholder Communication', 4),
(v_quiz_id, 'What is a recommended way to separate data from recommendation when handling stakeholder disagreement?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Presenting "here is the data" separately from "here is my recommendation," so disagreeing with one does not require disputing the other'),
   jsonb_build_object('id','b','text','Always assuming the stakeholder is wrong'),
   jsonb_build_object('id','c','text','Refusing to share the underlying data at all'),
   jsonb_build_object('id','d','text','Combining data and recommendation so they cannot be separately evaluated')),
 'a', 'Separating data from recommendation allows productive disagreement about the conclusion without disputing the underlying facts.', 'Professional', 'Stakeholder Communication', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Rewrite a Technical Finding for an Executive Audience',
  'Turn a detailed technical writeup into a lead-with-the-answer executive summary.', 'Professional',
  'A technical writeup reads: "Our database tier''s CPU utilization has averaged 14% over the trailing 90 days across all four nodes, with peak utilization never exceeding 31% even during the highest-traffic period. Based on this sustained low utilization, we recommend downsizing from the current xlarge instance type to large, which would reduce the monthly cost of this tier from $18,400 to approximately $9,200 with no expected performance impact."',
  jsonb_build_object('technical_writeup', 'See scenario above'),
  'Identify what the very first sentence of the executive-facing rewrite should lead with, and identify one technical detail from the original that should be dropped entirely for the executive audience.',
  array['Executive Reporting','Business Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','lead_with','label','What the first sentence should lead with','expected','the recommendation and the dollar savings','weight',3,'skill','Executive Reporting',
      'options', jsonb_build_array('the recommendation and the dollar savings','the CPU utilization percentage','the number of nodes','the instance type name')),
    jsonb_build_object('key','detail_to_drop','label','Detail to drop for this audience','expected','the specific utilization percentages and node count','weight',2,'skill','Business Communication',
      'options', jsonb_build_array('the specific utilization percentages and node count','the dollar savings figure','the recommendation itself','nothing should be dropped'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 19 — Container & Kubernetes Cost Management
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Container & Kubernetes Cost Management', 'Why containerized infrastructure breaks the usual allocation model, and how to fix it.', 'Professional', 19, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cost Visibility in Containerized Environments',
  'Allocating cost when many teams share the same underlying cluster.',
  'Professional', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Kubernetes Cost Allocation and Optimization', 'Why a shared cluster needs its own allocation approach.', 1, 'Professional')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Kubernetes Breaks Traditional Cost Allocation',
  'The bill is for the whole cluster; the usage is dozens of separate teams.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A Kubernetes cluster typically runs many different teams'' applications ("workloads") on a shared pool of underlying virtual machines. The cloud bill only shows the cost of those underlying machines — not which team''s workload actually consumed what share of them.'),
    jsonb_build_object('heading','Why is it important?','body',
      'The resource-level tagging approach from earlier levels does not work cleanly here: an individual virtual machine hosts pieces of many different teams'' workloads simultaneously, so a single tag on that machine cannot capture a fair split.'),
    jsonb_build_object('heading','How does it work?','body',
      'Kubernetes cost allocation instead requires visibility inside the cluster itself — tracking each workload''s actual CPU and memory requests/usage — and allocating the underlying machine cost proportionally based on that in-cluster usage data, not the machine-level tags used everywhere else.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s existing tagging-based allocation model simply broke once workloads moved to a shared Kubernetes cluster — the same virtual machines suddenly served a dozen teams at once, and a completely different, workload-level allocation approach had to be built from scratch.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Requests vs. Limits: The Kubernetes Rightsizing Problem',
  'Why over-requested workloads are the Kubernetes version of an oversized virtual machine.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'In Kubernetes, a workload declares "requests" (resources it is guaranteed to get) and "limits" (the maximum it is allowed to use). Requests reserve capacity on the underlying machines whether or not the workload actually uses it.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Teams commonly over-request "to be safe," reserving far more CPU and memory than their workload actually needs — this is the direct Kubernetes equivalent of an oversized, underutilized virtual machine from the rightsizing lesson earlier in this program.'),
    jsonb_build_object('heading','How does it work?','body',
      'Rightsizing a Kubernetes workload means comparing its actual observed usage against its declared requests, then lowering the requests to match real usage with a reasonable safety margin — freeing up reserved-but-unused capacity for other workloads to actually use.'),
    jsonb_build_object('heading','Real company example','body',
      'A cluster running at only 35% overall utilization, despite hosting dozens of "fully-booked" workloads on paper, turned out to be almost entirely over-requested — rightsizing requests across the largest offenders let the same cluster host significantly more real workload with no new machines added.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Cluster-Level Optimization: Autoscaling and Bin Packing',
  'Optimizing the shared infrastructure layer, not just individual workloads.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Beyond fixing individual workloads'' requests, a cluster itself can be optimized: autoscaling adds or removes underlying machines to match total cluster demand, and "bin packing" arranges workloads efficiently across existing machines to minimize wasted, unused space on each one.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Even with perfectly rightsized individual workloads, a poorly packed or non-autoscaling cluster can still run mostly-empty machines around the clock — this is a cluster-level optimization layer distinct from, and in addition to, workload-level rightsizing.'),
    jsonb_build_object('heading','How does it work?','body',
      'Cluster autoscalers monitor overall demand and add machines only when existing capacity is genuinely insufficient, while a scheduler''s bin-packing behavior determines how tightly workloads are consolidated onto the fewest machines needed, rather than spread thinly across many partially-empty ones.'),
    jsonb_build_object('heading','Real company example','body',
      'A cluster with well-rightsized individual workloads was still running twice as many underlying machines as needed, simply because the scheduler was spreading workloads thin instead of packing them tightly — a bin-packing configuration change alone cut the machine count nearly in half.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Container & Kubernetes Cost Management Quiz', 'Checks understanding of Kubernetes cost allocation, requests vs. limits, and cluster-level optimization.', 'Professional', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'Why does traditional resource-level tagging fail to allocate cost cleanly on a shared Kubernetes cluster?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A single underlying machine can host pieces of many different teams'' workloads at once'),
   jsonb_build_object('id','b','text','Kubernetes does not support tags at all'),
   jsonb_build_object('id','c','text','Kubernetes clusters are always owned by exactly one team'),
   jsonb_build_object('id','d','text','Tagging works exactly the same as with individual virtual machines')),
 'a', 'Because many teams'' workloads share the same underlying machines, a single machine-level tag cannot capture a fair per-team split.', 'Advanced', 'FinOps Fundamentals', 1),
(v_quiz_id, 'True or False: A Kubernetes workload''s declared "requests" reserve capacity regardless of whether the workload is actually using it.', 'true_false', null, 'true',
 'Requests reserve guaranteed capacity on the underlying machine, whether or not the workload actually consumes it — over-requesting wastes reserved capacity.', 'Advanced', 'Rightsizing', 2),
(v_quiz_id, 'What is the Kubernetes equivalent of an oversized, underutilized virtual machine?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A workload with requests set far higher than its actual observed usage'),
   jsonb_build_object('id','b','text','A cluster with zero workloads'),
   jsonb_build_object('id','c','text','A workload with no requests set at all'),
   jsonb_build_object('id','d','text','There is no equivalent concept in Kubernetes')),
 'a', 'Over-requested workloads reserve unused capacity, directly analogous to an oversized VM.', 'Advanced', 'Rightsizing', 3),
(v_quiz_id, 'A cluster has well-rightsized workloads but still runs twice as many machines as needed. What is the most likely cause?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Poor bin-packing spreading workloads thin across many machines instead of consolidating them'),
   jsonb_build_object('id','b','text','The cloud provider is overcharging'),
   jsonb_build_object('id','c','text','Rightsizing individual workloads always causes this'),
   jsonb_build_object('id','d','text','There is no possible explanation')),
 'a', 'Even with rightsized workloads, poor bin-packing at the scheduler level can leave far more machines running than necessary.', 'Professional', 'Cost Optimization', 4),
(v_quiz_id, 'What does a Kubernetes cluster autoscaler primarily do?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Adds or removes underlying machines to match overall cluster demand'),
   jsonb_build_object('id','b','text','Deletes all workloads automatically'),
   jsonb_build_object('id','c','text','Sets requests and limits for every workload automatically with no human input'),
   jsonb_build_object('id','d','text','Has no relationship to cost at all')),
 'a', 'Autoscaling matches the number of underlying machines to actual cluster-wide demand, avoiding both under- and over-provisioning.', 'Professional', 'Cost Optimization', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Diagnose a Kubernetes Cost Problem',
  'Distinguish a workload-level problem from a cluster-level one.', 'Professional',
  'A shared Kubernetes cluster runs at 35% overall utilization. Investigation shows individual workloads are requesting roughly 3x their actual observed usage on average, and the cluster''s scheduler is also spreading workloads thinly rather than consolidating them.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','Workloads requesting ~3x actual usage'),
    jsonb_build_object('signal','Scheduler spreading workloads thin rather than consolidating'),
    jsonb_build_object('signal','Overall cluster utilization at 35%')
  )),
  'Identify both contributing problems present here, and state which layer (workload-level or cluster-level) each one belongs to.',
  array['Rightsizing','Cost Optimization','FinOps Fundamentals'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','problem_1','label','First problem and its layer','expected','over-requested workloads, workload-level','weight',3,'skill','Rightsizing',
      'options', jsonb_build_array('over-requested workloads, workload-level','too few machines, cluster-level','no problems exist','billing error, provider-level')),
    jsonb_build_object('key','problem_2','label','Second problem and its layer','expected','poor bin-packing, cluster-level','weight',3,'skill','Cost Optimization',
      'options', jsonb_build_array('poor bin-packing, cluster-level','under-requested workloads, workload-level','too many teams','a pricing model change'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
