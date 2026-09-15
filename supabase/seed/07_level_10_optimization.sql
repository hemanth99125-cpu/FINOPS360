-- ============================================================================
-- Level 10 — Cost Optimization Strategies
-- Same shape as every prior level (supabase/seed/02_sample_level.sql):
-- learning_path -> course -> module -> 3 lessons -> quiz (5 qs) -> challenge.
--
-- Why this topic for Level 10: Level 3 introduced the FinOps lifecycle
-- (Inform -> Optimize -> Operate) and Levels 4-9 have been entirely
-- Inform-phase work (billing, allocation, showback, analysis, budgeting,
-- forecasting). Nothing so far has covered Optimize in depth — this is the
-- natural next slice, using the Rightsizing / Storage Optimization /
-- Network Optimization skill_category values already seeded in
-- 01_skills.sql but never exercised by a quiz or challenge until now.
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Cost Optimization Strategies', 'Turning visible cost into lower cost: rightsizing, storage tiering, and network optimization.', 'Advanced', 10, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'The Optimize Phase',
  'The three highest-leverage optimization levers, and how to tell which one a given workload actually needs.',
  'Advanced', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Rightsizing, Storage, and Network Optimization', 'Matching resources to actual usage across all three cost categories.', 1, 'Advanced')
returning id into v_module_id;

-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Rightsizing: Matching Compute to Actual Usage',
  'Finding and fixing oversized, underutilized compute.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Rightsizing is the practice of changing a resource''s size (or quantity) to match its actual, observed utilization, instead of the size someone guessed it would need when it was first provisioned.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Oversized compute is one of the single largest sources of avoidable cloud waste. A virtual machine running at 10% average CPU utilization is not a functioning system that happens to be efficient — it is nearly always a candidate for a smaller, cheaper size with no performance impact.'),
    jsonb_build_object('heading','How does it work?','body',
      'A rightsizing review looks at utilization data (CPU, memory, and sometimes network) over a meaningful window — long enough to capture normal peaks, not just a quiet afternoon — and recommends the smallest size that still comfortably covers observed peak demand, with a safety margin.'),
    jsonb_build_object('heading','Real company example','body',
      'A fleet of database servers running at a consistent 15% CPU utilization was downsized two instance sizes, cutting that fleet''s cost by more than half with zero measurable performance change — the original size had simply never been revisited since a one-time launch-day guess.')
  )), 'concept', 10, 1) returning id into v_l1;

-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Storage Optimization: Tiering and Lifecycle Policies',
  'Making sure data sits on storage that matches how often it is actually accessed.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Storage optimization means moving data to the cheapest storage tier that still meets its actual access-frequency and durability needs, using automated lifecycle policies rather than manual, one-off cleanups.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Storage cost compounds silently: data almost never gets deleted, so a company''s storage footprint only grows, and most of that growth is data that is rarely or never read again after the first few weeks.'),
    jsonb_build_object('heading','How does it work?','body',
      'A lifecycle policy defines rules like "after 30 days with no access, move to infrequent-access tier; after 180 days, move to archive tier" — applied automatically by the cloud provider, so the optimization happens continuously without a person re-reviewing it every month.'),
    jsonb_build_object('heading','Real company example','body',
      'A media company found seven years of raw video source files sitting in its most expensive, fastest-access storage tier, almost none of it touched after the first month post-upload. A lifecycle policy alone — no data deleted, nothing re-architected — cut that storage line item by roughly 70%.')
  )), 'concept', 10, 2) returning id into v_l2;

-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Network Optimization: Reducing Data Transfer Cost',
  'Cutting egress and inter-region transfer cost without changing what the product does.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Network optimization reduces the cost of moving data — especially egress (leaving the provider''s network) and cross-region transfer — which is often the least-understood line item on a cloud bill despite sometimes being one of the largest.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Unlike compute or storage, network cost is easy to miss because no single team "owns" a resource called network — it is a byproduct of how everything else is architected, so it tends to go unmanaged until someone specifically goes looking for it.'),
    jsonb_build_object('heading','How does it work?','body',
      'Common levers include serving cacheable content through a content delivery network instead of egressing it repeatedly from origin, keeping chatty services in the same region to avoid cross-region transfer fees, and compressing large payloads before they cross a billed boundary.'),
    jsonb_build_object('heading','Real company example','body',
      'A company serving large images directly from origin storage on every request cut its egress cost by roughly 80% by putting a content delivery network in front of that storage — the images themselves never changed, only how repeatedly they were re-fetched from the expensive source.')
  )), 'concept', 10, 3) returning id into v_l3;

-- ---------------------------------------------------------------------------
insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Cost Optimization Strategies Quiz', 'Checks understanding of rightsizing, storage tiering, and network optimization.', 'Advanced', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'A virtual machine consistently runs at 15% CPU utilization. What is the recommended first action?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Leave it as-is, since it is functioning correctly'),
   jsonb_build_object('id','b','text','Rightsize it to a smaller instance size'),
   jsonb_build_object('id','c','text','Immediately delete it'),
   jsonb_build_object('id','d','text','Increase its size for safety')),
 'b', 'Consistently low utilization is the classic signal for rightsizing to a smaller, cheaper size, not deletion or leaving it unchanged.', 'Beginner', 'Rightsizing', 1),
(v_quiz_id, 'True or False: A storage lifecycle policy requires someone to manually move each file to a cheaper tier.', 'true_false', null, 'false',
 'Lifecycle policies apply automatically based on rules like time-since-last-access, with no manual per-file action needed.', 'Beginner', 'Storage Optimization', 2),
(v_quiz_id, 'Why is network/egress cost often overlooked compared to compute or storage?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','It is always the smallest line item, so it never matters'),
   jsonb_build_object('id','b','text','No single team "owns" it the way a team owns a server or a database'),
   jsonb_build_object('id','c','text','Cloud providers do not track it'),
   jsonb_build_object('id','d','text','It only applies to on-premises infrastructure')),
 'b', 'Network cost is a byproduct of architecture decisions made across many teams, so it lacks a natural single owner and tends to go unmanaged.', 'Intermediate', 'Network Optimization', 3),
(v_quiz_id, 'A company repeatedly serves the same large images directly from origin storage on every request. What is the most effective network optimization?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Delete the images'),
   jsonb_build_object('id','b','text','Put a content delivery network in front of the storage to serve cached copies'),
   jsonb_build_object('id','c','text','Move the images to a different cloud provider'),
   jsonb_build_object('id','d','text','Increase the size of the origin storage')),
 'b', 'A CDN caches and serves the content close to users, dramatically cutting repeated egress from the expensive origin source.', 'Intermediate', 'Network Optimization', 4),
(v_quiz_id, 'What should a rightsizing review measure utilization over, and why?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A single quiet afternoon, since that is the easiest data to pull'),
   jsonb_build_object('id','b','text','A window long enough to capture normal peak demand, not just typical usage'),
   jsonb_build_object('id','c','text','Exactly one minute, for precision'),
   jsonb_build_object('id','d','text','Utilization does not need to be measured at all')),
 'b', 'Sizing off a quiet period risks undersizing for real peaks — the review window has to include normal peak demand.', 'Advanced', 'Rightsizing', 5);

-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Prioritize Three Optimization Opportunities',
  'Rank rightsizing, storage, and network opportunities by dollar impact.', 'Advanced',
  'A cost review surfaces three opportunities at once. Leadership has time to fund only one initiative this quarter and wants a single, clearly justified recommendation.',
  jsonb_build_object('opportunities', jsonb_build_array(
    jsonb_build_object('opportunity','Rightsize an over-provisioned compute fleet (avg 12% utilization)','estimated_monthly_savings',18000),
    jsonb_build_object('opportunity','Apply lifecycle policies to seven years of rarely-accessed storage','estimated_monthly_savings',6500),
    jsonb_build_object('opportunity','Add a CDN in front of frequently-served static assets','estimated_monthly_savings',4200)
  )),
  'Given the three estimated monthly savings figures, identify which single opportunity should be funded first this quarter, and classify it into Compute / Storage / Networking.',
  array['Rightsizing','Cost Optimization','Financial Analysis'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','top_opportunity','label','Highest-priority opportunity','expected','Rightsize an over-provisioned compute fleet (avg 12% utilization)','weight',3,'skill','Rightsizing',
      'options', jsonb_build_array('Rightsize an over-provisioned compute fleet (avg 12% utilization)','Apply lifecycle policies to seven years of rarely-accessed storage','Add a CDN in front of frequently-served static assets')),
    jsonb_build_object('key','category','label','Cost category','expected','Compute','weight',2,'skill','Cost Optimization',
      'options', jsonb_build_array('Compute','Storage','Networking'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
