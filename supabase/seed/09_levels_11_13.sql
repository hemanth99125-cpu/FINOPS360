-- ============================================================================
-- Levels 11-13: Commitment Discounts Deep Dive -> Multi-Cloud FinOps ->
-- Unit Economics & Cloud ROI. Same shape as every prior level.
-- ============================================================================

-- ============================================================================
-- LEVEL 11 — Commitment Discounts Deep Dive
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Commitment Discounts Deep Dive', 'Building an actual Reserved Instance / Savings Plan / CUD portfolio, not just knowing they exist.', 'Advanced', 11, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Managing a Commitment Portfolio',
  'Coverage vs. utilization, laddering commitment terms, and avoiding over-commitment risk.',
  'Advanced', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Coverage, Utilization, and Commitment Risk', 'The two metrics every commitment strategy is judged on.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Coverage vs. Utilization: The Two Metrics That Matter',
  'Why buying a commitment is only half the job — using it is the other half.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Coverage measures what percentage of eligible usage is running under a commitment discount rather than on-demand pricing. Utilization measures what percentage of the commitment you already bought is actually being used, rather than sitting unused and wasted.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Low coverage means you are leaving savings on the table by paying on-demand rates unnecessarily. Low utilization means you already paid for a commitment and are not even using it — arguably worse, since that money is already spent with nothing to show for it.'),
    jsonb_build_object('heading','How does it work?','body',
      'A healthy commitment portfolio is tracked on both metrics continuously: coverage should trend upward for stable workloads, while utilization should stay close to 100% — any commitment sitting at 60% utilization for months is a sign it was sized wrong or the underlying workload changed.'),
    jsonb_build_object('heading','Real company example','body',
      'A team proudly reported 90% commitment coverage, but a closer look showed utilization on part of that portfolio was only 55% — they had over-bought for a workload that had since shrunk, effectively paying for capacity nobody used.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Laddering Commitment Terms',
  'Avoiding the trap of locking in one giant, all-at-once, multi-year bet.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Laddering means spreading commitment purchases across multiple start dates and terms (for example, a mix of 1-year and 3-year commitments purchased over time) instead of buying one enormous commitment on a single day.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A single giant commitment locks in today''s usage level as a long-term bet. If the business shrinks, pivots, or migrates workloads, that entire commitment can go underutilized at once — laddering limits how much risk is concentrated in any one purchase.'),
    jsonb_build_object('heading','How does it work?','body',
      'Instead of committing to 100% of steady-state usage in one purchase, a laddered approach commits to a base layer now and adds incremental commitments over subsequent quarters as usage patterns prove out, with terms staggered so they don''t all expire (or all get purchased) at once.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that bought one enormous 3-year commitment right before a major architecture migration was stuck paying for capacity an old system no longer needed, with no way to unwind the purchase — a laddered approach would have left much less exposed at that single point in time.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'When Not to Commit',
  'Recognizing the workloads that should stay on-demand.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Not every workload is a good commitment candidate. Highly variable, short-lived, or soon-to-be-decommissioned workloads are often better left on flexible on-demand or spot pricing, even though the per-unit rate is higher.'),
    jsonb_build_object('heading','Why is it important?','body',
      'The pressure to maximize "coverage" as a headline metric can push teams to commit on workloads that are a poor fit, trading a small rate discount for real flexibility risk later.'),
    jsonb_build_object('heading','How does it work?','body',
      'Before committing, ask: is this workload''s size likely to still exist a year from now? Is it a temporary migration artifact? Is it experimental and likely to be cut? A "no" to stability on any of these is a strong signal to stay on-demand regardless of the discount available.'),
    jsonb_build_object('heading','Real company example','body',
      'A team was pressured to commit on a workload supporting a product that leadership was already quietly considering sunsetting. Staying on-demand for six more months, until the sunset decision was final, avoided an otherwise-wasted multi-year commitment.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Commitment Discounts Quiz', 'Checks understanding of coverage, utilization, laddering, and when to avoid committing.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'A team has 90% commitment coverage but only 55% utilization on part of that portfolio. What does this indicate?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Everything is optimal — high coverage is all that matters'),
   jsonb_build_object('id','b','text','They over-bought commitments relative to actual usage'),
   jsonb_build_object('id','c','text','The cloud provider made a billing error'),
   jsonb_build_object('id','d','text','Utilization does not matter if coverage is high')),
 'b', 'High coverage with low utilization means commitments were purchased that exceed actual usage — money spent on unused capacity.', 'Advanced', 'Commitment Management', 1),
(v_quiz_id, 'True or False: Buying one large, multi-year commitment all at once is generally safer than laddering purchases over time.', 'true_false', null, 'false',
 'Laddering spreads risk across multiple purchases and terms; one large purchase concentrates the entire risk in a single bet.', 'Advanced', 'Commitment Management', 2),
(v_quiz_id, 'Which workload characteristic is the strongest signal to stay on-demand rather than commit?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Stable usage expected to continue for years'),
   jsonb_build_object('id','b','text','A workload likely to be decommissioned soon'),
   jsonb_build_object('id','c','text','Predictable, steady traffic'),
   jsonb_build_object('id','d','text','A production database running continuously')),
 'b', 'Workloads likely to be decommissioned are poor commitment candidates regardless of the discount, since the commitment would outlive the need.', 'Advanced', 'Commitment Management', 3),
(v_quiz_id, 'What is the main risk of purchasing one enormous commitment in a single transaction?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','It is against cloud provider policy'),
   jsonb_build_object('id','b','text','If usage changes, the entire commitment can go underutilized at once'),
   jsonb_build_object('id','c','text','It always costs more than smaller purchases'),
   jsonb_build_object('id','d','text','There is no risk at all')),
 'b', 'A single large purchase concentrates all commitment risk into one point in time and one usage assumption.', 'Advanced', 'Commitment Management', 4),
(v_quiz_id, 'What two metrics should every commitment discount strategy track continuously?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Coverage and utilization'),
   jsonb_build_object('id','b','text','Only the total dollar amount spent'),
   jsonb_build_object('id','c','text','Employee headcount and office square footage'),
   jsonb_build_object('id','d','text','Stock price and revenue')),
 'a', 'Coverage (how much eligible usage is committed) and utilization (how much of the commitment is actually used) together tell the full story.', 'Advanced', 'Commitment Management', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Evaluate a Commitment Purchase Proposal',
  'Decide whether a proposed commitment purchase is well-timed.', 'Advanced',
  'A team wants to buy a single 3-year commitment covering 100% of their current compute usage. The team is in the middle of a major architecture migration expected to change their compute footprint significantly within 6 months.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','Mid-migration, footprint expected to change significantly'),
    jsonb_build_object('signal','Proposal covers 100% of current usage in one purchase'),
    jsonb_build_object('signal','3-year term with no laddering')
  )),
  'Recommend whether this commitment purchase should proceed as proposed, and justify the recommendation.',
  array['Commitment Management','Financial Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','recommendation','label','Recommendation','expected','delay or reduce the commitment until after the migration','weight',3,'skill','Commitment Management',
      'options', jsonb_build_array('delay or reduce the commitment until after the migration','proceed exactly as proposed','commit for 10 years instead','cancel all commitment purchases forever')),
    jsonb_build_object('key','reasoning','label','Primary reasoning','expected','usage is about to change, creating over-commitment risk','weight',2,'skill','Financial Analysis',
      'options', jsonb_build_array('usage is about to change, creating over-commitment risk','3-year terms are never a good idea','the team asked nicely','it is always right to maximize coverage'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 12 — Multi-Cloud FinOps
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Multi-Cloud FinOps', 'Comparing and managing cost fairly across AWS, Azure, and Google Cloud at once.', 'Advanced', 12, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Working Across Multiple Providers',
  'Why the same workload can look completely different in cost across three providers with three different vocabularies.',
  'Advanced', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Normalizing Cost Across Providers', 'Comparing apples to apples across AWS, Azure, and GCP.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Multi-Cloud Happens (and Why It''s Hard to Manage)',
  'Companies rarely choose multi-cloud on purpose — it usually accumulates.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Multi-cloud means running production workloads on more than one cloud provider at once. Some companies choose this deliberately for resilience or negotiating leverage; far more end up there through acquisitions, or different teams independently picking different providers over time.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Each additional provider multiplies the complexity of every FinOps practice covered so far — tagging, allocation, budgeting, and forecasting all now have to work across systems that don''t share a common billing format.'),
    jsonb_build_object('heading','How does it work?','body',
      'A FinOps analyst working multi-cloud typically maintains a normalized internal cost model that maps each provider''s specific billing categories (and discount programs) into common, comparable categories, so a leadership report can show "total compute cost" as one number regardless of provider.'),
    jsonb_build_object('heading','Real company example','body',
      'A company discovered it was running near-identical workloads on both AWS and GCP purely because two teams, formed from an acquisition, had never compared notes — consolidating onto one provider for that workload alone cut cost meaningfully with no feature loss.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Comparing Discount Programs Across Providers',
  'The same underlying discount, three different names and slightly different rules.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'AWS offers Reserved Instances and Savings Plans, Azure offers Reserved VM Instances and Azure Savings Plans, and Google Cloud offers Committed Use Discounts. All three trade a usage commitment for a lower rate, but eligibility, flexibility, and cancellation terms differ meaningfully between them.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Assuming one provider''s commitment rules apply to another is a common and costly multi-cloud mistake — for example, some providers'' commitments can be resold or exchanged more flexibly than others.'),
    jsonb_build_object('heading','How does it work?','body',
      'Before recommending a commitment strategy on any given provider, verify that provider''s specific rules for flexibility, term lengths, and what happens if usage changes — do not assume what worked on one provider transfers directly to another.'),
    jsonb_build_object('heading','Real company example','body',
      'A team assumed their AWS Savings Plan exchange flexibility would work the same way for a similar Azure commitment, and only discovered the difference in terms after they were already locked in — a lesson in verifying provider-specific rules before committing, not after.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Building a Unified Multi-Cloud Cost Report',
  'Giving leadership one number they can trust, regardless of how many providers are behind it.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A unified multi-cloud report presents cost, allocation, and trend data in one consistent view, even though the underlying data comes from multiple providers with different formats, currencies, and billing cycles.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Leadership does not want three separate reports in three different formats to mentally reconcile themselves — a unified view is what actually gets used to make decisions.'),
    jsonb_build_object('heading','How does it work?','body',
      'Building this typically requires normalizing each provider''s raw usage/billing export into a common schema (service category, team, environment) before any reporting or dashboarding happens — the same tagging and allocation principles from earlier levels, just applied consistently across more than one source.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s first unified multi-cloud dashboard revealed, for the first time, that one product line was actually running at a significant loss once its full multi-provider infrastructure cost was combined into one number — a fact invisible when each provider''s bill was reviewed separately.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Multi-Cloud FinOps Quiz', 'Checks understanding of multi-cloud complexity, discount program differences, and unified reporting.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What is the most common reason companies end up multi-cloud?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A single, deliberate strategic decision made once'),
   jsonb_build_object('id','b','text','Accumulation over time — acquisitions or independent team decisions'),
   jsonb_build_object('id','c','text','Cloud providers require it by law'),
   jsonb_build_object('id','d','text','It is always cheaper than single-cloud')),
 'b', 'Multi-cloud usually accumulates gradually rather than resulting from one deliberate, coordinated decision.', 'Beginner', 'Multi-Cloud FinOps', 1),
(v_quiz_id, 'True or False: AWS Savings Plans, Azure Savings Plans, and GCP Committed Use Discounts all have identical flexibility and cancellation terms.', 'true_false', null, 'false',
 'Each provider''s commitment program has its own specific rules — assuming they are identical is a common and costly mistake.', 'Advanced', 'Multi-Cloud FinOps', 2),
(v_quiz_id, 'What is the primary purpose of a unified multi-cloud cost report?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','To let leadership see one consistent view instead of reconciling separate provider reports themselves'),
   jsonb_build_object('id','b','text','To reduce the cloud bill automatically'),
   jsonb_build_object('id','c','text','To replace the need for tagging'),
   jsonb_build_object('id','d','text','It has no real purpose')),
 'a', 'A unified view is what actually gets used for decisions — separate, differently-formatted reports rarely do.', 'Advanced', 'Multi-Cloud FinOps', 3),
(v_quiz_id, 'A company discovers near-identical workloads running on two different providers due to a past acquisition. What is the most direct optimization opportunity?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Consolidate the duplicate workload onto a single provider'),
   jsonb_build_object('id','b','text','Add a third provider for balance'),
   jsonb_build_object('id','c','text','Ignore it since both providers are already paid for'),
   jsonb_build_object('id','d','text','Immediately shut down both workloads')),
 'a', 'Eliminating true duplication by consolidating onto one provider is the most direct savings opportunity here.', 'Advanced', 'Multi-Cloud FinOps', 4),
(v_quiz_id, 'What must happen before multi-cloud cost data can be meaningfully compared across providers?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Normalizing each provider''s categories into a common schema'),
   jsonb_build_object('id','b','text','Switching entirely to a single provider first'),
   jsonb_build_object('id','c','text','Nothing — all providers report identically by default'),
   jsonb_build_object('id','d','text','Converting all costs to cryptocurrency')),
 'a', 'Without normalization, each provider''s different categories and formats cannot be fairly compared.', 'Advanced', 'Multi-Cloud FinOps', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Spot a Multi-Cloud Duplication Opportunity',
  'Find the consolidation opportunity hiding in two providers'' bills.', 'Advanced',
  'A post-acquisition review shows Team A runs its analytics pipeline on AWS ($40,000/month) and Team B, from the acquired company, runs a nearly identical analytics pipeline on GCP ($35,000/month), serving overlapping internal use cases.',
  jsonb_build_object('teams', jsonb_build_array(
    jsonb_build_object('team','Team A','provider','AWS','monthly_cost',40000),
    jsonb_build_object('team','Team B','provider','GCP','monthly_cost',35000)
  )),
  'Identify the highest-value recommendation given this duplication, and state which provider is the more reasonable choice to consolidate onto based on the lower current cost.',
  array['Multi-Cloud FinOps','Cost Optimization','Financial Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','recommendation','label','Recommendation','expected','consolidate onto one provider','weight',3,'skill','Multi-Cloud FinOps',
      'options', jsonb_build_array('consolidate onto one provider','add a third pipeline for redundancy','do nothing, both are already funded','switch both to a fourth provider')),
    jsonb_build_object('key','lower_cost_provider','label','Provider with lower current cost','expected','GCP','weight',2,'skill','Financial Analysis',
      'options', jsonb_build_array('AWS','GCP'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 13 — Unit Economics & Cloud ROI
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Unit Economics & Cloud ROI', 'Moving from "what did we spend" to "was it worth it" — cost per customer, per transaction, and cloud investment ROI.', 'Advanced', 13, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cost Per Unit of Value',
  'Turning a total cost number into a metric the business can actually judge itself against.',
  'Advanced', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Unit Economics and Cloud Investment', 'Cost per customer/transaction, and evaluating cloud spend as an investment.', 1, 'Advanced')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'What Is Unit Economics, and Why Total Spend Isn''t Enough',
  'Why "cost per customer" tells a very different story than a raw total.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Unit economics expresses cost relative to a meaningful business unit — cost per customer, per transaction, per API call — instead of as a raw total that grows for reasons that could be entirely healthy, like business growth.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Total cloud spend doubling sounds alarming; cost per customer staying flat while customer count doubled is actually a story of healthy, efficient growth. Without a unit metric, these two very different situations look identical on a top-line chart.'),
    jsonb_build_object('heading','How does it work?','body',
      'Building a unit metric requires connecting cost data (from the allocation work covered earlier) to a business metric like active customers or transaction volume, tracked over the same period, then dividing one by the other consistently over time.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s cloud bill tripled in a year, alarming the board — until unit economics showed cost per active user had actually fallen by 20% over the same period, because user growth had outpaced infrastructure growth. The story completely reversed once "per unit" replaced "total."')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Calculating and Tracking Cost Per Unit',
  'The mechanics of building a trustworthy unit economics metric.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Calculating cost per unit means picking a denominator that genuinely reflects the value being delivered (active users, orders processed, API requests served) and dividing allocated infrastructure cost for that product by that denominator, consistently, period over period.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Picking the wrong denominator — one that does not actually track with what drives the cost — produces a unit metric that looks stable or improving for the wrong reasons, misleading the same leadership it was meant to inform.'),
    jsonb_build_object('heading','How does it work?','body',
      'A good unit metric is chosen by asking: what business activity, if it doubled, would we expect infrastructure cost to roughly double alongside? That activity — not just "number of customers" as a default — is usually the right denominator.'),
    jsonb_build_object('heading','Real company example','body',
      'A company initially tracked cost per customer, but discovered infrastructure cost actually scaled much more closely with transaction volume than customer count, since some customers transacted 100x more than others — switching the denominator produced a far more meaningful, stable metric.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Evaluating Cloud Spend as an Investment (ROI and TCO)',
  'Judging whether a cloud investment paid off, not just how much it cost.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Return on investment (ROI) and total cost of ownership (TCO) frame a cloud spending decision — like migrating a system, or investing in a new platform — as an investment to be judged against the value it generates, not just a cost to be minimized.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Not every cost increase is bad, and not every cost decrease is good — a spending increase that unlocks meaningfully more revenue or reliability can be a great decision, and a FinOps analyst needs the framework to say so credibly.'),
    jsonb_build_object('heading','How does it work?','body',
      'A basic ROI analysis compares the total cost of an investment (including migration effort, not just ongoing infrastructure) against its expected quantified benefit (revenue enabled, cost avoided elsewhere, risk reduced) over a defined time horizon.'),
    jsonb_build_object('heading','Real company example','body',
      'A proposed database migration looked purely like a $200,000 cost increase until the ROI analysis included the outage-related revenue it was expected to prevent — at which point the "cost" was recognized as a strongly positive-ROI investment, not a budget problem.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Unit Economics & Cloud ROI Quiz', 'Checks understanding of unit economics, denominator selection, and ROI/TCO framing.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'A company''s total cloud spend tripled, but cost per active user fell 20% over the same period. What does this indicate?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','A serious, unexplained cost problem'),
   jsonb_build_object('id','b','text','Healthy, efficient growth — infrastructure spend grew slower than the user base'),
   jsonb_build_object('id','c','text','A billing error'),
   jsonb_build_object('id','d','text','Nothing meaningful can be concluded')),
 'b', 'Falling cost per unit alongside rising total spend is the signature of efficient growth, not a cost problem.', 'Advanced', 'Unit Economics', 1),
(v_quiz_id, 'True or False: The denominator for a unit economics metric should always be "number of customers," regardless of the business.', 'true_false', null, 'false',
 'The right denominator is whatever business activity infrastructure cost actually scales with — sometimes that''s transactions or requests, not raw customer count.', 'Advanced', 'Unit Economics', 2),
(v_quiz_id, 'What is the main purpose of a return-on-investment (ROI) analysis for a cloud spending decision?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','To always recommend the cheapest possible option'),
   jsonb_build_object('id','b','text','To judge a cost increase against the value it is expected to generate'),
   jsonb_build_object('id','c','text','To avoid ever discussing cost with leadership'),
   jsonb_build_object('id','d','text','To replace budgeting entirely')),
 'b', 'ROI frames spend as an investment to be judged by its returns, not simply minimized.', 'Advanced', 'Cloud Economics', 3),
(v_quiz_id, 'A proposed migration costs $200,000 but is expected to prevent an estimated $500,000 in outage-related revenue loss. How should this be framed?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','As a pure cost increase to be rejected'),
   jsonb_build_object('id','b','text','As a positive-ROI investment given the expected benefit'),
   jsonb_build_object('id','c','text','As irrelevant to the FinOps discussion'),
   jsonb_build_object('id','d','text','As a project that should be delayed indefinitely')),
 'b', 'Weighing the cost against the quantified expected benefit shows this is a strongly positive-ROI investment, not simply a cost to minimize.', 'Advanced', 'Cloud Economics', 4),
(v_quiz_id, 'Why might "cost per customer" be the wrong unit economics metric for a company with highly variable per-customer usage?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Because some customers use 100x more resources than others, so customer count alone does not track with cost'),
   jsonb_build_object('id','b','text','Because customers should never be counted'),
   jsonb_build_object('id','c','text','Because it is too easy to calculate'),
   jsonb_build_object('id','d','text','There is no reason it would ever be wrong')),
 'a', 'When usage varies widely across customers, a usage-based denominator like transaction volume often tracks cost far more accurately.', 'Advanced', 'Unit Economics', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Choose the Right Unit Economics Denominator',
  'Pick the metric that actually tracks with infrastructure cost.', 'Advanced',
  'A company wants a unit economics metric for its API platform. Data shows infrastructure cost correlates strongly with API request volume, but only weakly with the number of registered accounts (many accounts are dormant; a small number drive nearly all request volume).',
  jsonb_build_object('candidates', jsonb_build_array(
    jsonb_build_object('metric','Registered accounts','correlation_with_cost','weak'),
    jsonb_build_object('metric','API request volume','correlation_with_cost','strong')
  )),
  'Recommend which denominator should be used for this platform''s unit economics metric, and justify the choice using the correlation data given.',
  array['Unit Economics','Data Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','denominator','label','Recommended denominator','expected','API request volume','weight',3,'skill','Unit Economics',
      'options', jsonb_build_array('Registered accounts','API request volume')),
    jsonb_build_object('key','justification','label','Justification','expected','it correlates strongly with actual infrastructure cost','weight',2,'skill','Data Analysis',
      'options', jsonb_build_array('it correlates strongly with actual infrastructure cost','it is a rounder number','accounts are easier to count','it was used last year'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
