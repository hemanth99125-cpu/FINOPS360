-- ============================================================================
-- Levels 20-21: Negotiating Enterprise Agreements & Vendor Management ->
-- Building a Continuous FinOps Operating Model (Run-stage maturity).
-- Same shape as every prior level. Level 21 is the final curriculum level,
-- closing the loop back to the Crawl/Walk/Run maturity model from Level 3.
-- ============================================================================

-- ============================================================================
-- LEVEL 20 — Negotiating Enterprise Agreements & Vendor Management
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Negotiating Enterprise Agreements', 'Negotiating directly with a cloud provider once spend is large enough to warrant it.', 'Professional', 20, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Vendor Management at Scale',
  'What an Enterprise Agreement actually contains, and how to prepare for the negotiation itself.',
  'Professional', 1, 150) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Enterprise Agreements and Negotiation Leverage', 'What can be negotiated, and what data makes the case.', 1, 'Professional')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'What Is an Enterprise Agreement?',
  'The custom contract layer above standard published pricing.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'An Enterprise Agreement is a custom, negotiated contract between a company and a cloud provider — typically available once spend crosses a meaningful threshold — that can include discounts beyond standard commitment pricing, spend commitments in exchange for credits, and negotiated terms around support and growth.'),
    jsonb_build_object('heading','Why is it important?','body',
      'At sufficient scale, published pricing and standard commitment discounts leave real savings on the table compared to what a direct negotiation can achieve — this is a lever unavailable at smaller spend levels covered earlier in the program.'),
    jsonb_build_object('heading','How does it work?','body',
      'A typical agreement trades a multi-year spend commitment (often with built-in growth assumptions) for negotiated discount rates, service credits, or favorable terms — the negotiation is fundamentally a trade of certainty (for the provider) for a better rate (for the customer).'),
    jsonb_build_object('heading','Real company example','body',
      'A company that had been buying only standard Savings Plans found, once its spend crossed a meaningful threshold, that a direct Enterprise Agreement negotiation produced a materially better effective rate than any standard commitment program alone could offer.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Building the Data Case Before Negotiating',
  'What preparation actually looks like before sitting down with a vendor.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Before any negotiation, preparing a data case means quantifying current spend, realistic multi-year growth projections, current commitment coverage/utilization, and — where possible — competitive benchmarks from other providers'' pricing.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A negotiation without hard data underneath it is just asking for a favor. A negotiation backed by specific, defensible growth projections and utilization data gives the provider concrete numbers to build a counteroffer around.'),
    jsonb_build_object('heading','How does it work?','body',
      'The data case typically combines everything covered earlier in this program — forecasting (a defensible growth projection), commitment coverage/utilization (proof of good-faith existing usage), and unit economics (framing growth in business terms the provider''s account team also has to justify internally).'),
    jsonb_build_object('heading','Real company example','body',
      'A company entered a renewal negotiation with a detailed three-year growth forecast built from its own unit economics model, rather than a rough guess — the provider''s counteroffer was noticeably more favorable than a prior renewal negotiated with no comparable data behind it.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Avoiding Over-Commitment in Multi-Year Agreements',
  'The same laddering caution from earlier, at a much larger scale.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Enterprise Agreements often ask for a multi-year spend commitment based on projected growth. If that growth does not materialize as projected, the company can be contractually obligated to spend at a level it never actually reaches organically.'),
    jsonb_build_object('heading','Why is it important?','body',
      'This is the same over-commitment risk from the commitment discounts level, but at a much larger scale and a much longer, harder-to-unwind timeframe — a poorly negotiated multi-year agreement can lock in years of unfavorable terms.'),
    jsonb_build_object('heading','How does it work?','body',
      'A well-negotiated agreement includes explicit flexibility provisions — the ability to true-down if growth falls short, or renegotiate terms at a midpoint checkpoint — rather than a rigid commitment locked entirely to an initial, potentially optimistic projection.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that signed a multi-year agreement based on an aggressive growth projection, with no true-down provision, ended up contractually committed to spend levels its actual (lower) growth never reached — a mid-agreement renegotiation was required to correct the mismatch.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Negotiating Enterprise Agreements Quiz', 'Checks understanding of Enterprise Agreements, data-driven negotiation prep, and over-commitment risk.', 'Professional', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What does an Enterprise Agreement typically trade in exchange for negotiated discount rates?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A multi-year spend commitment'),
   jsonb_build_object('id','b','text','Nothing — the discount is unconditional'),
   jsonb_build_object('id','c','text','Ownership of the company'),
   jsonb_build_object('id','d','text','A one-time payment with no ongoing obligation')),
 'a', 'Enterprise Agreements typically trade a spend commitment for a negotiated rate — a larger-scale version of the commitment-discount trade-off.', 'Professional', 'FinOps Governance', 1),
(v_quiz_id, 'True or False: A negotiation with no supporting data is generally as effective as one backed by a detailed growth forecast and utilization data.', 'true_false', null, 'false',
 'A data-backed negotiation gives the provider concrete numbers to work with, generally producing a more favorable outcome than an unsupported request.', 'Professional', 'Financial Analysis', 2),
(v_quiz_id, 'What is the main risk of a multi-year Enterprise Agreement with no true-down provision?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','If growth falls short of projections, the company remains contractually obligated to the original spend level'),
   jsonb_build_object('id','b','text','There is no risk at all'),
   jsonb_build_object('id','c','text','The agreement automatically cancels itself'),
   jsonb_build_object('id','d','text','The provider is required to lower the price regardless')),
 'a', 'Without flexibility to true-down, an over-optimistic growth projection can leave the company locked into spend it never organically reaches.', 'Professional', 'Financial Analysis', 3),
(v_quiz_id, 'Which prior FinOps skill from this program is most directly useful in preparing a negotiation data case?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Forecasting and unit economics'),
   jsonb_build_object('id','b','text','None of the prior material is relevant'),
   jsonb_build_object('id','c','text','Only knowledge of office furniture pricing'),
   jsonb_build_object('id','d','text','Graphic design skills')),
 'a', 'A defensible growth forecast and business-framed unit economics are exactly what a negotiation data case is built from.', 'Professional', 'Forecasting', 4),
(v_quiz_id, 'A company is preparing for a renewal negotiation. What is the recommended first step?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Show up with no preparation and ask for a better price'),
   jsonb_build_object('id','b','text','Build a data case: current spend, growth projections, and coverage/utilization data'),
   jsonb_build_object('id','c','text','Threaten to cancel the contract immediately with no data'),
   jsonb_build_object('id','d','text','Sign whatever is offered without review')),
 'b', 'Preparation with hard data is the foundation of an effective negotiation, as covered throughout this lesson.', 'Professional', 'FinOps Governance', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Evaluate a Proposed Enterprise Agreement',
  'Spot the missing flexibility provision in a proposed multi-year deal.', 'Professional',
  'A cloud provider proposes a 3-year Enterprise Agreement based on an aggressive 40%-per-year growth projection, with the full commitment due regardless of actual growth and no mention of a mid-term review or true-down option.',
  jsonb_build_object('proposal_terms', jsonb_build_array(
    jsonb_build_object('term','3-year term based on 40%/year growth assumption'),
    jsonb_build_object('term','Full commitment due regardless of actual growth'),
    jsonb_build_object('term','No mid-term review or true-down mentioned')
  )),
  'Identify the single most important missing provision in this proposal, and explain the risk it would protect against.',
  array['FinOps Governance','Financial Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','missing_provision','label','Most important missing provision','expected','a true-down or mid-term review option','weight',3,'skill','FinOps Governance',
      'options', jsonb_build_array('a true-down or mid-term review option','a longer contract term','a lower headline discount rate','more marketing materials')),
    jsonb_build_object('key','risk_protected','label','Risk it protects against','expected','being locked into spend levels never actually reached if growth falls short','weight',3,'skill','Financial Analysis',
      'options', jsonb_build_array('being locked into spend levels never actually reached if growth falls short','the provider going out of business','a change in tax law','a change in company leadership'))
  )), v_module_id) returning id into v_challenge_id;

end $$;

-- ============================================================================
-- LEVEL 21 — Building a Continuous FinOps Operating Model
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Building a Continuous FinOps Operating Model', 'Closing the loop: reaching and sustaining Run-stage maturity across the whole practice.', 'Professional', 21, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Sustaining a Mature FinOps Practice',
  'Bringing every level of this program together into one continuously operating model.',
  'Professional', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'From Individual Skills to a Running Practice', 'Integrating everything learned into a single, continuous operating model.', 1, 'Professional')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Revisiting Crawl, Walk, Run — With the Full Toolkit',
  'What "Run" stage actually looks like once every skill in this program is in place.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Back in Level 3, "Run" stage maturity was described as treating cost like a first-class engineering metric: automated governance, cost-aware design decisions, and unit economics tracked continuously. Every level since has built one specific piece of what makes that possible.'),
    jsonb_build_object('heading','Why is it important?','body',
      'It is easy to treat each skill in this program — tagging, forecasting, KPIs, SQL, negotiation — as a separate topic. A Run-stage practice is what happens when they operate together, continuously, rather than as isolated one-off projects.'),
    jsonb_build_object('heading','How does it work?','body',
      'A running Run-stage practice has: governance-enforced tagging feeding accurate allocation, allocation feeding trustworthy showback/chargeback, trend and anomaly analysis feeding forecasts, forecasts feeding budgets and enterprise negotiations, and a KPI scorecard summarizing whether all of it is actually working — each piece feeding the next.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that had built every individual capability from this program still operated them as disconnected quarterly projects until someone mapped how each one''s output fed the next one''s input — only then did the practice start running continuously rather than being re-started from scratch each quarter.')
  )), 'concept', 10, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Where FinOps Fits as the Business Changes',
  'Why a mature practice keeps adapting rather than staying static once built.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A business that adopts new technology (a Kubernetes migration, a new cloud provider, an AI workload with an entirely new cost profile) requires the FinOps practice to extend to cover it — maturity is not a finished state, but an ongoing capacity to absorb new cost categories.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A practice built entirely around the assumptions of today''s infrastructure can be caught flat-footed by tomorrow''s — the Kubernetes-specific allocation challenges covered earlier in this program are exactly this pattern playing out for one specific technology shift.'),
    jsonb_build_object('heading','How does it work?','body',
      'A durable practice treats "how do we get visibility and governance over this new thing" as a standard, repeatable question to ask of any new technology adoption, applying the same Inform-Optimize-Operate lifecycle from Level 3 to whatever the business adopts next, rather than building bespoke processes reactively each time.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s FinOps team, having already been through one such adaptation for Kubernetes, handled a subsequent shift to a new AI/ML compute platform far faster the second time — not because the specific technology was familiar, but because the process for extending governance to something new was already well-practiced.')
  )), 'concept', 10, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'What Comes Next: A Career, Not a Checklist',
  'Closing thought on applying everything covered in this program.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'This program has covered the full FinOps skill set: cloud fundamentals, billing, allocation, showback/chargeback, cost analysis, budgeting, forecasting, optimization, commitment strategy, multi-cloud, unit economics, governance, KPIs, data analysis, SQL, executive communication, containers, and negotiation.'),
    jsonb_build_object('heading','Why is it important?','body',
      'No single company will need every one of these skills applied at once on day one — the value of covering all of them is knowing which lever to reach for as a company''s specific situation and maturity level demands it.'),
    jsonb_build_object('heading','How does it work?','body',
      'In practice, a FinOps career is a continuous loop of applying this full toolkit to whatever a specific organization''s current maturity and immediate problem actually is — sometimes that''s a first tagging cleanup at a Crawl-stage company, sometimes it''s negotiating an Enterprise Agreement at a Run-stage one.'),
    jsonb_build_object('heading','Real company example','body',
      'A FinOps professional who completed a program much like this one used the tagging and allocation skills in their first month at a new company (which was still Crawl-stage) long before ever touching the negotiation or Kubernetes material — the full toolkit''s value was in having it ready for whichever problem showed up first.')
  )), 'concept', 10, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Continuous FinOps Operating Model Quiz', 'Checks understanding of integrating the full FinOps toolkit into one continuously operating practice.', 'Professional', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What distinguishes a Run-stage FinOps practice from simply having completed every skill in this program once?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Run-stage means the skills operate together continuously, not as isolated one-off projects'),
   jsonb_build_object('id','b','text','Nothing — completing each skill once is sufficient'),
   jsonb_build_object('id','c','text','Run-stage only requires knowing SQL'),
   jsonb_build_object('id','d','text','Run-stage means spending has been minimized to zero')),
 'a', 'A Run-stage practice is defined by continuous, interconnected operation of these capabilities, not one-time completion.', 'Professional', 'FinOps Governance', 1),
(v_quiz_id, 'True or False: A mature FinOps practice, once built, requires no further adaptation as the business adopts new technology.', 'true_false', null, 'false',
 'Maturity is an ongoing capacity to absorb new cost categories, not a finished, static state — new technology adoption requires extending the practice.', 'Professional', 'FinOps Governance', 2),
(v_quiz_id, 'What lifecycle model from Level 3 should be applied whenever a business adopts a new technology?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Inform, Optimize, Operate'),
   jsonb_build_object('id','b','text','A completely new, unrelated model each time'),
   jsonb_build_object('id','c','text','No model is needed for new technology'),
   jsonb_build_object('id','d','text','Only the Optimize phase applies')),
 'a', 'The same Inform-Optimize-Operate lifecycle applies to any new technology adoption, giving a repeatable process rather than reinventing one each time.', 'Professional', 'FinOps Fundamentals', 3),
(v_quiz_id, 'A company has built every individual FinOps capability but still runs each as a disconnected quarterly project. What is missing?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Mapping how each capability''s output feeds the next one''s input, so they run continuously together'),
   jsonb_build_object('id','b','text','Nothing is missing — this is already Run-stage'),
   jsonb_build_object('id','c','text','More individual capabilities need to be built'),
   jsonb_build_object('id','d','text','The company should stop doing FinOps entirely')),
 'a', 'Having all the pieces is not the same as having them integrated into one continuously operating practice — that connection is what was missing.', 'Professional', 'FinOps Governance', 4),
(v_quiz_id, 'What determines which specific FinOps skill from this program a professional should apply first at a new company?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','That company''s specific current maturity level and immediate problem'),
   jsonb_build_object('id','b','text','Always negotiation, regardless of company size'),
   jsonb_build_object('id','c','text','Always SQL, regardless of the situation'),
   jsonb_build_object('id','d','text','The order the skills were taught in this program')),
 'a', 'The right first move depends entirely on the specific company''s maturity and immediate need, not a fixed, universal order.', 'Professional', 'FinOps Fundamentals', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Choose the Right First Move at a New Company',
  'Apply the full toolkit judgment: what to reach for first, given the situation.', 'Professional',
  'You join a new company as its first dedicated FinOps hire. Tagging is inconsistent, there is no budget process, and nobody has ever proposed a commitment discount purchase. This closely mirrors a Crawl-stage organization from earlier in this program.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','Inconsistent tagging'),
    jsonb_build_object('signal','No budget process'),
    jsonb_build_object('signal','No commitment discounts ever purchased')
  )),
  'Given this is a Crawl-stage organization, identify which single capability from this program should be tackled first, and explain why it must come before the others.',
  array['FinOps Governance', 'FinOps Fundamentals'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','first_move','label','First capability to tackle','expected','tagging and cost allocation','weight',3,'skill','FinOps Governance',
      'options', jsonb_build_array('tagging and cost allocation','negotiating an Enterprise Agreement','Kubernetes cost optimization','executive scorecard design')),
    jsonb_build_object('key','why_first','label','Why it must come first','expected','visibility/allocation has to exist before budgeting, optimization, or negotiation can be done credibly','weight',3,'skill','FinOps Fundamentals',
      'options', jsonb_build_array('visibility/allocation has to exist before budgeting, optimization, or negotiation can be done credibly','it is the easiest task','it requires no data at all','leadership specifically requested it'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
