-- ============================================================================
-- Levels 3-8: FinOps Fundamentals -> Cloud Billing -> Cost Allocation &
-- Tagging -> Showback & Chargeback -> Cost Analysis -> Budgeting.
-- Same shape as supabase/seed/02_sample_level.sql: each level is one
-- learning_path -> one course -> one module -> 3 lessons -> 1 quiz (5
-- questions) -> 1 challenge (linked to the module via challenges.module_id,
-- added in migration 0005).
-- ============================================================================

-- ============================================================================
-- LEVEL 3 — FinOps Fundamentals
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('FinOps Fundamentals', 'What FinOps is, who does it, and why it exists.', 'Foundation', 3, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'The FinOps Discipline',
  'The Crawl-Walk-Run maturity model, the three phases of the FinOps lifecycle, and who owns what.',
  'Foundation', 1, 150)
returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'What Is FinOps?', 'The discipline, its phases, and its core metrics.', 1, 'Beginner')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'FinOps: A Cultural Practice, Not Just a Cost-Cutting Job',
  'What FinOps actually is, and why it is a partnership between finance, engineering, and business.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'FinOps (a blend of "Finance" and "DevOps") is the practice of bringing financial accountability to the variable spend model of the cloud. It is not one person''s job title alone — it is a set of practices that gets engineers, finance, and business leaders looking at the same cost data and making joint tradeoffs between speed, cost, and quality.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Before the cloud, IT spend was a fixed, predictable line item finance approved once a year. Cloud spend is variable, decentralized (any engineer can spin up a resource), and changes daily. Without FinOps, this creates "bill shock" — nobody realizes costs have climbed until finance sees the invoice, by which point the spend already happened.'),
    jsonb_build_object('heading','How does it work?','body',
      'FinOps runs as an iterative cycle of three phases: Inform (get visibility into what is being spent and by whom), Optimize (identify and act on waste and inefficiency), and Operate (build the processes and governance that make the first two phases continuous rather than one-off).'),
    jsonb_build_object('heading','Real company example','body',
      'A media company found that its streaming infrastructure cost had tripled over a year. Instead of one team unilaterally cutting resources (which risked outages), FinOps got engineering, finance, and product in the same room: engineering explained what drove the increase, finance quantified the budget impact, and product weighed in on which features were worth the cost. That joint decision-making is the essence of FinOps.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'The FinOps Lifecycle: Inform, Optimize, Operate',
  'The three-phase loop every mature FinOps practice runs continuously.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','Inform','body',
      'The Inform phase is about visibility: allocating cost accurately to teams, products, and business units, and giving everyone a shared, trusted view of what they are spending. You cannot optimize what you cannot see, so this phase always comes first.'),
    jsonb_build_object('heading','Optimize','body',
      'Once cost is visible, Optimize is where waste gets found and eliminated: rightsizing oversized resources, buying commitment discounts for predictable workloads, and cleaning up unused resources. This phase is where most people assume "FinOps" begins — but it only works because Inform came first.'),
    jsonb_build_object('heading','Operate','body',
      'Operate is where the first two phases become permanent rather than a one-time cleanup: budgets, alerts, tagging policies, and regular review cadences that keep cost under control as the business keeps shipping new features and scaling up.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'Every task you will do in this program maps to one of these three phases. Reading a bill and allocating cost by tag is Inform. Recommending a rightsizing change is Optimize. Building a monthly budget-vs-actual report is Operate. Knowing which phase you are in helps you know what "done" looks like.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Crawl, Walk, Run: The FinOps Maturity Model',
  'How a company''s FinOps practice matures over time, and how to spot which stage a team is in.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','Crawl','body',
      'A "Crawl" stage organization has basic visibility — they know roughly what they spend in total — but little allocation detail, no tagging discipline, and reactive (not proactive) cost management. Most companies start here.'),
    jsonb_build_object('heading','Walk','body',
      'A "Walk" stage organization has decent tagging coverage, regular cost reviews, and has started buying commitment discounts. Optimization is happening, but often only when someone notices a problem, not on a fixed cadence.'),
    jsonb_build_object('heading','Run','body',
      'A "Run" stage organization treats cost like a first-class engineering metric alongside performance and reliability: automated anomaly detection, cost-aware architecture decisions made at design time, and unit economics tracked per customer or transaction.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'You will rarely walk into a company at "Run." Most of your early work will be Crawl-stage cleanup — better tagging, basic showback reports — before you can even attempt more advanced Walk/Run practices like unit economics or automated governance.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'FinOps Fundamentals Quiz', 'Checks understanding of the FinOps lifecycle and maturity model.', 'Beginner', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the primary goal of the "Inform" phase of the FinOps lifecycle?',
 'multiple_choice',
 jsonb_build_array(jsonb_build_object('id','a','text','Automatically cutting all unused resources'),
   jsonb_build_object('id','b','text','Giving teams accurate, shared visibility into what they spend'),
   jsonb_build_object('id','c','text','Negotiating a discount with the cloud provider'),
   jsonb_build_object('id','d','text','Firing underperforming engineers')),
 'b', 'Inform is about visibility and shared, trusted cost data — everything else in FinOps depends on this being right first.', 'Beginner', 'FinOps Fundamentals', 1),
(v_quiz_id, 'True or False: FinOps is best understood as a single person''s job title.', 'true_false', null, 'false',
 'FinOps is a cross-functional practice spanning finance, engineering, and business — not one role.', 'Beginner', 'FinOps Fundamentals', 2),
(v_quiz_id, 'A company has decent tagging and holds regular but reactive cost reviews. Which maturity stage best describes them?',
 'scenario', jsonb_build_array(jsonb_build_object('id','a','text','Crawl'), jsonb_build_object('id','b','text','Walk'), jsonb_build_object('id','c','text','Run')),
 'b', 'Regular reviews and reasonable tagging, but still reactive rather than automated, is the hallmark of the Walk stage.', 'Intermediate', 'FinOps Fundamentals', 3),
(v_quiz_id, 'Which FinOps lifecycle phase does "rightsizing an oversized virtual machine" belong to?',
 'multiple_choice', jsonb_build_array(jsonb_build_object('id','a','text','Inform'), jsonb_build_object('id','b','text','Optimize'), jsonb_build_object('id','c','text','Operate')),
 'b', 'Rightsizing is an action taken on cost that has already been made visible — that is the Optimize phase.', 'Beginner', 'FinOps Fundamentals', 4),
(v_quiz_id, 'What best distinguishes a "Run" stage FinOps practice from a "Walk" stage one?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Run-stage companies spend less on cloud in total'),
   jsonb_build_object('id','b','text','Run-stage companies treat cost as a first-class metric with automated governance and unit economics'),
   jsonb_build_object('id','c','text','Run-stage companies do not need engineers'),
   jsonb_build_object('id','d','text','Run-stage companies only use one cloud provider')),
 'b', 'Run-stage maturity is defined by automation, cost-aware design decisions, and unit economics — not simply spending less.', 'Intermediate', 'FinOps KPIs', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Diagnose the Team''s FinOps Maturity Stage',
  'Assess a real-sounding scenario against the Crawl/Walk/Run model.', 'Beginner',
  'A department head describes their setup: "We know our total AWS bill each month, but we can''t say which team is driving it. Tagging is inconsistent, and we usually only look closely at cost when finance flags it as unusually high."',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','Total spend known, but not allocated by team'),
    jsonb_build_object('signal','Inconsistent tagging'),
    jsonb_build_object('signal','Cost reviewed reactively, only when flagged')
  )),
  'Based on the three signals above, classify this team''s FinOps maturity stage and recommend the single highest-priority next step.',
  array['FinOps Fundamentals','Problem Solving','Stakeholder Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','maturity_stage','label','Maturity stage','expected','Crawl','weight',3,'skill','FinOps Fundamentals',
      'options', jsonb_build_array('Crawl','Walk','Run')),
    jsonb_build_object('key','priority_action','label','Highest-priority next step','expected','improve tagging','weight',3,'skill','Problem Solving',
      'options', jsonb_build_array('improve tagging','buy more reserved instances','build a machine learning cost model','switch cloud providers'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 4 — Reading the Cloud Bill (Cloud Billing)
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Cloud Billing', 'How to actually read and reconcile a cloud invoice.', 'Foundation', 4, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cloud Billing Fundamentals',
  'Line items, pricing models, and how to reconcile what you were billed against what you expected.',
  'Foundation', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Understanding Your Invoice', 'What''s actually on a cloud bill and how pricing models work.', 1, 'Beginner')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Anatomy of a Cloud Invoice',
  'The line items, accounts, and time periods that make up a typical bill.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A cloud invoice is a detailed, itemized statement of every billable event across an account for a billing period — typically a calendar month. Unlike a fixed utility bill, it can contain thousands of line items: one for every service, region, and usage type combination that was consumed.'),
    jsonb_build_object('heading','Why is it important?','body',
      'You cannot manage what you cannot read. A FinOps analyst who cannot parse an invoice cannot allocate cost, spot anomalies, or explain a spend increase to a stakeholder — reading the bill accurately is the single most foundational skill in the discipline.'),
    jsonb_build_object('heading','How does it work?','body',
      'Bills are typically organized by account (or subscription), then by service (e.g., compute, storage), then by usage type and region. Providers also expose a much more granular "Cost and Usage Report" (CUR) — a raw, line-by-line export used for detailed analysis rather than the summarized PDF invoice.'),
    jsonb_build_object('heading','Real company example','body',
      'A finance team receiving only the summarized monthly PDF invoice cannot tell why compute cost rose 20%. Pulling the detailed Cost and Usage Report reveals it was one specific team''s test environment left running all month — a finding invisible in the summary view.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Pricing Models: On-Demand, Reserved, and Spot',
  'The three fundamental ways cloud resources are priced, and the tradeoffs between them.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','On-Demand','body',
      'On-Demand pricing charges the full list rate for exactly what you use, with no upfront commitment. It is the most flexible and the most expensive per unit — the "retail price" of cloud computing.'),
    jsonb_build_object('heading','Reserved / Committed','body',
      'Reserved Instances (AWS), Reserved VM Instances (Azure), and Committed Use Discounts (GCP) all trade a 1- or 3-year usage commitment for a significantly lower rate — often 30-60% cheaper — on predictable, steady-state workloads.'),
    jsonb_build_object('heading','Spot / Preemptible','body',
      'Spot instances sell a provider''s unused capacity at steep discounts (often 70-90% off), but the provider can reclaim that capacity with little warning. They fit fault-tolerant, interruptible workloads like batch processing, not customer-facing production systems.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'A huge share of cloud waste comes from running steady, predictable workloads on expensive On-Demand pricing simply because nobody made the commitment decision. Identifying which workloads are stable enough for Reserved or Committed pricing is one of the highest-leverage optimizations a FinOps analyst can recommend.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Reconciling the Bill: Catching Errors and Surprises',
  'How to check that what you were billed matches what you expected.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Reconciliation means comparing the current bill against a prior period (or a forecast) and confirming that every material difference has an explanation. It is a routine, disciplined check — not a one-time audit.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Cloud billing systems are complex, and errors do happen: duplicate resources, mis-tagged accounts, or a provider-side billing mistake. Without regular reconciliation, these go unnoticed for months and compound.'),
    jsonb_build_object('heading','How does it work?','body',
      'A typical reconciliation process compares month-over-month spend by service, flags any line item that moved beyond a set threshold (for example, more than 15%), and requires an owner to explain each flagged change before the books are considered closed for the month.'),
    jsonb_build_object('heading','Real company example','body',
      'A reconciliation review caught that a backup job had been duplicated after a migration, silently doubling storage cost for two months before anyone in engineering noticed. The fix was a five-minute deletion — but only after the bill review surfaced it.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Cloud Billing Quiz', 'Checks understanding of invoice structure, pricing models, and reconciliation.', 'Beginner', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is a Cost and Usage Report (CUR)?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A marketing brochure from the cloud provider'),
   jsonb_build_object('id','b','text','A raw, line-by-line detailed export of billing data'),
   jsonb_build_object('id','c','text','A forecast of next year''s spend'),
   jsonb_build_object('id','d','text','A contract renewal notice')),
 'b', 'The CUR is the granular, line-item export used for detailed analysis — much more detailed than the summarized invoice.', 'Beginner', 'Cloud Billing', 1),
(v_quiz_id, 'Which pricing model offers the deepest discount but can be reclaimed by the provider with little warning?',
 'multiple_choice', jsonb_build_array(jsonb_build_object('id','a','text','On-Demand'), jsonb_build_object('id','b','text','Reserved'), jsonb_build_object('id','c','text','Spot')),
 'c', 'Spot/preemptible capacity is steeply discounted precisely because the provider can reclaim it at any time.', 'Beginner', 'Cloud Billing', 2),
(v_quiz_id, 'True or False: On-Demand pricing is generally the cheapest way to run a steady, predictable workload long-term.', 'true_false', null, 'false',
 'Reserved/committed pricing is cheaper for steady, predictable workloads — On-Demand is the most flexible but most expensive rate.', 'Beginner', 'Cloud Billing', 3),
(v_quiz_id, 'A storage line item unexpectedly doubles month over month. What is the correct first reconciliation step?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Ignore it, storage always fluctuates'),
   jsonb_build_object('id','b','text','Immediately delete all storage resources'),
   jsonb_build_object('id','c','text','Investigate the specific resources driving the increase before taking action'),
   jsonb_build_object('id','d','text','Switch cloud providers')),
 'c', 'Reconciliation means investigating the specific driver of a flagged change before acting, not reacting blindly.', 'Beginner', 'Cloud Billing', 4),
(v_quiz_id, 'Which workload is the best fit for Spot/preemptible pricing?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A customer-facing production checkout service'),
   jsonb_build_object('id','b','text','A fault-tolerant, interruptible batch data processing job'),
   jsonb_build_object('id','c','text','A database of record'),
   jsonb_build_object('id','d','text','A company''s primary authentication service')),
 'b', 'Spot fits fault-tolerant, interruptible work — not systems that must stay up continuously for customers.', 'Intermediate', 'Cloud Billing', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Reconcile a Month-Over-Month Cost Jump',
  'A billing reconciliation exercise using a small simulated dataset.', 'Beginner',
  'This month''s compute line item rose from $30,000 to $46,000. Last month, the team also purchased zero commitment discounts; this month they still bought zero.',
  jsonb_build_object('line_items', jsonb_build_array(
    jsonb_build_object('item','Compute - On-Demand','last_month',30000,'this_month',46000),
    jsonb_build_object('item','Compute - Reserved','last_month',0,'this_month',0)
  )),
  'Identify the most likely explanation for the increase and recommend the single highest-leverage fix, given that no commitment discounts have ever been purchased.',
  array['Cloud Billing','Cloud Cost Data Analysis','Problem Solving'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','likely_cause','label','Most likely cause','expected','usage increase on on-demand pricing','weight',3,'skill','Cloud Billing',
      'options', jsonb_build_array('usage increase on on-demand pricing','a provider price cut','a currency exchange rate change','a data entry error')),
    jsonb_build_object('key','recommended_fix','label','Highest-leverage fix','expected','purchase reserved instances or savings plans','weight',3,'skill','Problem Solving',
      'options', jsonb_build_array('purchase reserved instances or savings plans','delete the invoice','switch regions','wait and see'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 5 — Cost Allocation & Tagging
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Cost Allocation & Tagging', 'Attributing spend to the teams and products that actually caused it.', 'Intermediate', 5, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cost Allocation & Tagging',
  'Tagging strategy, tag hygiene, and how untagged resources get allocated.',
  'Intermediate', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Tagging Strategy & Cost Allocation', 'How resources get attributed to the right owner.', 1, 'Intermediate')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Cost Allocation Matters',
  'Turning one big shared bill into an accurate view of who spends what.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Cost allocation is the process of attributing a shared cloud bill to the specific teams, products, or cost centers that actually generated the spend, instead of leaving it as one undifferentiated total.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Without allocation, nobody is accountable for cost — the bill is "the company''s" problem, and no individual team feels pressure to optimize. Accurate allocation is what makes every other FinOps practice (budgeting, showback, optimization) possible.'),
    jsonb_build_object('heading','How does it work?','body',
      'Allocation relies primarily on resource tags — metadata labels attached to cloud resources (e.g., team=payments, env=production) — that let a billing system group cost by any dimension the business cares about.'),
    jsonb_build_object('heading','Real company example','body',
      'A 200-engineer company found that 40% of its cloud spend was "untaggable" — nobody could say which team owned it. After a tagging push, that untagged share dropped to 4%, and three teams voluntarily cut spend once they could finally see their own number.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Building a Tagging Strategy',
  'What good tags look like, and the policies that keep them consistent.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','Required tag categories','body',
      'A solid tagging strategy usually requires a small, mandatory set of tags on every resource: owning team, environment (production/staging/dev), cost center, and application/product name. Optional tags can cover anything else, but these four almost always exist.'),
    jsonb_build_object('heading','Enforcement','body',
      'Tags only work if they are enforced, not just recommended. Mature organizations use automated policies that block resource creation (or flag it for cleanup) when required tags are missing, rather than relying on engineers to remember.'),
    jsonb_build_object('heading','Common pitfalls','body',
      'Common tagging failures include inconsistent casing (Team vs team vs TEAM, which billing systems treat as different values), tags that drift out of date as ownership changes, and tagging only some resource types while others (like storage buckets) get skipped.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'Before you can allocate, showback, or chargeback anything, you have to assess and improve tag coverage and consistency — this is often the very first project a FinOps analyst runs at a new company.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Handling Untagged and Shared Cost',
  'What to do with the spend that cannot be cleanly attributed to one team.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Even in a well-tagged environment, some cost is genuinely shared — a company-wide networking backbone, a central logging platform — and some is simply untagged because of gaps in enforcement. Both need a defined handling method.'),
    jsonb_build_object('heading','Allocation methods for shared cost','body',
      'Shared cost is typically split using one of a few methods: evenly across all teams, proportionally based on each team''s tagged usage, or by a fixed negotiated percentage agreed on by finance and engineering leadership.'),
    jsonb_build_object('heading','Handling untagged cost','body',
      'Untagged cost should never simply disappear from reporting. Most organizations either allocate it proportionally like shared cost, or — better — report it as its own visible "unallocated" line item to create pressure to fix the tagging gap.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'A common mistake is hiding untagged spend inside someone''s allocated total to make the report look complete. This destroys trust in the numbers the moment a team notices costs they don''t recognize — transparency about what is and isn''t allocated matters more than a clean-looking report.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Cost Allocation & Tagging Quiz', 'Checks understanding of tagging strategy and shared/untagged cost handling.', 'Intermediate', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the primary mechanism used to allocate shared cloud cost to specific teams?',
 'multiple_choice', jsonb_build_array(jsonb_build_object('id','a','text','Resource tags'), jsonb_build_object('id','b','text','Server hostnames'), jsonb_build_object('id','c','text','IP addresses'), jsonb_build_object('id','d','text','The invoice date')),
 'a', 'Resource tags are the metadata that lets billing systems group cost by team, environment, or any other business dimension.', 'Beginner', 'Cost Allocation', 1),
(v_quiz_id, 'True or False: Tag casing (e.g., "Team" vs "team") is typically treated as identical by billing systems.', 'true_false', null, 'false',
 'Most billing systems treat differently-cased tag keys/values as distinct, which fragments allocation if casing isn''t standardized.', 'Intermediate', 'Tagging', 2),
(v_quiz_id, 'A company finds 40% of its spend is untagged. What is the recommended way to report it?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Hide it by folding it evenly into every team''s total'),
   jsonb_build_object('id','b','text','Report it as a visible, separate "unallocated" line item'),
   jsonb_build_object('id','c','text','Delete the untagged resources without investigation'),
   jsonb_build_object('id','d','text','Leave it out of every report')),
 'b', 'Transparency about unallocated spend builds trust and creates pressure to fix the underlying tagging gap.', 'Intermediate', 'Cost Allocation', 3),
(v_quiz_id, 'Which of these is NOT typically one of the small set of mandatory tags?',
 'multiple_choice', jsonb_build_array(jsonb_build_object('id','a','text','Owning team'), jsonb_build_object('id','b','text','Environment'), jsonb_build_object('id','c','text','Cost center'), jsonb_build_object('id','d','text','The engineer''s favorite color')),
 'd', 'Mandatory tags are business-meaningful dimensions like team, environment, and cost center — not arbitrary personal metadata.', 'Beginner', 'Tagging', 4),
(v_quiz_id, 'What is the best way to keep tagging consistent over time, rather than just recommending it?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','An automated policy that blocks or flags resources missing required tags'),
   jsonb_build_object('id','b','text','A yearly email reminder'),
   jsonb_build_object('id','c','text','Relying on each engineer''s memory'),
   jsonb_build_object('id','d','text','Nothing — tags fix themselves')),
 'a', 'Enforcement, not just guidance, is what keeps tag coverage high as an organization grows.', 'Intermediate', 'Tagging', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Design an Allocation Method for Shared Networking Cost',
  'Decide how to split a genuinely shared cost across teams.', 'Intermediate',
  'A company''s $12,000/month shared networking backbone serves three product teams of very different sizes and usage. Finance wants a defensible way to split this cost across the three teams'' budgets.',
  jsonb_build_object('teams', jsonb_build_array(
    jsonb_build_object('team','Payments','tagged_compute_spend',80000),
    jsonb_build_object('team','Search','tagged_compute_spend',50000),
    jsonb_build_object('team','Notifications','tagged_compute_spend',20000)
  )),
  'Recommend which allocation method is most defensible for this shared cost, and identify which team should be allocated the largest share under that method.',
  array['Cost Allocation','Financial Analysis','Business Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','method','label','Recommended allocation method','expected','proportional to tagged usage','weight',3,'skill','Cost Allocation',
      'options', jsonb_build_array('even split across all teams','proportional to tagged usage','allocate all to the largest team','ignore it')),
    jsonb_build_object('key','largest_share','label','Team with the largest allocated share','expected','Payments','weight',2,'skill','Financial Analysis',
      'options', jsonb_build_array('Payments','Search','Notifications'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 6 — Showback & Chargeback
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Showback & Chargeback', 'Making cost visible to teams, and when to actually bill them for it.', 'Intermediate', 6, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Showback & Chargeback Models',
  'The difference between visibility and billing, and how to choose between them.',
  'Intermediate', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Showback vs. Chargeback', 'Two ways to make cost accountability real.', 1, 'Intermediate')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Showback: Visibility Without a Bill',
  'Giving teams their number without actually moving money.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Showback reports each team''s allocated cost back to them for awareness, without any internal transfer of money. It answers "what did we spend?" without answering "who pays for it?"'),
    jsonb_build_object('heading','Why is it important?','body',
      'Simply seeing a number changes behavior. Teams that receive a monthly showback report reliably start noticing and questioning their own spend, even with zero financial consequence attached.'),
    jsonb_build_object('heading','How does it work?','body',
      'A showback report is typically a recurring dashboard or email built from allocated cost data (see the tagging/allocation lessons) broken down by team, with trends over time so teams can spot their own anomalies.'),
    jsonb_build_object('heading','Real company example','body',
      'After introducing monthly showback reports with no billing attached, one engineering team voluntarily deleted 15 unused development environments the week after seeing their number for the first time — no mandate required.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Chargeback: Making Cost Real',
  'Actually billing internal teams for their cloud usage.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Chargeback goes a step further than showback: the allocated cost is actually deducted from a team''s budget, as if they were paying a real invoice, even though the money stays inside the same company.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Chargeback creates the strongest possible incentive for teams to manage their own cost, because it directly affects their budget and headcount planning — not just their awareness.'),
    jsonb_build_object('heading','Tradeoffs','body',
      'Chargeback requires much more accurate, trusted allocation data than showback — teams will dispute a bill they think is wrong in a way they would never dispute an informational report. It also adds real organizational overhead: someone has to run it like an internal billing operation.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that moved straight to chargeback before its tagging was reliable spent months fighting disputes from teams who correctly pointed out their bill included another team''s misallocated resources — trust in the whole program suffered as a result.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Choosing Between Showback and Chargeback',
  'How to decide which model fits an organization''s maturity.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','Start with showback','body',
      'Almost every organization should start with showback. It requires less accurate data, builds trust in the numbers, and gets teams used to seeing (and reacting to) their own cost before any money moves.'),
    jsonb_build_object('heading','Graduate to chargeback carefully','body',
      'Chargeback should only follow once tagging and allocation are reliably accurate — the FinOps "Walk" or "Run" maturity stage from earlier in this path — and once teams already trust the underlying numbers from months of showback.'),
    jsonb_build_object('heading','A hybrid approach','body',
      'Many mature organizations run chargeback only for the largest, most stable cost categories (like reserved compute), while keeping smaller or newer categories on showback until the data is trustworthy enough to bill against.'),
    jsonb_build_object('heading','Why this matters for a FinOps analyst','body',
      'Recommending chargeback before an organization is ready is one of the most common FinOps mistakes — the right question is never "which model is better" in the abstract, but "how accurate and trusted is our allocation data today."')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Showback & Chargeback Quiz', 'Checks understanding of the two models and when to use each.', 'Intermediate', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the key difference between showback and chargeback?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Showback is more expensive to run'),
   jsonb_build_object('id','b','text','Chargeback actually deducts allocated cost from a team''s budget; showback only reports it'),
   jsonb_build_object('id','c','text','They are the same thing with different names'),
   jsonb_build_object('id','d','text','Showback only works for storage costs')),
 'b', 'Chargeback moves budget; showback is purely informational visibility.', 'Beginner', 'Showback', 1),
(v_quiz_id, 'True or False: Most organizations should move directly to chargeback without first running showback.', 'true_false', null, 'false',
 'Showback should almost always come first, to build trust in the data before any money moves.', 'Beginner', 'Chargeback', 2),
(v_quiz_id, 'Why does chargeback require more accurate allocation data than showback?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Because teams will dispute a bill that directly affects their budget in a way they wouldn''t dispute a report'),
   jsonb_build_object('id','b','text','Because chargeback uses a different cloud provider'),
   jsonb_build_object('id','c','text','Accuracy requirements are identical for both'),
   jsonb_build_object('id','d','text','Chargeback does not use tags at all')),
 'a', 'Real budget impact raises the stakes of any allocation error, so chargeback demands much higher trust in the underlying data.', 'Intermediate', 'Chargeback', 3),
(v_quiz_id, 'A company has unreliable, inconsistent tagging. What should a FinOps analyst recommend?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Move straight to full chargeback to force better tagging'),
   jsonb_build_object('id','b','text','Fix tagging and run showback first, before considering chargeback'),
   jsonb_build_object('id','c','text','Skip both and only report total company spend'),
   jsonb_build_object('id','d','text','Chargeback teams a random amount')),
 'b', 'Chargeback should wait until allocation data is trustworthy — showback first is the safer, more standard path.', 'Intermediate', 'Chargeback', 4),
(v_quiz_id, 'What does a "hybrid" showback/chargeback approach typically look like?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Chargeback for the largest, most stable cost categories; showback for the rest'),
   jsonb_build_object('id','b','text','Alternating models every other month at random'),
   jsonb_build_object('id','c','text','Chargeback for every category regardless of data quality'),
   jsonb_build_object('id','d','text','No reporting of any kind')),
 'a', 'A common hybrid pattern is chargeback where data is most reliable (e.g. reserved compute), showback elsewhere.', 'Intermediate', 'Chargeback', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Recommend a Cost-Accountability Model',
  'Decide whether an organization is ready for chargeback.', 'Intermediate',
  'A company has run showback reports for eight months. Teams broadly trust the numbers and have started proactively cleaning up waste. Tagging coverage is now at 96%. Leadership is asking whether to introduce chargeback for the compute category.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','8 months of trusted showback history'),
    jsonb_build_object('signal','96% tag coverage'),
    jsonb_build_object('signal','Teams already acting on the data voluntarily')
  )),
  'Recommend whether this company is ready to introduce chargeback for compute, and justify the recommendation using the signals given.',
  array['Chargeback','Showback','Business Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','recommendation','label','Recommendation','expected','ready for chargeback','weight',3,'skill','Chargeback',
      'options', jsonb_build_array('ready for chargeback','not ready, needs more showback first','never introduce chargeback','switch cloud providers first')),
    jsonb_build_object('key','key_justification','label','Strongest supporting signal','expected','high tag coverage with trusted history','weight',2,'skill','Business Communication',
      'options', jsonb_build_array('high tag coverage with trusted history','the company is large','leadership asked for it','the cloud bill is high'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 7 — Cost Analysis & Anomaly Detection
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Cost Analysis', 'Finding the story behind the numbers, including when something looks wrong.', 'Intermediate', 7, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cost Analysis & Anomaly Detection',
  'Trend analysis, cost drivers, and spotting the spend that doesn''t fit the pattern.',
  'Intermediate', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Analyzing Cost Trends & Anomalies', 'Reading the shape of spend over time.', 1, 'Intermediate')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Trend Analysis: Reading Spend Over Time',
  'Separating normal growth from something worth investigating.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Trend analysis looks at cost over multiple periods (weeks, months, quarters) rather than a single snapshot, to distinguish gradual, expected growth from a sudden, unexpected jump.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A single month''s number tells you almost nothing on its own. $50,000 could be alarming or completely normal depending on whether last month was $48,000 or $20,000 — trend context is what makes a number meaningful.'),
    jsonb_build_object('heading','How does it work?','body',
      'Analysts typically plot spend by service or team over a rolling window (commonly 3, 6, or 12 months), and compare the recent trend line''s slope against business context like headcount growth, new product launches, or seasonal traffic.'),
    jsonb_build_object('heading','Real company example','body',
      'A steady 5% month-over-month increase in compute spend looked alarming in isolation, but matched almost exactly with the company''s planned 5% monthly user growth target — the trend was expected, not a problem.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Identifying Cost Drivers',
  'Finding the specific factor responsible for a change in spend.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A cost driver is the specific, identifiable cause behind a change in spend — a new feature launch, a traffic spike, a pricing change, or a configuration mistake — as opposed to a vague "it just went up."'),
    jsonb_build_object('heading','Why is it important?','body',
      'Stakeholders cannot act on "cost went up." They can act on "cost went up because the new video feature increased egress by 40%." Identifying the specific driver is what turns a number into a decision.'),
    jsonb_build_object('heading','How does it work?','body',
      'Driver analysis usually works top-down: start with the total change, break it into the services that moved the most, then break each of those into the specific resources or usage types responsible, stopping once you reach something a human decision-maker can act on.'),
    jsonb_build_object('heading','Real company example','body',
      'A 12% total cost increase looked confusing until broken down: 9 of the 12 points came from one specific new feature''s database queries, which were unindexed and scanning far more data than necessary — a fixable engineering issue, not a vague "cloud got more expensive."')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Spotting Cost Anomalies',
  'Recognizing spend that breaks the established pattern and needs investigation.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A cost anomaly is a change in spend that deviates meaningfully from the established pattern — not just "went up," but "went up in a way the recent trend does not explain."'),
    jsonb_build_object('heading','Why is it important?','body',
      'Anomalies are often the earliest signal of a real problem: a misconfiguration, a runaway process, or even a security incident generating unexpected usage. Catching them early can save significant, avoidable spend.'),
    jsonb_build_object('heading','How does it work?','body',
      'Anomaly detection compares actual spend against an expected range built from historical patterns (accounting for known seasonality), and flags anything that falls meaningfully outside that range for human investigation — it flags, it does not automatically judge.'),
    jsonb_build_object('heading','Real company example','body',
      'An overnight anomaly alert on a normally-idle test environment led engineers to discover a runaway script that had been left accidentally looping, generating thousands of unnecessary API calls before anyone noticed — caught within hours instead of a full billing cycle.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Cost Analysis Quiz', 'Checks understanding of trend analysis, cost drivers, and anomaly detection.', 'Intermediate', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'Why is a single month''s spend number, on its own, usually not enough to judge cost health?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','It needs trend context from prior periods to know if it is normal or unusual'),
   jsonb_build_object('id','b','text','Single-month numbers are always wrong'),
   jsonb_build_object('id','c','text','Cloud providers do not report monthly totals'),
   jsonb_build_object('id','d','text','Only quarterly numbers are ever accurate')),
 'a', 'A number is only meaningful in the context of the trend it came from.', 'Beginner', 'Cost Analysis', 1),
(v_quiz_id, 'What is a "cost driver"?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','The employee who approved the cloud budget'),
   jsonb_build_object('id','b','text','The specific, identifiable cause behind a change in spend'),
   jsonb_build_object('id','c','text','A type of virtual machine'),
   jsonb_build_object('id','d','text','A billing software vendor')),
 'b', 'A cost driver is the concrete factor responsible for a spend change — the thing stakeholders can actually act on.', 'Beginner', 'Cost Analysis', 2),
(v_quiz_id, 'True or False: A cost anomaly alert should automatically judge whether a spend change is good or bad.', 'true_false', null, 'false',
 'Anomaly detection flags deviations for human investigation — it does not make the final judgment call.', 'Intermediate', 'Cost Anomaly Analysis', 3),
(v_quiz_id, 'A 12% total cost increase is traced to one new feature''s unindexed database queries. What is the correct next step?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Report only the 12% total and stop there'),
   jsonb_build_object('id','b','text','Flag the specific query issue to engineering as an actionable fix'),
   jsonb_build_object('id','c','text','Assume it will resolve itself'),
   jsonb_build_object('id','d','text','Shut down the entire feature immediately without discussion')),
 'b', 'Driver analysis is only useful if it ends in a specific, actionable finding — here, the indexing issue.', 'Intermediate', 'Cost Anomaly Analysis', 4),
(v_quiz_id, 'What should an anomaly detection baseline account for, to avoid false alarms?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Known seasonality and historical patterns'),
   jsonb_build_object('id','b','text','The CEO''s calendar'),
   jsonb_build_object('id','c','text','Stock market performance'),
   jsonb_build_object('id','d','text','The weather')),
 'a', 'A good baseline reflects expected seasonal and historical patterns so genuine anomalies stand out from normal fluctuation.', 'Intermediate', 'Cost Anomaly Analysis', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Trace a Cost Spike to Its Driver',
  'A driver-analysis exercise using a simulated breakdown of a cost increase.', 'Intermediate',
  'Total spend rose 18% month over month. Leadership wants to know exactly what caused it before approving next quarter''s budget.',
  jsonb_build_object('breakdown', jsonb_build_array(
    jsonb_build_object('service','Compute','contribution_points',3),
    jsonb_build_object('service','Storage','contribution_points',1),
    jsonb_build_object('service','Data Transfer (Egress)','contribution_points',13),
    jsonb_build_object('service','Managed Database','contribution_points',1)
  )),
  'Given the point breakdown of the 18-point total increase, identify the primary driver and classify it, then state one specific, plausible business cause.',
  array['Cost Analysis','Cost Anomaly Analysis','Data Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','primary_driver','label','Primary driver','expected','Data Transfer (Egress)','weight',3,'skill','Cost Analysis',
      'options', jsonb_build_array('Compute','Storage','Data Transfer (Egress)','Managed Database')),
    jsonb_build_object('key','plausible_cause','label','Most plausible business cause','expected','a new feature or traffic pattern increasing outbound data','weight',2,'skill','Cost Anomaly Analysis',
      'options', jsonb_build_array('a new feature or traffic pattern increasing outbound data','a change in employee headcount','a new office lease','a change in accounting software'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 8 — Budgeting
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Budgeting', 'Setting, tracking, and explaining variance against a cloud budget.', 'Intermediate', 8, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cloud Budgeting',
  'How cloud budgets get set, tracked, and reforecast, and how to explain variance to leadership.',
  'Intermediate', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Setting & Tracking a Cloud Budget', 'Budgets as a living tool, not a once-a-year exercise.', 1, 'Intermediate')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Setting a Cloud Budget',
  'Where a starting budget number actually comes from.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A cloud budget is a planned spending target for a team, product, or the company as a whole over a period — usually a quarter or a year — against which actual spend will later be measured.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Without a budget, "too much" and "on track" have no meaning — spend can only be judged as high or low relative to some target, and that target is the budget.'),
    jsonb_build_object('heading','How does it work?','body',
      'Budgets are typically built bottom-up (each team estimates its own planned usage and growth) and validated top-down (finance checks the sum against overall revenue and growth targets), reconciling the two into one agreed number.'),
    jsonb_build_object('heading','Real company example','body',
      'A team that set its budget purely top-down (finance picked a number with no team input) found it wildly unrealistic within six weeks, because it never accounted for a planned migration that would temporarily double compute cost — a case for always validating budgets against team-level plans.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Tracking Budget vs. Actual',
  'Turning a budget from a document into an ongoing practice.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Budget tracking is the recurring comparison of actual spend against the planned budget, typically reviewed weekly or monthly, to catch drift early rather than discovering a large overage at year-end.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A budget that is only checked once a year is nearly useless — by the time an overage is discovered, there is no time left to correct course. Frequent tracking is what makes a budget an operational tool.'),
    jsonb_build_object('heading','How does it work?','body',
      'Most organizations track budget consumption as a percentage-of-period-elapsed comparison: if 40% of the quarter has passed but 55% of the budget is already spent, that is an early warning sign worth investigating regardless of the raw dollar amount.'),
    jsonb_build_object('heading','Real company example','body',
      'A monthly tracking cadence caught that a team had already spent 70% of its quarterly budget by week six, giving leadership time to intervene and adjust scope — a problem that would have gone unnoticed under yearly-only tracking until it was too late to fix.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Explaining Variance to Leadership',
  'Turning a budget-vs-actual gap into a clear, credible story.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Variance is simply the gap between budgeted and actual spend, expressed as a dollar amount or percentage. Explaining variance means answering, credibly, why that gap exists.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Leadership does not just want the variance number — they want to know whether it reflects a one-time, explainable event or a structural problem that will recur every period going forward.'),
    jsonb_build_object('heading','How does it work?','body',
      'A strong variance explanation names the specific driver (tying back to the cost-analysis skills from the prior level), states whether it is one-time or ongoing, and — if ongoing — proposes either a budget revision or a corrective action, not just an apology.'),
    jsonb_build_object('heading','Real company example','body',
      'A 20% quarterly overage explained simply as "cloud costs went up" satisfied no one. The same overage explained as "a one-time data migration temporarily doubled storage cost for six weeks and is now back to baseline" was accepted immediately, because it was specific and clearly bounded.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Budgeting Quiz', 'Checks understanding of setting, tracking, and explaining variance on a cloud budget.', 'Intermediate', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the recommended approach for setting a cloud budget?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Purely top-down, with no team input'),
   jsonb_build_object('id','b','text','Bottom-up team estimates reconciled with top-down finance validation'),
   jsonb_build_object('id','c','text','Copy last year''s number exactly with no changes'),
   jsonb_build_object('id','d','text','Whatever the cloud provider recommends')),
 'b', 'Combining team-level bottom-up estimates with top-down validation produces the most realistic, agreed-upon budget.', 'Beginner', 'Budgeting', 1),
(v_quiz_id, 'True or False: A budget that is only reviewed once at year-end still gives leadership enough time to correct course.', 'true_false', null, 'false',
 'By year-end there is no time left to correct an overage — frequent tracking is what makes a budget operationally useful.', 'Beginner', 'Budgeting', 2),
(v_quiz_id, 'At week 6 of a 13-week quarter, a team has spent 70% of its quarterly budget. What does this suggest?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Nothing unusual — this is right on pace'),
   jsonb_build_object('id','b','text','A likely overage risk that warrants investigation now, not at quarter-end'),
   jsonb_build_object('id','c','text','The team should immediately double its budget'),
   jsonb_build_object('id','d','text','The budget was set too high')),
 'b', 'Spending 70% of budget at roughly 46% of the period elapsed is a clear early warning sign worth investigating.', 'Intermediate', 'Variance Analysis', 3),
(v_quiz_id, 'What makes a variance explanation credible to leadership?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Naming a specific driver and stating whether it is one-time or ongoing'),
   jsonb_build_object('id','b','text','Simply saying "costs went up"'),
   jsonb_build_object('id','c','text','Blaming the cloud provider with no detail'),
   jsonb_build_object('id','d','text','Avoiding the topic entirely')),
 'a', 'A credible explanation is specific and distinguishes one-time events from structural, recurring problems.', 'Intermediate', 'Variance Analysis', 4),
(v_quiz_id, 'A budget overage is confirmed to be a one-time, six-week data migration that has already ended. What should the variance explanation recommend?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A permanent increase to the budget going forward'),
   jsonb_build_object('id','b','text','No budget revision needed, since the cause was temporary and has ended'),
   jsonb_build_object('id','c','text','Firing the team responsible'),
   jsonb_build_object('id','d','text','Switching cloud providers')),
 'b', 'A confirmed one-time, resolved cause does not justify a permanent budget change — the explanation should say so clearly.', 'Intermediate', 'Variance Analysis', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Explain a Quarterly Budget Variance',
  'Write a credible variance explanation from budget-tracking data.', 'Intermediate',
  'A team budgeted $300,000 for the quarter and actually spent $354,000 — an 18% overage. Investigation shows $50,000 of the overage came from a one-time, now-completed data migration; the remaining $4,000 is normal month-to-month fluctuation.',
  jsonb_build_object('budget',300000,'actual',354000,'one_time_migration_cost',50000),
  'Classify whether this variance is primarily one-time or structural, and recommend whether next quarter''s budget should be permanently revised upward.',
  array['Budgeting','Variance Analysis','Executive Reporting'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','variance_type','label','Variance classification','expected','primarily one-time','weight',3,'skill','Variance Analysis',
      'options', jsonb_build_array('primarily one-time','primarily structural/ongoing','impossible to determine')),
    jsonb_build_object('key','budget_recommendation','label','Next-quarter budget recommendation','expected','no permanent increase needed','weight',3,'skill','Budgeting',
      'options', jsonb_build_array('no permanent increase needed','permanently increase budget by 18%','cut the budget in half','abandon budgeting entirely'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
