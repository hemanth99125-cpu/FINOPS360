-- ============================================================================
-- BONUS LEVEL — From Cloud Sales to FinOps: Translating Your Existing Skills
-- Written specifically for a learner transferring internally from a cloud
-- sales role into a FinOps role. Same shape as every other level: one
-- learning_path -> one course -> one module -> 3 lessons -> 1 quiz (5
-- questions) -> 1 challenge (linked to the module via challenges.module_id).
-- ============================================================================
do $$
declare
  v_path_id uuid;
  v_course_id uuid;
  v_module_id uuid;
  v_lesson1 uuid;
  v_lesson2 uuid;
  v_lesson3 uuid;
  v_quiz_id uuid;
  v_challenge_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('Bridge: Cloud Sales to FinOps',
  'A short bonus path for someone moving internally from a cloud sales role into FinOps — reframing skills you already have rather than starting from zero.',
  'Bonus', 22, 75)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'From Pitching Cloud to Managing Its Cost',
  'How the instincts and vocabulary you built in cloud sales map directly onto FinOps work — and where the two roles genuinely differ.',
  'Bonus', 1, 75)
returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Translating Sales Skills into FinOps Value',
  'Reframing what you already know, and naming the few things that are genuinely new.', 1, 'Bridge')
returning id into v_module_id;

-- ---------------------------------------------------------------------------
-- Lesson 1
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Why a Sales Background Is a FinOps Advantage',
  'The one thing most FinOps hires lack — and the one thing you already have.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'The stakeholder gap most FinOps teams have', 'body',
        'Most people who land in FinOps come from engineering or finance. They are usually strong with numbers and tools, but weaker at the part of the job that involves walking into a room with a VP of Engineering or a CFO and explaining, in plain language, why the cloud bill moved and what to do about it. That translation work — cost data into a story a non-technical stakeholder will act on — is exactly what sales already trained you to do, every single call.'),
      jsonb_build_object('heading', 'You already speak the vendor''s language', 'body',
        'If you sold cloud services, you already understand commitment discounts, tiered pricing, discount negotiation, and how a vendor frames "savings" to a customer. In FinOps, you sit on the other side of that exact conversation — evaluating whether a vendor''s proposed discount is genuinely good for your company, or just good for the vendor''s quota. Knowing how the pitch is built is a real advantage when your job is to see through it.'),
      jsonb_build_object('heading', 'What is genuinely new, so you can plan for it', 'body',
        'Be honest with yourself about the gap: sales rarely requires writing SQL queries against a billing dataset, auditing resource tags across hundreds of accounts, or building a chargeback model nobody asked you to sell. Those are learnable skills, not talent gaps — but they are new, and worth deliberately practicing rather than assuming they will click immediately the way stakeholder conversations will.'),
      jsonb_build_object('heading', 'How to use this module', 'body',
        'The next two lessons take specific things you already do in sales and show you the FinOps-side equivalent. The quiz and challenge at the end are designed to test the translation, not brand-new material — you should recognize most of the underlying concepts already.')
    )
  ),
  'concept', 12, 1
) returning id into v_lesson1;

-- ---------------------------------------------------------------------------
-- Lesson 2
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'From Pitching Discounts to Auditing Them: Commitment Discounts, Revisited',
  'The same Reserved Instances and Savings Plans you sold, seen from the buyer''s side.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'The sales-side version you know', 'body',
        'As a cloud sales specialist, your job with commitment discounts was to get the customer to commit to more usage for a lower rate — a 1-year or 3-year Reserved Instance, or a Savings Plan, framed around the discount percentage and the "savings" it unlocks compared to on-demand pricing.'),
      jsonb_build_object('heading', 'The FinOps-side version you are moving into', 'body',
        'On the FinOps side, the question flips: is this commitment actually a good idea for THIS company, given how their usage really behaves? A commitment discount only saves money if the underlying usage is stable enough to honor it. A FinOps analyst looks at utilization history before recommending a commitment — the opposite instinct of a sales conversation, where the goal is usually to close the commitment, not stress-test it.'),
      jsonb_build_object('heading', 'The trap FinOps analysts are trained to avoid', 'body',
        'Overcommitting is one of the most common and expensive mistakes in cloud cost management: locking into a 3-year Reserved Instance for a workload that gets decommissioned in month eight. The commitment itself doesn''t go away — the company keeps paying for capacity nobody uses anymore. Recognizing this risk is a skill you are uniquely positioned to develop quickly, because you already understand how the discount was sold to begin with.'),
      jsonb_build_object('heading', 'What to actually check before recommending a commitment', 'body',
        'A practical checklist a FinOps analyst uses: has this usage been stable for at least 3 months? Is the workload likely to still exist at the end of the commitment term? Would a shorter commitment (1yr instead of 3yr) capture most of the savings with less risk? These are the same questions you might have anticipated a skeptical customer asking you in a sales call — now you are the one asking them internally.')
    )
  ),
  'concept', 12, 2
) returning id into v_lesson2;

-- ---------------------------------------------------------------------------
-- Lesson 3
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Speaking FinOps in the Room: Reframing Your Sales Vocabulary',
  'Concrete phrase-for-phrase swaps for your first few weeks of meetings.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'Same instinct, different framing', 'body',
        'In sales, a strong pitch says: "you could save 40% by committing to this plan." In FinOps, the equivalent strong statement says: "based on 90 days of usage, this workload is a good candidate for a 1-year commitment, projected to save $X/month with low risk of underutilization." Same underlying skill — quantify the value, be specific — but grounded in your own company''s actual data instead of a vendor''s proposal.'),
      jsonb_build_object('heading', 'Reframe: "objection handling" becomes "risk framing"', 'body',
        'In sales, when a customer pushed back, you addressed their concern and kept moving toward the close. In FinOps, when you present a cost recommendation, expect pushback from engineering ("this will slow us down") or finance ("why wasn''t this caught sooner"). The skill transfers directly: listen to the specific concern, address it with data, and propose a concrete next step — you are just no longer trying to "close" anything, you are trying to reach the right decision together.'),
      jsonb_build_object('heading', 'Reframe: "quota" pressure becomes "credibility" pressure', 'body',
        'Sales performance is measured in numbers closed. Early FinOps credibility is measured in being right and being useful — flagging a real anomaly before someone else notices it, or catching a bad commitment before it locks in, builds trust fast. Resist the old instinct to oversell a recommendation''s certainty; FinOps credibility is built on being calibrated and precise, not persuasive for its own sake.'),
      jsonb_build_object('heading', 'A sentence starter for your first team meeting', 'body',
        'If you are unsure how to introduce your background, something like this works well: "I spent time on the vendor side selling these commitment plans, so I understand how they''re priced and pitched — I''m looking forward to applying that from the other side of the table." It turns your background into an asset out loud, instead of something to downplay.')
    )
  ),
  'practical', 10, 3
) returning id into v_lesson3;

-- ---------------------------------------------------------------------------
-- Quiz
-- ---------------------------------------------------------------------------
insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Sales-to-FinOps Bridge Quiz', 'Checks whether sales-side concepts translate correctly to the FinOps-side equivalent.', 'Bridge', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order)
values
(v_quiz_id,
 'A vendor pitches your company a 3-year Reserved Instance based on last month''s usage spike. As the FinOps analyst reviewing this, what should you check first?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Whether the discount percentage is above 30%'),
   jsonb_build_object('id','b','text','Whether that usage level has been stable over a longer period, not just one spike'),
   jsonb_build_object('id','c','text','Whether the vendor is a "preferred partner"'),
   jsonb_build_object('id','d','text','Nothing — a 3-year term always maximizes savings')
 ),
 'b',
 'A single spike is not a reliable basis for a multi-year commitment. The core FinOps skill here is checking usage stability before locking in a long-term commitment, since overcommitting on unstable usage is one of the most expensive and common cloud cost mistakes.',
 'Bridge', 'Commitment Discounts', 1),

(v_quiz_id,
 'True or False: The core skill of translating cost data into a clear business story for a non-technical stakeholder is essentially the same skill used in a sales pitch, just applied internally.',
 'true_false', null, 'true',
 'This is the central idea of the bridge module: stakeholder communication is a directly transferable skill from sales into FinOps, even though the goal (informing a decision, not closing a deal) is different.',
 'Bridge', 'Stakeholder Communication', 2),

(v_quiz_id,
 'A workload that justified a 3-year Reserved Instance is decommissioned after 8 months. What is the main financial consequence?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','The company automatically gets a refund for the unused term'),
   jsonb_build_object('id','b','text','The commitment is cancelled with no further cost'),
   jsonb_build_object('id','c','text','The company keeps paying for the committed capacity for the remaining term, whether or not it is used'),
   jsonb_build_object('id','d','text','The vendor absorbs the remaining cost as a courtesy')
 ),
 'c',
 'Commitment discounts are a binding financial obligation, not a cancellable subscription. This is exactly the risk a FinOps analyst is trained to weigh before recommending a commitment — the opposite instinct from a sales conversation focused on closing the commitment.',
 'Bridge', 'Commitment Discounts', 3),

(v_quiz_id,
 'In a FinOps team meeting, an engineer pushes back on a rightsizing recommendation, saying it will slow down their team. What is the best response, drawing on sales-style objection handling?',
 'scenario',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Insist the recommendation is correct and move on'),
   jsonb_build_object('id','b','text','Withdraw the recommendation immediately to avoid conflict'),
   jsonb_build_object('id','c','text','Listen to the specific concern, address it with data, and propose a concrete next step together'),
   jsonb_build_object('id','d','text','Escalate directly to their manager without discussing it first')
 ),
 'c',
 'This mirrors good objection handling from sales: acknowledge the specific concern, respond with data rather than assertion, and move toward a concrete next step — collaboration, not "winning" the conversation.',
 'Bridge', 'Stakeholder Communication', 4),

(v_quiz_id,
 'Which of the following is a genuinely new skill for someone moving from cloud sales into FinOps, rather than a direct translation of an existing skill?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Explaining cost concepts in plain language to a non-technical stakeholder'),
   jsonb_build_object('id','b','text','Understanding how commitment discounts are priced'),
   jsonb_build_object('id','c','text','Writing SQL queries against a billing dataset to investigate a cost anomaly'),
   jsonb_build_object('id','d','text','Handling pushback on a recommendation with calm, data-backed responses')
 ),
 'c',
 'SQL and hands-on billing-data analysis are the parts of the job with no direct sales equivalent — worth deliberately practicing rather than assuming they transfer automatically, unlike the stakeholder-communication and pricing-literacy skills.',
 'Bridge', 'Self-Assessment', 5);

-- ---------------------------------------------------------------------------
-- Challenge
-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values (
  'Evaluate the Vendor''s Commitment Proposal — From the Other Side of the Table',
  'A practical exercise applying sales-side pricing knowledge to a FinOps-side recommendation.',
  'Bridge',
  'A cloud vendor account rep — someone doing the job you used to do — has proposed a 3-year Reserved Instance commitment for your company''s largest compute workload, citing a 42% discount versus on-demand pricing. Your manager asks you to evaluate whether to accept it before the next budget review.',
  jsonb_build_object(
    'usage_history_monthly_hours', jsonb_build_array(
      jsonb_build_object('month','Month 1','hours',720),
      jsonb_build_object('month','Month 2','hours',705),
      jsonb_build_object('month','Month 3','hours',180),
      jsonb_build_object('month','Month 4','hours',715),
      jsonb_build_object('month','Month 5','hours',690),
      jsonb_build_object('month','Month 6','hours',710)
    ),
    'proposed_discount_pct', 42,
    'proposed_term_years', 3,
    'engineering_note', 'This workload supports a product currently under review for possible deprecation within the next 12 months.'
  ),
  'Review the six months of usage history and the engineering note. Decide whether to recommend accepting the vendor''s proposed 3-year commitment as-is, and identify the single biggest risk factor in this scenario.',
  array['Commitment Discounts','Stakeholder Communication','Risk Assessment'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','recommendation','label','Recommendation on the 3-year term','expected','do not accept as-is','weight',3,'skill','Risk Assessment',
      'options', jsonb_build_array('accept as-is','do not accept as-is','double the commitment instead')),
    jsonb_build_object('key','biggest_risk','label','Biggest risk factor','expected','possible deprecation within the term','weight',3,'skill','Commitment Discounts',
      'options', jsonb_build_array('the discount percentage is too low','possible deprecation within the term','month 3''s usage dip is unexplained','the vendor cannot be trusted')),
    jsonb_build_object('key','next_step','label','Recommended next step','expected','ask engineering for a firmer deprecation timeline before committing','weight',2,'skill','Stakeholder Communication',
      'options', jsonb_build_array('ask engineering for a firmer deprecation timeline before committing','sign the 3-year term immediately to lock in savings','ignore the engineering note and proceed','decline all future vendor proposals'))
  )),
  v_module_id
) returning id into v_challenge_id;

end $$;
