-- ============================================================================
-- BONUS LEVEL — AI Token Economics for FinOps (expanded)
-- One learning_path -> one course -> one module -> 7 lessons (one with an
-- interactive Token Cost Simulator) -> 1 quiz (8 questions) -> 2 challenges.
-- Covers how LLM/AI token-based pricing works and how to manage it as a
-- FinOps cost category — "FinOps for AI" is an active, real specialty the
-- FinOps Foundation now tracks, not a stretch addition to the curriculum.
-- ============================================================================
do $$
declare
  v_path_id uuid;
  v_course_id uuid;
  v_module_id uuid;
  v_quiz_id uuid;
begin

insert into learning_paths (title, description, level, sequence_order, estimated_duration_minutes)
values ('AI Token Economics for FinOps',
  'How LLM and AI-service costs actually work, and how to manage them the way you would manage any other cloud cost category.',
  'Bonus', 23, 150)
returning id into v_path_id;

insert into courses (learning_path_id, title, description, level, sequence_order, estimated_duration_minutes)
values (v_path_id, 'Managing the Cost of AI Workloads',
  'Token pricing, what actually drives AI spend, and how to bring the same FinOps discipline you use for cloud compute to AI usage.',
  'Bonus', 1, 150)
returning id into v_course_id;

insert into modules (course_id, title, description, sequence_order, difficulty_level)
values (v_course_id, 'Token Pricing, Cost Drivers, and Optimization',
  'Understanding what you are actually paying for when a bill says "tokens," and the levers that control it.', 1, 'Bridge')
returning id into v_module_id;

-- ---------------------------------------------------------------------------
-- Lesson 1
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'What Is a Token, and Why Does Pricing Work This Way',
  'The basic unit AI providers bill on, and why it is not the same as "one word."',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'A token is a chunk of text, not a word', 'body',
      'AI language models process text broken into "tokens" — small chunks that are often close to, but not exactly, whole words. A rough rule of thumb is about 4 characters or three-quarters of a word per token in English. Providers bill per token because tokens are what the model actually computes on internally, not because it maps neatly onto anything a customer would intuitively count.'),
    jsonb_build_object('heading', 'Input tokens and output tokens are priced differently', 'body',
      'Almost every major provider charges a different rate for input tokens (the prompt and any context you send in) versus output tokens (what the model generates back), and output tokens are usually priced several times higher than input tokens. A workload that generates long responses costs meaningfully more than one that mostly reads and summarizes.'),
    jsonb_build_object('heading', 'Context length is a hidden cost multiplier', 'body',
      'Every token in the conversation history, system instructions, and any retrieved documents counts as input tokens on every single call, not just once. An application that resends a large chunk of context on every request can rack up cost far faster than the visible "user-facing" interaction would suggest.'),
    jsonb_build_object('heading', 'Why this is now a real FinOps category', 'body',
      'AI/LLM spend behaves like a new, fast-growing cloud cost category: usage-based, easy to scale without immediately noticing the cost impact, and often owned by product or engineering teams who are not thinking about cost at the same time they are thinking about capability. Bringing FinOps discipline here is now a distinct and growing specialty inside the field.')
  )),
  'concept', 12, 1
);

-- ---------------------------------------------------------------------------
-- Lesson 2
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'What Actually Drives AI Cost Growth',
  'The usual suspects when an AI bill grows faster than usage seems to justify.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'Model choice is the single biggest lever', 'body',
      'Larger, more capable models cost meaningfully more per token than smaller ones — often by several multiples. A large share of AI cost optimization is simply asking whether every call actually needs the most capable model, or whether a smaller model would perform the task just as well at a fraction of the cost.'),
    jsonb_build_object('heading', 'Uncontrolled context growth', 'body',
      'Chat-style applications that keep appending the full conversation history to every request will see cost grow non-linearly as conversations get longer, since every prior message gets re-billed as input tokens on every new turn. Trimming or summarizing older context is a direct, controllable cost lever.'),
    jsonb_build_object('heading', 'Retries, loops, and agentic workflows', 'body',
      'Automated systems that call a model repeatedly — retrying on a bad response, or an "agent" that takes many sequential steps to complete one task — can multiply the token cost of a single user action many times over without that multiplication being obvious from the outside. This is analogous to a misconfigured auto-scaling group in traditional cloud cost management.'),
    jsonb_build_object('heading', 'Caching and batching reduce real spend, not just latency', 'body',
      'Many providers offer prompt caching (discounted or free reuse of repeated context) and batch processing (delayed, lower-cost handling of non-urgent requests). These are often framed as performance features, but from a FinOps lens they are cost-optimization levers directly comparable to reserved capacity or spot instances in traditional cloud infrastructure.')
  )),
  'concept', 12, 2
);

-- ---------------------------------------------------------------------------
-- Lesson 3 — new deep dive
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Prompt Caching: How It Actually Saves Money',
  'A closer look at the single highest-leverage optimization for repetitive AI workloads.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'What gets cached, and what does not', 'body',
      'Prompt caching stores a processed version of a prompt prefix — typically system instructions, long reference documents, or few-shot examples — that stays identical across many calls. Only the portion of the input that repeats can be cached; content that changes on every call (like a unique user question) is always billed at the full rate.'),
    jsonb_build_object('heading', 'Why this matters most for high-volume, repetitive workloads', 'body',
      'A customer support bot that sends the same 3,000-token policy document as context on every single call is an ideal caching candidate: that 3,000 tokens is identical every time. A one-off creative writing request, by contrast, has almost nothing to cache, since the prompt is different every time.'),
    jsonb_build_object('heading', 'Cache hit rate is the number that actually matters', 'body',
      'A caching feature only saves money in proportion to how often the cached content is actually reused before it expires (cache lifetimes are typically minutes, not days). A workload with a 90% cache hit rate captures most of the available discount; one with a 10% hit rate barely benefits, and the added complexity may not be worth it.'),
    jsonb_build_object('heading', 'This is the AI-era version of a cloud commitment discount', 'body',
      'Structurally, caching works like a Reserved Instance: you get a much cheaper rate in exchange for a form of predictability (repeated, stable content) — the same underlying trade-off, applied to a completely different pricing mechanism.')
  )),
  'concept', 10, 3
);

-- ---------------------------------------------------------------------------
-- Lesson 4 — new deep dive
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'RAG and Retrieval: The Hidden Cost Multiplier',
  'Why "just add retrieval" is a cost decision, not only an accuracy improvement.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'What RAG actually adds to a request', 'body',
      'Retrieval-Augmented Generation (RAG) improves answer quality by pulling relevant documents from a knowledge base and inserting them into the prompt before the model sees the question. Every retrieved document becomes additional input tokens billed on that call — a system that retrieves five documents per query is paying for the tokens of all five, every time.'),
    jsonb_build_object('heading', 'More retrieved context is not automatically better or cheaper', 'body',
      'A common failure mode is retrieving more documents than necessary "just in case," which increases both cost and the risk of irrelevant context confusing the model''s answer. Tuning how many documents are retrieved, and how aggressively they are trimmed or summarized before insertion, is a direct cost lever with a quality trade-off attached.'),
    jsonb_build_object('heading', 'Embedding costs are a separate, easy-to-forget line item', 'body',
      'Before retrieval can happen, documents must be converted into embeddings (usually a one-time or periodic cost per document) and a query embedding must be generated on every request. Both are billed separately from the main generation call, and teams sometimes evaluate "AI cost" while only looking at the generation bill and missing this piece entirely.'),
    jsonb_build_object('heading', 'The FinOps question to ask about any RAG system', 'body',
      'Is the marginal accuracy gained from retrieving N documents worth the marginal token cost of N documents? This is the same cost-versus-benefit question used to evaluate any cloud infrastructure decision — RAG is just a newer place it shows up.')
  )),
  'concept', 10, 4
);

-- ---------------------------------------------------------------------------
-- Lesson 5 — new deep dive
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Fine-Tuning vs. Prompting: A Cost Tradeoff, Not Just a Technical One',
  'When customizing a model''s behavior actually pays for itself.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'Two ways to get a model to behave a certain way', 'body',
      'Prompting means giving instructions and examples inside every request. Fine-tuning means training a customized version of the model ahead of time, so the same behavior can be achieved with a much shorter prompt at inference time. Fine-tuning has an upfront cost; prompting has an ongoing per-call cost that repeats forever.'),
    jsonb_build_object('heading', 'The breakeven is a volume question', 'body',
      'If a lengthy set of instructions and examples adds, say, 2,000 extra input tokens to every single call, that recurring cost can eventually exceed the one-time cost of fine-tuning a model that does not need those instructions repeated. At low request volume, prompting is almost always cheaper; at very high volume, fine-tuning can pay for itself, sometimes quickly.'),
    jsonb_build_object('heading', 'This is a capital-versus-operating-cost decision', 'body',
      'This is structurally the same tradeoff as buying versus renting infrastructure: fine-tuning behaves like an upfront investment that lowers a recurring cost, similar in shape to a Reserved Instance or Savings Plan commitment, just applied to model behavior instead of compute capacity.'),
    jsonb_build_object('heading', 'Fine-tuning is not automatically the "optimized" choice', 'body',
      'It adds real complexity: maintaining a custom model version, re-tuning when the base model updates, and evaluating whether quality actually held up. A FinOps-minded recommendation weighs the full cost of maintaining that complexity, not just the smaller per-call token bill.')
  )),
  'concept', 10, 5
);

-- ---------------------------------------------------------------------------
-- Lesson 6 — new deep dive
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Comparing Providers Without Getting Fooled by Sticker Price',
  'A framework for evaluating AI cost claims that holds up even as actual prices change.',
  jsonb_build_object('sections', jsonb_build_array(
    jsonb_build_object('heading', 'Why memorizing current prices is the wrong skill', 'body',
      'AI provider pricing changes frequently — often multiple times a year, sometimes with new pricing tiers entirely. The durable skill is not knowing today''s exact rate, it is knowing which factors to compare: input rate, output rate, context window limits, and whether caching or batch discounts are available at all.'),
    jsonb_build_object('heading', 'A lower per-token price does not always mean a lower total cost', 'body',
      'A cheaper model that requires a much longer, more detailed prompt to get comparable quality can end up costing more overall than a pricier model that needs a shorter prompt. Total cost per task — not the headline per-token rate — is the number that should drive a decision.'),
    jsonb_build_object('heading', 'Quality-adjusted cost is the real comparison', 'body',
      'If a cheaper model requires two retries on average to produce an acceptable answer, its effective cost is closer to three times its sticker price. Any real evaluation should account for retry rates and failure rates, not only the advertised per-token cost.'),
    jsonb_build_object('heading', 'The questions to ask before switching providers', 'body',
      'What is the actual input and output rate today? Does caching or batch pricing exist, and at what discount? What is the effective cost per successfully completed task, based on real retry/failure rates — not the vendor''s best-case example? Answering these three consistently is more valuable than tracking a specific price list, which will already be outdated by the time you read it again.')
  )),
  'concept', 10, 6
);

-- ---------------------------------------------------------------------------
-- Lesson 7 — synthesis + interactive simulator
-- ---------------------------------------------------------------------------
insert into lessons (module_id, title, description, content, lesson_type, estimated_duration_minutes, sequence_order)
values (
  v_module_id,
  'Bringing FinOps Discipline to AI Spend',
  'Applying allocation, budgeting, and optimization practices you already know — then testing the levers yourself.',
  jsonb_build_object(
    'sections', jsonb_build_array(
      jsonb_build_object('heading', 'Allocation and tagging still apply', 'body',
        'The same tagging and allocation discipline used for cloud compute applies to AI usage: attribute token spend to the specific product feature, team, or customer that generated it. Without this, AI cost shows up as one large, unexplained line item that nobody can act on.'),
      jsonb_build_object('heading', 'Set a per-feature or per-user budget, not just a total', 'body',
        'A single company-wide AI budget hides which specific feature or workflow is actually expensive. Breaking the budget down by feature makes it possible to catch a cost spike close to its source, the same way per-service or per-team budgets work in traditional cloud FinOps.'),
      jsonb_build_object('heading', 'Right-size the model the way you right-size an instance', 'body',
        'The direct AI-era equivalent of "rightsizing an oversized EC2 instance" is routing a task to the smallest model that still meets the quality bar — using an expensive, highly capable model only for the subset of requests that genuinely need it.'),
      jsonb_build_object('heading', 'Try the levers yourself', 'body',
        'The simulator below lets you adjust model tier, request volume, average input/output length, and caching, and see the monthly cost move in real time. Try dropping from a frontier model to a smaller one, then try enabling caching with a high hit rate — notice which lever moves the number more.')
    ),
    'tokenSimulator', jsonb_build_object('config', jsonb_build_object(
      'modelTier', 'frontier',
      'monthlyRequestsThousands', 500,
      'avgInputTokens', 1500,
      'avgOutputTokens', 400,
      'cachingEnabled', false,
      'cacheHitRatePct', 70
    ))
  ),
  'practical', 15, 7
);

-- ---------------------------------------------------------------------------
-- Quiz — 8 questions
-- ---------------------------------------------------------------------------
insert into quizzes (module_id, title, description, difficulty, passing_score)
values (v_module_id, 'AI Token Economics Quiz', 'Checks understanding of how AI/LLM costs are structured, what drives them, and how to optimize them.', 'Bridge', 70)
returning id into v_quiz_id;

insert into quiz_questions (quiz_id, question, question_type, options, correct_answer, explanation, difficulty, skill_category, sequence_order)
values
(v_quiz_id,
 'Why are output tokens usually priced higher than input tokens?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','It is an arbitrary marketing decision with no cost basis'),
   jsonb_build_object('id','b','text','Providers price output higher across most major models, reflecting the added compute of generating each new token'),
   jsonb_build_object('id','c','text','Output tokens are actually cheaper, not more expensive, than input tokens'),
   jsonb_build_object('id','d','text','Pricing is identical for input and output on every provider')
 ), 'b',
 'Generation (output) is typically priced higher than reading (input) across most major providers, which is why workloads that generate long responses cost more than ones that mostly summarize.',
 'Bridge', 'AI Cost Fundamentals', 1),

(v_quiz_id,
 'True or False: Resending the full conversation history on every turn of a chatbot means earlier messages get re-billed as input tokens on every subsequent call.',
 'true_false', null, 'true',
 'Context sent with each request counts as input tokens on every call — this is why long, uncompressed conversation histories cause cost to grow faster than message count alone would suggest.',
 'Bridge', 'Cost Drivers', 2),

(v_quiz_id,
 'A team notices their AI costs tripled, but user traffic only grew 20%. Which of these is the LEAST likely explanation?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','An agentic workflow started retrying failed steps automatically'),
   jsonb_build_object('id','b','text','A feature was switched to a larger, more expensive model'),
   jsonb_build_object('id','c','text','The billing currency exchange rate shifted overnight'),
   jsonb_build_object('id','d','text','Conversation context grew longer and is now resent on every call')
 ), 'c',
 'Exchange rate shifts are negligible compared to model choice, retries/loops, and context growth — the common real drivers of a cost spike disproportionate to traffic growth.',
 'Bridge', 'Cost Drivers', 3),

(v_quiz_id,
 'What is the direct AI-era equivalent of "rightsizing an oversized cloud instance"?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Routing a task to the smallest model that still meets the required quality bar'),
   jsonb_build_object('id','b','text','Always using the most capable model available for every request'),
   jsonb_build_object('id','c','text','Increasing the context window size for every request'),
   jsonb_build_object('id','d','text','Switching AI providers every month')
 ), 'a',
 'Just as rightsizing avoids paying for unneeded compute capacity, model routing avoids paying premium per-token rates for tasks a smaller, cheaper model could handle equally well.',
 'Bridge', 'Optimization', 4),

(v_quiz_id,
 'A workload sends the same 3,000-token policy document as context on every call. Why is this an ideal prompt caching candidate?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Because the content is identical across calls, so it can be reused at a steep discount instead of billed fresh each time'),
   jsonb_build_object('id','b','text','Because caching only works on output tokens, not input'),
   jsonb_build_object('id','c','text','Because policy documents are exempt from billing entirely'),
   jsonb_build_object('id','d','text','Because caching requires the content to change on every call')
 ), 'a',
 'Caching saves the most when the same content repeats across many calls — a fixed policy document sent every time is the textbook use case, unlike content that changes on every request.',
 'Bridge', 'Caching', 5),

(v_quiz_id,
 'A RAG system retrieves 5 documents per query "just in case," even though most queries only need 1-2 to answer well. What is the main FinOps concern here?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','There is no cost concern — retrieval is always free'),
   jsonb_build_object('id','b','text','The system is paying for the input tokens of all 5 documents on every call, most of which add cost without adding value'),
   jsonb_build_object('id','c','text','Retrieved documents only affect latency, never cost'),
   jsonb_build_object('id','d','text','Embedding cost disappears once retrieval is in use')
 ), 'b',
 'Every retrieved document becomes billed input tokens on that call. Over-retrieving "just in case" increases cost without a guaranteed accuracy benefit — a direct cost-versus-benefit tradeoff to tune.',
 'Bridge', 'RAG Costs', 6),

(v_quiz_id,
 'A team is deciding between fine-tuning a model and continuing to prompt it with lengthy instructions on every call. What mainly determines which is more cost-effective?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','Request volume — fine-tuning''s upfront cost is more likely to pay off at high volume, prompting is usually cheaper at low volume'),
   jsonb_build_object('id','b','text','Fine-tuning is always cheaper regardless of volume'),
   jsonb_build_object('id','c','text','Prompting is always cheaper regardless of volume'),
   jsonb_build_object('id','d','text','The choice has no cost implications, only accuracy implications')
 ), 'a',
 'This is a breakeven question, similar to buy-versus-rent: fine-tuning''s one-time cost can offset a recurring per-call cost, but only once volume is high enough to justify it.',
 'Bridge', 'Fine-Tuning vs Prompting', 7),

(v_quiz_id,
 'When comparing two AI providers, why can a model with a lower per-token price still end up more expensive overall?',
 'multiple_choice',
 jsonb_build_array(
   jsonb_build_object('id','a','text','It cannot — the lowest per-token price is always the lowest total cost'),
   jsonb_build_object('id','b','text','It may require a longer prompt or more retries to reach acceptable quality, raising its effective cost per completed task above a pricier model''s'),
   jsonb_build_object('id','c','text','Cheaper models are never allowed to be used in production'),
   jsonb_build_object('id','d','text','Per-token price and total cost are unrelated concepts')
 ), 'b',
 'Total cost per successfully completed task — accounting for prompt length and retry/failure rates — is the number that should drive a decision, not the headline per-token rate alone.',
 'Bridge', 'Provider Comparison', 8);

-- ---------------------------------------------------------------------------
-- Challenge 1
-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values (
  'Diagnose an AI Cost Spike',
  'A practical exercise investigating an unexplained jump in AI/LLM spend.',
  'Bridge',
  'Your company''s AI-powered customer support summarization feature saw its monthly token bill jump from $4,200 to $15,800, while ticket volume only grew 15%. Your manager asks you to investigate before the next budget review.',
  jsonb_build_object(
    'monthly_data', jsonb_build_array(
      jsonb_build_object('month','Last month','tickets_processed',8200,'avg_context_tokens_per_call',900,'model','fast-small-v1','cost_usd',4200),
      jsonb_build_object('month','This month','tickets_processed',9430,'avg_context_tokens_per_call',5600,'model','frontier-large-v2','cost_usd',15800)
    ),
    'engineering_note', 'We upgraded to the larger frontier model last month for better summary quality, and also started including the full ticket thread history in every call instead of just the latest message.'
  ),
  'Review the monthly data and the engineering note. Identify the two biggest cost drivers behind the spike, and recommend one concrete change that would reduce cost without reverting the quality improvement entirely.',
  array['AI Cost Fundamentals','Cost Drivers','Optimization'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','driver_1','label','First biggest cost driver identified','expected','model upgrade to a more expensive model','weight',3,'skill','Cost Drivers',
      'options', jsonb_build_array('model upgrade to a more expensive model','ticket volume growth alone','exchange rate changes','customer complaints increasing')),
    jsonb_build_object('key','driver_2','label','Second biggest cost driver identified','expected','sending full context on every call increased input tokens per request','weight',3,'skill','Cost Drivers',
      'options', jsonb_build_array('sending full context on every call increased input tokens per request','the support team hired more staff','the summarization feature was used less often','output formatting changed to plain text')),
    jsonb_build_object('key','recommendation','label','Recommended optimization','expected','summarize or trim older thread history instead of sending it in full on every call','weight',2,'skill','Optimization',
      'options', jsonb_build_array('summarize or trim older thread history instead of sending it in full on every call','revert to the smaller model entirely','stop processing tickets on weekends','increase the support team headcount'))
  )),
  v_module_id
);

-- ---------------------------------------------------------------------------
-- Challenge 2 — new
-- ---------------------------------------------------------------------------
insert into challenges (title, description, difficulty, scenario, scenario_data, instructions, skills_tested, scoring_rules, module_id)
values (
  'Compare Two Provider Quotes Without Getting Fooled by Sticker Price',
  'A practical exercise applying total-cost-per-task thinking to a vendor comparison.',
  'Bridge',
  'Two AI providers have quoted your team for the same feature. Provider A advertises a lower per-token price. Your manager assumes Provider A is the obvious choice and asks you to confirm before signing.',
  jsonb_build_object(
    'provider_comparison', jsonb_build_array(
      jsonb_build_object('provider','Provider A','input_rate_per_1m',0.50,'output_rate_per_1m',2.00,'avg_prompt_tokens_needed',4200,'avg_retries_per_task',1.8),
      jsonb_build_object('provider','Provider B','input_rate_per_1m',3.00,'output_rate_per_1m',15.00,'avg_prompt_tokens_needed',900,'avg_retries_per_task',1.05)
    ),
    'note', 'Provider A''s lower-capability model needs a much longer, more detailed prompt to perform the task, and fails to produce an acceptable answer on the first try more often, requiring extra retries. Provider B''s model succeeds on the first attempt almost every time with a much shorter prompt.'
  ),
  'Using total cost per successfully completed task — not just the advertised per-token rate — determine which provider is actually cheaper, and explain the reasoning your manager is missing.',
  array['Provider Comparison','AI Cost Fundamentals','Stakeholder Communication'],
  jsonb_build_object('criteria', jsonb_build_array(
    jsonb_build_object('key','actual_cheaper_provider','label','Which provider is actually cheaper per completed task','expected','depends on the numbers, but likely not the one with the lower sticker price alone','weight',3,'skill','Provider Comparison',
      'options', jsonb_build_array('Provider A because its per-token price is lower','Provider B once prompt length and retries are factored in','Impossible to determine without more information','They are exactly equal')),
    jsonb_build_object('key','missing_factor','label','What the manager''s assumption is missing','expected','it only compares sticker price, not total cost per completed task including prompt length and retries','weight',3,'skill','AI Cost Fundamentals',
      'options', jsonb_build_array('it only compares sticker price, not total cost per completed task including prompt length and retries','nothing, the assumption is already correct','the manager should have picked Provider B on brand reputation alone','pricing comparisons are not a FinOps responsibility')),
    jsonb_build_object('key','communication_approach','label','How to raise this with the manager','expected','present the total-cost-per-task calculation clearly rather than simply overruling the assumption','weight',2,'skill','Stakeholder Communication',
      'options', jsonb_build_array('present the total-cost-per-task calculation clearly rather than simply overruling the assumption','say nothing and sign with Provider A as instructed','escalate to a VP immediately without discussing it first','refuse to work on the comparison'))
  )),
  v_module_id
);

end $$;
