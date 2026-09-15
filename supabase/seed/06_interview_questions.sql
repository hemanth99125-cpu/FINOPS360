-- ============================================================================
-- Mock interview question bank. Open-ended by design — guidance is talking
-- points a strong answer would hit, not a hidden correct answer (see
-- migration 0007 for why these are readable directly, unlike quiz answers).
-- ============================================================================
insert into interview_questions (category, question, skill_category, guidance, difficulty) values

('behavioral',
 'Tell me about a time you had to convince a team to change how they were using cloud resources. How did you approach it?',
 'Stakeholder Communication',
 'Look for: a specific real or realistic scenario, framing the ask in terms the team cared about (not just cost), and how resistance was handled — not just the outcome.',
 'medium'),

('behavioral',
 'Describe a situation where a cost anomaly or spike caught you off guard. What did you do?',
 'Cost Anomaly Analysis',
 'Look for: how the anomaly was detected, the investigation process (not just the fix), and what changed afterward to catch it sooner next time.',
 'medium'),

('behavioral',
 'How do you handle disagreement with an engineering team that doesn''t think cost is their responsibility?',
 'Business Communication',
 'Look for: empathy for the engineering perspective, framing cost as a shared engineering concern rather than a finance mandate, and a concrete example if possible.',
 'medium'),

('technical',
 'Walk me through how you would read and reconcile a cloud provider''s monthly invoice against what was budgeted.',
 'Cloud Billing',
 'Look for: mention of line-item detail, credits/discounts, tax, and reconciling by service/account rather than just comparing one total number.',
 'easy'),

('technical',
 'A team''s compute spend doubled month over month with no change in traffic. How would you investigate?',
 'Cost Analysis',
 'Look for: a structured investigation (instance type/count changes, idle resources, region changes, pricing model changes) rather than jumping straight to a guess.',
 'medium'),

('technical',
 'When would you recommend a Reserved Instance or Savings Plan versus staying on-demand?',
 'Commitment Management',
 'Look for: usage predictability and workload stability as the deciding factor, awareness of commitment risk, and that this isn''t a blanket "always commit" answer.',
 'medium'),

('technical',
 'What''s your approach to designing a tagging strategy for an organization that currently has none?',
 'Tagging',
 'Look for: a small mandatory tag set, an enforcement mechanism (not just a policy doc), and a plan for what to do with already-untagged historical resources.',
 'hard'),

('technical',
 'How would you decide between showback and chargeback for a given organization?',
 'Chargeback',
 'Look for: reference to organizational maturity and appetite for internal billing, not a one-size-fits-all answer.',
 'medium'),

('scenario',
 'Leadership wants a hard budget cap on cloud spend next quarter, but engineering says that could break production during traffic spikes. How do you resolve this?',
 'Budgeting',
 'Look for: a proposal that reconciles both concerns (e.g., budget with a defined burst/reforecast trigger) rather than picking one side.',
 'hard'),

('scenario',
 'You inherit a cloud environment where nobody owns cost accountability. Where do you start?',
 'FinOps Governance',
 'Look for: a prioritized first move (usually visibility/tagging before optimization), not an attempt to fix everything at once.',
 'hard'),

('scenario',
 'A VP asks you to summarize a complex cost driver analysis in one slide. What do you include, and what do you leave out?',
 'Executive Reporting',
 'Look for: leading with the business impact and recommendation, not the methodology; ruthless prioritization of what''s left out.',
 'medium'),

('scenario',
 'Two teams are disputing which one should be charged for a shared database''s cost. How do you handle it?',
 'Cost Allocation',
 'Look for: a fair, repeatable allocation method (e.g., usage-based split) proposed as policy, not a one-off arbitration.',
 'medium');
