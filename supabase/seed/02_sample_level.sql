-- ============================================================================
-- Sample level, wired end-to-end: Level 2 — Cloud Computing Foundations
-- (Levels 1, 3-21 follow the same shape and can be added the same way.)
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
values ('Cloud Foundation', 'Understand how cloud computing works before touching FinOps.', 'Foundation', 2, 180)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Cloud Computing Foundations',
  'What cloud computing is, who the major providers are, and the building blocks (compute, storage, networking) that every cloud bill is made of.',
  'Foundation', 1, 180)
returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Core Cloud Concepts', 'The vocabulary and mental model you need before reading a cloud invoice.', 1, 'Beginner')
returning id into v_module_id;

-- ---------------------------------------------------------------------------
-- Lesson 1
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'What Is Cloud Computing?',
  'Traditional data centers vs. the cloud, and why companies made the switch.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'What is it?', 'body',
        'For decades, a company that needed a computer program to run had to buy physical servers, put them in a room with cooling and backup power, and hire people to maintain them. Cloud computing replaces that room with someone else''s data center: companies like Amazon, Microsoft, and Google run enormous facilities full of servers, and let other companies rent capacity from them by the hour or second instead of buying hardware outright.'),
      jsonb_build_object('heading', 'Why is it important?', 'body',
        'Renting instead of owning changes the economics completely. A company can start small, scale up during a busy season, and scale back down afterward — paying only for what it actually used. This is the entire reason a "cloud bill" exists and fluctuates: usage drives cost, in a way a fixed monthly server lease never did.'),
      jsonb_build_object('heading', 'How does it work?', 'body',
        'Cloud providers virtualize physical hardware — one physical server is split into many smaller virtual machines, each rented out to a different customer. The provider handles the physical maintenance; the customer only manages what runs inside their rented slice.'),
      jsonb_build_object('heading', 'Real company example', 'body',
        'A retail company expects 10x normal traffic on Black Friday. On physical servers, they''d have had to buy enough hardware to survive one day a year and let it sit idle the other 364. On the cloud, they temporarily rent more capacity for that one day, then scale back down on Saturday — and their bill reflects exactly that spike.')
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
  'The Major Cloud Providers: AWS, Azure, Google Cloud',
  'What each provider is generally used for, in plain terms.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'What is it?', 'body',
        'Three providers dominate the market: Amazon Web Services (AWS), Microsoft Azure, and Google Cloud Platform (GCP). All three sell fundamentally the same thing — rented compute, storage, and networking — but with different service names, pricing structures, and strengths.'),
      jsonb_build_object('heading', 'Why does the difference matter for FinOps?', 'body',
        'Every provider bills differently. AWS has "Reserved Instances" and "Savings Plans," Azure has "Reserved VM Instances," and Google has "Committed Use Discounts." A FinOps professional working at a company using more than one provider has to understand each one''s billing model to compare costs fairly — this is called multi-cloud FinOps, covered later in this path.'),
      jsonb_build_object('heading', 'Common use cases', 'body',
        'AWS is the largest and oldest, with the widest range of services. Azure is common in companies already using Microsoft tools like Windows Server and Active Directory. Google Cloud is known for data analytics and machine learning workloads. In practice, a FinOps analyst rarely picks the provider — they analyze whatever the engineering team already chose.')
    )
  ),
  'concept', 10, 2
) returning id into v_lesson2;

-- ---------------------------------------------------------------------------
-- Lesson 3
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Compute, Storage, and Networking: What You''re Actually Paying For',
  'The three cost categories that make up almost every cloud bill.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'Compute', 'body',
        'Compute is the processing power that runs your applications: virtual machines (called "instances"), containers, and serverless functions. You are billed for how much CPU/memory you reserved and for how long it ran — an idle, oversized virtual machine is one of the most common sources of waste a FinOps analyst finds.'),
      jsonb_build_object('heading', 'Storage', 'body',
        'Storage holds data: object storage (like AWS S3) for files and backups, block storage attached to a virtual machine like a hard drive, and file storage shared across many machines. Storage cost depends on how much data you keep and how "hot" (frequently accessed) it needs to be — cold, rarely-accessed data can move to cheaper storage tiers.'),
      jsonb_build_object('heading', 'Networking', 'body',
        'Networking costs come mostly from data transfer — especially "egress," data leaving the cloud provider''s network to the public internet or to another region. Data moving between two virtual machines in the same region is usually cheap or free; data leaving the provider entirely is often the most expensive kind of traffic.'),
      jsonb_build_object('heading', 'Why this matters for a FinOps analyst', 'body',
        'Nearly every cost optimization recommendation you will ever make falls into one of these three buckets: rightsizing compute, optimizing storage tiers, or reducing unnecessary data transfer. Being able to categorize a line item on a bill into one of these three is the first practical skill this path is building toward.')
    )
  ),
  'concept', 10, 3
) returning id into v_lesson3;

-- ---------------------------------------------------------------------------
-- Quiz
-- ---------------------------------------------------------------------------
insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'Cloud Computing Foundations Quiz', 'Checks understanding of providers, compute, storage, and networking.', 'Beginner', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order)
values
(v_quiz_id,
 'A company scales up servers for one day of holiday sales, then scales back down. What best describes why cloud computing enables this?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Cloud providers give hardware away for free on holidays'),
   jsonb_build_object('id','b','text','Cloud computing lets companies rent capacity by usage instead of owning fixed hardware'),
   jsonb_build_object('id','c','text','Cloud computing requires buying enough servers to handle the busiest day of the year'),
   jsonb_build_object('id','d','text','Cloud computing only works for retail companies')
 ),
 'b',
 'The core economic shift of cloud computing is paying for rented capacity as you use it, instead of owning fixed hardware sized for your busiest day.',
 'Beginner', 'Cloud Fundamentals', 1),

(v_quiz_id,
 'True or False: Data transferred between two virtual machines in the same cloud region is typically the most expensive type of network traffic.',
 'true_false', null, 'false',
 'The most expensive traffic is usually egress — data leaving the provider''s network entirely — not traffic within the same region.',
 'Beginner', 'Networking', 2),

(v_quiz_id,
 'Which cost category does an oversized, mostly-idle virtual machine fall under?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Storage'),
   jsonb_build_object('id','b','text','Networking'),
   jsonb_build_object('id','c','text','Compute'),
   jsonb_build_object('id','d','text','Licensing')
 ),
 'c',
 'Virtual machines are compute resources — you pay for the CPU/memory you reserved whether or not it''s being used, which is why idle VMs are a classic compute waste example.',
 'Beginner', 'Compute', 3),

(v_quiz_id,
 'Which AWS billing concept is most analogous to Google Cloud''s "Committed Use Discounts"?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','On-Demand Pricing'),
   jsonb_build_object('id','b','text','Savings Plans'),
   jsonb_build_object('id','c','text','Spot Instances'),
   jsonb_build_object('id','d','text','Data Transfer Pricing')
 ),
 'b',
 'AWS Savings Plans and Reserved Instances are the rough equivalent of GCP''s Committed Use Discounts — all three trade a usage commitment for a lower rate.',
 'Beginner', 'AWS Fundamentals', 4),

(v_quiz_id,
 'A dataset is accessed once a year for compliance reasons. Which storage decision would a FinOps analyst recommend?',
 'scenario',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Keep it in the most expensive, fastest-access storage tier'),
   jsonb_build_object('id','b','text','Delete it immediately'),
   jsonb_build_object('id','c','text','Move it to a low-cost, infrequent-access ("cold") storage tier'),
   jsonb_build_object('id','d','text','Duplicate it across every region')
 ),
 'c',
 'Rarely-accessed ("cold") data belongs in a cheaper, infrequent-access storage tier — this is one of the most common and low-risk storage optimizations.',
 'Intermediate', 'Storage', 5);

-- ---------------------------------------------------------------------------
-- Challenge
-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules)
values (
  'Diagnose the Surprise Cloud Bill',
  'A first practical investigation exercise using a small simulated billing dataset.',
  'Beginner',
  'Your company''s cloud bill jumped from $42,000 to $58,000 this month. Engineering says "nothing major changed." Finance wants an answer before the exec review tomorrow morning.',
  jsonb_build_object(
    'line_items', jsonb_build_array(
      jsonb_build_object('service','Compute (VMs)','last_month',22000,'this_month',24500),
      jsonb_build_object('service','Object Storage','last_month',6000,'this_month',6200),
      jsonb_build_object('service','Data Transfer (Egress)','last_month',9000,'this_month',18800),
      jsonb_build_object('service','Managed Database','last_month',5000,'this_month',5100)
    )
  ),
  'Review the four line items above. Identify which service category is the primary driver of the increase, classify it into Compute / Storage / Networking, and recommend a first investigation step.',
  array['Cloud Cost Analysis','Cost Anomaly Analysis','Problem Solving'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','primary_driver','label','Primary cost driver','expected','Data Transfer (Egress)','weight',3,'skill','Cost Anomaly Analysis',
      'options', jsonb_build_array('Compute (VMs)','Object Storage','Data Transfer (Egress)','Managed Database')),
    jsonb_build_object('key','category','label','Cost category','expected','Networking','weight',2,'skill','Cloud Cost Data Analysis',
      'options', jsonb_build_array('Compute','Storage','Networking')),
    jsonb_build_object('key','next_step','label','Recommended first step','expected','investigate egress','weight',2,'skill','Problem Solving',
      'options', jsonb_build_array('investigate egress','buy more reserved instances','delete the database','ignore it, it will normalize'))
  ))
) returning id into v_challenge_id;

end $$;
