-- ============================================================================
-- Level 9 — Forecasting (and the interactive Cloud Cost Simulator)
-- Same shape as prior levels, with one addition: Lesson 3 is a
-- lesson_type='simulation' lesson whose content includes a `simulator` key
-- (see lib/types.ts / components/CostSimulator.tsx). LessonClient renders the
-- interactive simulator automatically whenever that key is present.
-- ============================================================================
do $$
declare
  v_path_id uuid; v_course_id uuid; v_module_id uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_quiz_id uuid; v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Forecasting', 'Projecting future cloud spend, and testing "what if" changes before committing to them.', 'Intermediate', 9, 160)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Forecasting Cloud Spend',
  'How forecasts get built, why they drift, and how to model the savings from a rightsizing or commitment decision before making it.',
  'Intermediate', 1, 160) returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Forecasting & Scenario Modeling', 'Projecting spend forward, and modeling changes before they happen.', 1, 'Intermediate')
returning id into v_module_id;

-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'What Forecasting Is (and Isn''t)',
  'Projecting future spend from trend and business context, not guessing.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Forecasting is the practice of projecting future cloud spend based on historical trend, known upcoming changes (new features, planned migrations, headcount growth), and seasonality — producing a number the business can plan against.'),
    jsonb_build_object('heading','Why is it important?','body',
      'Budgets (from the prior level) need a starting number to be set against, and that number should come from a forecast, not a guess. A good forecast also gives you the baseline that turns an "unusual" reading into a real anomaly, and an "expected" one into nothing worth escalating.'),
    jsonb_build_object('heading','How does it work?','body',
      'A simple forecast extends the recent trend line (e.g., a moving average of the last 3-6 months growth rate) forward, then adjusts it for anything already known — a planned migration, a scheduled discount purchase, a seasonal spike like a holiday shopping period.'),
    jsonb_build_object('heading','Real company example','body',
      'A retailer''s naive trend-only forecast missed badly every November because it did not account for the known, recurring holiday traffic spike. Once seasonality was built in, the forecast error dropped from over 25% to under 5%.')
  )), 'concept', 10, 1) returning id into v_l1;

-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Forecast Accuracy and Reforecasting',
  'Why forecasts drift, and when to update one rather than defend it.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading','What is it?','body',
      'Forecast accuracy measures how close a prior forecast came to actual spend, usually as a percentage error. Reforecasting means deliberately updating the projection mid-period once new information arrives, rather than waiting for the next planning cycle.'),
    jsonb_build_object('heading','Why is it important?','body',
      'A forecast is a living estimate, not a promise. Treating an outdated forecast as gospel once circumstances have clearly changed just produces a bigger, more embarrassing variance later — reforecasting early is almost always better than defending a stale number.'),
    jsonb_build_object('heading','How does it work?','body',
      'Most organizations set a materiality threshold (for example, a change expected to move spend more than 10% from the original forecast) that triggers a formal reforecast and a note to stakeholders explaining what changed and why.'),
    jsonb_build_object('heading','Real company example','body',
      'A team learned mid-quarter that a major customer had signed a much larger contract than planned, meaning infrastructure would need to scale sooner than forecast. Reforecasting immediately, with a clear explanation, kept trust intact — waiting until quarter-end to reveal the same gap would have looked like a miss instead of a known, well-managed change.')
  )), 'concept', 10, 2) returning id into v_l2;

-- ---------------------------------------------------------------------------
-- Lesson 3: the interactive Cloud Cost Simulator
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (v_module_id, 'Modeling "What If": The Cloud Cost Simulator',
  'Test a rightsizing or commitment decision before making it, using a live cost model.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading','What is it?','body',
        'Before recommending a change like rightsizing a fleet of virtual machines or buying a commitment discount, a FinOps analyst can model the expected savings first, using the same size/quantity/utilization/commitment inputs a real billing system tracks.'),
      jsonb_build_object('heading','Why is it important?','body',
        'A recommendation backed by a specific, modeled dollar figure ("rightsizing this fleet saves an estimated $4,200/month") is far more persuasive — and far more likely to get approved — than a vague "we should probably rightsize this."'),
      jsonb_build_object('heading','How does it work?','body',
        'Below is a simplified fleet of virtual machines with their current size, quantity, average utilization, and commitment type. Try lowering the size of an under-utilized fleet, or switching a steady fleet from On-Demand to a 1- or 3-year commitment, and watch the projected monthly cost update.'),
      jsonb_build_object('heading','What to look for','body',
        'Notice which lever — rightsizing an oversized, low-utilization fleet, or committing a steady, well-utilized one — produces the bigger swing in this scenario. In practice, both levers matter, but they apply to different kinds of workloads, and mixing them up is a common early mistake.')
    ),
    'simulator', jsonb_build_object('instances', jsonb_build_array(
      jsonb_build_object('id','fleet-1','name','Batch processing fleet','size','xlarge','quantity',12,'avg_utilization_pct',18,'commitment','on_demand'),
      jsonb_build_object('id','fleet-2','name','Core API servers','size','large','quantity',20,'avg_utilization_pct',72,'commitment','on_demand'),
      jsonb_build_object('id','fleet-3','name','Internal dev/test environments','size','medium','quantity',15,'avg_utilization_pct',9,'commitment','on_demand'),
      jsonb_build_object('id','fleet-4','name','Primary database tier','size','xlarge','quantity',4,'avg_utilization_pct',81,'commitment','on_demand')
    ))
  ), 'simulation', 15, 3) returning id into v_l3;

-- ---------------------------------------------------------------------------
insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Forecasting Quiz', 'Checks understanding of forecasting, reforecasting, and modeling savings scenarios.', 'Intermediate', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order) values
(v_quiz_id, 'What should a good forecast be built from, beyond just the recent trend line?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Nothing else — trend alone is always sufficient'),
   jsonb_build_object('id','b','text','Known upcoming changes and seasonality'),
   jsonb_build_object('id','c','text','The CEO''s personal opinion'),
   jsonb_build_object('id','d','text','A competitor''s cloud bill')),
 'b', 'A trend-only forecast misses known changes like planned migrations, launches, or recurring seasonal spikes.', 'Beginner', 'Forecasting', 1),
(v_quiz_id, 'True or False: Once a forecast is set for the quarter, it should never be updated before the next planning cycle.', 'true_false', null, 'false',
 'Reforecasting when material new information arrives is standard practice — a forecast is a living estimate, not a fixed promise.', 'Beginner', 'Forecasting', 2),
(v_quiz_id, 'A team learns mid-quarter of a major, unplanned change that will clearly affect spend. What is the recommended action?',
 'scenario', jsonb_build_array(
   jsonb_build_object('id','a','text','Say nothing and wait for the variance to appear at quarter-end'),
   jsonb_build_object('id','b','text','Reforecast immediately and explain the change to stakeholders'),
   jsonb_build_object('id','c','text','Ignore the new information entirely'),
   jsonb_build_object('id','d','text','Cancel the forecast process altogether')),
 'b', 'Proactively reforecasting and explaining the driver preserves trust; waiting turns a known change into a surprise miss.', 'Intermediate', 'Forecasting', 3),
(v_quiz_id, 'In the Cloud Cost Simulator, which lever is the better fit for a fleet with high, steady utilization?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','Rightsizing it smaller'),
   jsonb_build_object('id','b','text','Buying a commitment discount (reserved pricing)'),
   jsonb_build_object('id','c','text','Deleting it'),
   jsonb_build_object('id','d','text','Doing nothing, since high utilization always means no savings are possible')),
 'b', 'Steady, well-utilized workloads are the ideal candidate for reserved/committed pricing, since the usage is predictable.', 'Intermediate', 'Commitment Management', 4),
(v_quiz_id, 'Which lever fits a fleet with very low, inconsistent utilization?',
 'multiple_choice', jsonb_build_array(
   jsonb_build_object('id','a','text','A 3-year commitment discount'),
   jsonb_build_object('id','b','text','Rightsizing to a smaller instance size'),
   jsonb_build_object('id','c','text','Increasing the quantity'),
   jsonb_build_object('id','d','text','Ignoring it since low utilization is always intentional')),
 'b', 'Low, inconsistent utilization signals an oversized instance — rightsizing, not a multi-year commitment, is the appropriate first move.', 'Intermediate', 'Rightsizing', 5);

-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values ('Model and Recommend a Fleet Change',
  'Use the simulator scenario to make a concrete, numbers-backed recommendation.', 'Intermediate',
  'Using the four fleets from the Cloud Cost Simulator lesson, leadership wants one clear, prioritized recommendation for next quarter''s optimization plan — the single largest dollar opportunity, not a list of everything that could theoretically be changed.',
  jsonb_build_object('fleets', jsonb_build_array(
    jsonb_build_object('name','Batch processing fleet','size','xlarge','quantity',12,'avg_utilization_pct',18,'commitment','on_demand','monthly_cost',6728),
    jsonb_build_object('name','Core API servers','size','large','quantity',20,'avg_utilization_pct',72,'commitment','on_demand','monthly_cost',5606),
    jsonb_build_object('name','Internal dev/test environments','size','medium','quantity',15,'avg_utilization_pct',9,'commitment','on_demand','monthly_cost',2102),
    jsonb_build_object('name','Primary database tier','size','xlarge','quantity',4,'avg_utilization_pct',81,'commitment','on_demand','monthly_cost',2243)
  )),
  'The batch processing fleet is both the largest and most under-utilized (18%) of the four. Identify which single fleet offers the largest absolute-dollar rightsizing opportunity, and state which lever (rightsizing or commitment discount) applies to it.',
  array['Forecasting','Rightsizing','Commitment Management'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','top_opportunity','label','Highest-priority fleet','expected','Batch processing fleet','weight',3,'skill','Rightsizing',
      'options', jsonb_build_array('Batch processing fleet','Core API servers','Internal dev/test environments','Primary database tier')),
    jsonb_build_object('key','lever','label','Correct lever for that fleet','expected','rightsizing','weight',3,'skill','Commitment Management',
      'options', jsonb_build_array('rightsizing','a 3-year commitment discount','deleting the fleet entirely','increasing quantity'))
  )), v_module_id) returning id into v_challenge_id;

end $$;
