-- ============================================================================
-- Level 1 — Introduction to FinOps & the Cloud Economics Mindset
-- The true entry point: sequence_order 1, before Level 2's technical cloud
-- foundations. Non-technical, career-framing intro to what FinOps is as a
-- discipline/career and why cloud economics differs from traditional IT
-- spend — sets up everything Levels 2+ build on.
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Introduction to FinOps', 'What a FinOps career looks like, and why cloud spend behaves so differently from traditional IT budgets.', 'Beginner', 1, 120)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'The FinOps Career Path',
  'Who works in FinOps, what they actually do day to day, and the economic shift that created the discipline in the first place.',
  'Beginner', 1, 120) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Why FinOps Exists', 'The economic shift behind the discipline, and what the job actually involves.', 1, 'Beginner')
returning id into v_module_id;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'What Does a FinOps Professional Actually Do?',
  'A realistic day-to-day picture of the role, before diving into any technical material.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'A FinOps professional sits between finance, engineering, and business leadership, translating cloud usage into cost that each group can understand and act on. The job mixes data analysis, financial reasoning, and a lot of plain communication.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Cloud spend is now one of the largest and fastest-growing line items at most technology companies, yet it is rarely anyone''s full-time job to manage it well — which is exactly the gap this career exists to fill.'),
    jsonb_build_object('heading','How does it work?','body',
      'A typical week might include reviewing a cost anomaly with an engineering team, building a variance explanation for finance, and presenting an optimization recommendation to a VP — the same three audiences you will practice writing for throughout this program.'),
    jsonb_build_object('heading','Real company example','body',
      'A company''s first dedicated FinOps hire spent their first month simply meeting with every engineering team to understand what they ran and why — before proposing a single change. Understanding the business came before the spreadsheet work.')
  )), 'concept', 8, 1) returning id into v_l1;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Why Cloud Spend Behaves Differently Than Traditional IT Budgets',
  'The economic shift from fixed, predictable costs to variable, usage-driven ones.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Traditional IT spend was capital expenditure: a company bought servers once a year in a large, predictable, finance-approved purchase. Cloud spend is operating expenditure: it changes daily based on what engineers actually run, with no single approval gate.'),
    jsonb_build_object('heading','Why is it important?','body',
      'This shift is the entire reason FinOps exists. A finance team used to budgeting a fixed annual hardware purchase has no natural process for a bill that can move 20% in either direction in a single month based on decisions made by individual engineers.'),
    jsonb_build_object('heading','How does it work?','body',
      'Variable cloud spend means the traditional "approve once a year" finance model has to be replaced with continuous visibility and lightweight, frequent decision-making — the Inform/Optimize/Operate lifecycle covered in the next level.'),
    jsonb_build_object('heading','Real company example','body',
      'A finance team accustomed to a fixed IT budget was blindsided by a 30% cloud cost increase mid-quarter, with no process to catch or explain it early — the exact failure mode that a functioning FinOps practice is built to prevent.')
  )), 'concept', 8, 2) returning id into v_l2;

insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Who Owns Cloud Cost? Everyone, a Little',
  'Why FinOps is a shared responsibility rather than one team''s job.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Unlike most cost categories, no single team fully controls cloud spend: engineers decide what to provision, finance sets and tracks budgets, and business leaders decide what features are worth building at all. FinOps coordinates across all three.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Treating cloud cost as purely a finance problem (auditing after the fact) or purely an engineering problem (asking engineers to self-police) both fail on their own — the discipline exists specifically to connect the two.'),
    jsonb_build_object('heading','How does it work?','body',
      'A functioning FinOps practice gives engineers visibility into the cost impact of their decisions, gives finance a forecast and budget they can actually track, and gives leadership a translated, business-relevant view of tradeoffs — without any one group having to become an expert in the others'' domain.'),
    jsonb_build_object('heading','Real company example','body',
      'A company that tried to fix cloud cost purely through a top-down finance mandate saw engineers quietly work around arbitrary limits that ignored real technical constraints — collaboration, not a mandate, produced the changes that stuck.')
  )), 'concept', 8, 3) returning id into v_l3;

insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Introduction to FinOps Quiz', 'Checks understanding of the FinOps role and why cloud economics differs from traditional IT.', 'Beginner', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What best describes the day-to-day work of a FinOps professional?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Writing application code full time'),
   jsonb_build_object('id','b','text','Translating cloud usage and cost between engineering, finance, and leadership'),
   jsonb_build_object('id','c','text','Only approving or denying every individual cloud purchase'),
   jsonb_build_object('id','d','text','Managing employee payroll')),
 'b', 'FinOps sits between three audiences, translating cost data into something each can act on.', 'Beginner', 'FinOps Fundamentals', 1),
(v_quiz_id, 'True or False: Traditional IT spend and cloud spend behave the same way financially.', 'true_false', null, 'false',
 'Traditional IT spend is fixed, annual capital expenditure; cloud spend is variable, continuous operating expenditure — a fundamentally different economic pattern.', 'Beginner', 'Cloud Economics', 2),
(v_quiz_id, 'Why can''t cloud cost be treated as purely a finance-owned problem?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Finance teams are not allowed to see cloud bills'),
   jsonb_build_object('id','b','text','Engineers make the day-to-day provisioning decisions that actually drive the cost'),
   jsonb_build_object('id','c','text','Cloud providers do not send finance any billing data'),
   jsonb_build_object('id','d','text','It actually can be, and should be, finance-only')),
 'b', 'Engineers control the underlying decisions, so a finance-only approach cannot see or influence the real cause of cost changes.', 'Beginner', 'FinOps Fundamentals', 3),
(v_quiz_id, 'A company imposes a strict top-down cloud spending cap with no engineering input. What is a likely outcome?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Engineers work around the cap in ways that ignore real technical constraints'),
   jsonb_build_object('id','b','text','Cloud spend instantly and permanently drops to zero'),
   jsonb_build_object('id','c','text','Engineering productivity increases with no tradeoffs'),
   jsonb_build_object('id','d','text','Nothing changes at all')),
 'a', 'A mandate imposed without engineering collaboration tends to produce workarounds rather than durable, well-reasoned change.', 'Beginner', 'FinOps Fundamentals', 4),
(v_quiz_id, 'What is the most accurate description of who "owns" cloud cost in a healthy FinOps practice?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Only the CFO'),
   jsonb_build_object('id','b','text','Only the engineering team that provisions resources'),
   jsonb_build_object('id','c','text','A shared responsibility across engineering, finance, and business leadership'),
   jsonb_build_object('id','d','text','The cloud provider')),
 'c', 'FinOps exists precisely because cloud cost accountability is shared across multiple groups, none of which can manage it alone.', 'Beginner', 'FinOps Fundamentals', 5);

insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Diagnose Why a Cost Conversation Went Wrong',
  'A first, non-technical exercise in spotting a collaboration failure.', 'Beginner',
  'Finance emailed engineering a spreadsheet demanding a 20% cloud cost cut within two weeks, with no explanation of which services or teams were involved. Engineering ignored it. Two months later, spend is unchanged and the relationship between the two teams has soured.',
  jsonb_build_object('signals', jsonb_build_array(
    jsonb_build_object('signal','No specific, actionable detail given to engineering'),
    jsonb_build_object('signal','No collaborative discussion before the demand was sent'),
    jsonb_build_object('signal','A hard deadline with no forecast/budget context behind it')
  )),
  'Identify the single biggest reason this cost-cutting effort failed, and recommend what should have happened instead.',
  array['FinOps Fundamentals','Business Communication','Stakeholder Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','root_cause','label','Primary reason for failure','expected','no collaboration or specific detail given to engineering','weight',3,'skill','FinOps Fundamentals',
      'options', jsonb_build_array('no collaboration or specific detail given to engineering','the 20% target was mathematically impossible','engineering does not care about cost at all','the email was sent on the wrong day')),
    jsonb_build_object('key','better_approach','label','What should have happened instead','expected','a collaborative review identifying specific opportunities together','weight',3,'skill','Stakeholder Communication',
      'options', jsonb_build_array('a collaborative review identifying specific opportunities together','a stricter deadline','escalating directly to the CEO','ignoring the cost increase entirely'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
