-- ============================================================================
-- Mock interview system: the last spec item with zero groundwork.
--
-- Design choices (kept deliberately light — single learner, no need for
-- machinery that only pays off at multi-user scale):
--
-- 1. interview_questions is readable directly by any authenticated user,
--    same as quiz_questions/challenges — and unlike those, there's no
--    "correct_answer" column to worry about at all, since interview answers
--    are open-ended. guidance is talking points a strong answer would hit,
--    not a hidden key.
-- 2. A session is repeatable practice, not a one-off deliverable like the
--    capstone — so no unique(user_id, ...) constraint here; a learner can run
--    as many mock interviews as they want, each its own row.
-- 3. Reuses the existing (already-migrated, already-RLS'd, currently unused)
--    capability_assessments table for the results summary instead of adding
--    a new results table — it already has exactly the right shape
--    (overall_score, strengths, weaknesses, recommendations).
-- 4. Logs to learning_activities using the existing 'assessment_completed'
--    type — no new activity_type value, no tracker page changes. A session
--    being started is not logged as an activity at all; it's a lightweight
--    practice action, not a milestone worth showing on the tracker feed
--    (unlike lessons/quizzes/challenges/capstone, which mark real progress
--    through the curriculum).
-- 5. Grading is explicitly self-rated (1-5 per question by the learner),
--    exactly like the capstone's self-assessed completeness — an interview
--    answer has no hidden correct answer to grade against either, so the
--    same "transparent, not algorithmic" approach applies here.
-- ============================================================================

create table interview_questions (
  id uuid primary key default uuid_generate_v4(),
  category text not null check (category in ('behavioral', 'technical', 'scenario')),
  question text not null,
  skill_category text references skills(skill_name),
  guidance text,
  difficulty text not null default 'medium' check (difficulty in ('easy', 'medium', 'hard'))
);

create table user_interview_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  question_ids uuid[] not null,
  responses jsonb not null default '[]'::jsonb,
  status text not null default 'in_progress' check (status in ('in_progress', 'completed')),
  overall_self_rating numeric(5, 2),
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create index user_interview_sessions_user_id_idx on user_interview_sessions(user_id);

alter table interview_questions enable row level security;
alter table user_interview_sessions enable row level security;

create policy "interview_questions_read" on interview_questions
  for select using (auth.uid() is not null);

create policy "interview_sessions_rw_own" on user_interview_sessions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "interview_sessions_read_tracker" on user_interview_sessions
  for select using (is_tracker());

-- ---------------------------------------------------------------------------
-- start_interview_session: client picks question_ids itself (a plain
-- `select id from interview_questions order by random() limit n` — read-only,
-- no need to hide it server-side since there's no answer key). This just
-- opens the session row so responses have somewhere to save to.
-- ---------------------------------------------------------------------------
create or replace function start_interview_session(
  p_question_ids uuid[]
) returns uuid
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_session_id uuid;
begin
  if p_question_ids is null or array_length(p_question_ids, 1) is null then
    raise exception 'At least one question is required to start a session';
  end if;
  if array_length(p_question_ids, 1) > 10 then
    raise exception 'A single mock interview session is limited to 10 questions';
  end if;

  insert into user_interview_sessions (user_id, question_ids)
  values (v_user_id, p_question_ids)
  returning id into v_session_id;

  return v_session_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- submit_interview_session: saves responses (draft or final). On final,
-- summarizes self-ratings into capability_assessments and logs the activity.
-- p_responses shape: [{ "question_id": uuid, "answer_text": text,
--                        "self_rating": 1-5 or null }, ...]
-- ---------------------------------------------------------------------------
create or replace function submit_interview_session(
  p_session_id uuid,
  p_responses jsonb,
  p_final boolean default false
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text := case when p_final then 'completed' else 'in_progress' end;
  v_avg_rating numeric;
  v_strengths text[];
  v_weaknesses text[];
  v_recommendations text[];
  v_skills_evaluated jsonb;
begin
  if not exists (
    select 1 from user_interview_sessions where id = p_session_id and user_id = v_user_id
  ) then
    raise exception 'Interview session not found for this user';
  end if;

  select round(avg((r->>'self_rating')::numeric), 2)
  into v_avg_rating
  from jsonb_array_elements(p_responses) r
  where r->>'self_rating' is not null;

  update user_interview_sessions
  set responses = p_responses,
    status = v_status,
    overall_self_rating = v_avg_rating,
    completed_at = case when p_final then now() else completed_at end
  where id = p_session_id;

  if p_final then
    select array_agg(distinct q.skill_category)
    into v_strengths
    from jsonb_array_elements(p_responses) r
    join interview_questions q on q.id = (r->>'question_id')::uuid
    where (r->>'self_rating')::numeric >= 4 and q.skill_category is not null;

    select array_agg(distinct q.skill_category)
    into v_weaknesses
    from jsonb_array_elements(p_responses) r
    join interview_questions q on q.id = (r->>'question_id')::uuid
    where (r->>'self_rating')::numeric <= 2 and q.skill_category is not null;

    select array_agg(distinct q.guidance)
    into v_recommendations
    from jsonb_array_elements(p_responses) r
    join interview_questions q on q.id = (r->>'question_id')::uuid
    where (r->>'self_rating')::numeric <= 2 and q.guidance is not null;

    select jsonb_agg(jsonb_build_object(
      'question_id', r->>'question_id',
      'skill_category', q.skill_category,
      'self_rating', (r->>'self_rating')::numeric
    ))
    into v_skills_evaluated
    from jsonb_array_elements(p_responses) r
    join interview_questions q on q.id = (r->>'question_id')::uuid;

    insert into capability_assessments (
      user_id, assessment_name, assessment_type, overall_score,
      skills_evaluated, strengths, weaknesses, recommendations
    ) values (
      v_user_id, 'Mock Interview Practice', 'mock_interview',
      coalesce(v_avg_rating * 20, 0),
      coalesce(v_skills_evaluated, '[]'::jsonb),
      coalesce(v_strengths, '{}'), coalesce(v_weaknesses, '{}'), coalesce(v_recommendations, '{}')
    );

    insert into learning_activities (user_id, activity_type, related_item_id, metadata)
    values (v_user_id, 'assessment_completed', p_session_id,
      jsonb_build_object(
        'mode', 'mock_interview',
        'overall_self_rating', v_avg_rating,
        'question_count', array_length((select question_ids from user_interview_sessions where id = p_session_id), 1)
      ));
  end if;

  return jsonb_build_object(
    'status', v_status,
    'overall_self_rating', v_avg_rating,
    'strengths', coalesce(v_strengths, '{}'),
    'weaknesses', coalesce(v_weaknesses, '{}'),
    'recommendations', coalesce(v_recommendations, '{}')
  );
end;
$$;

revoke execute on function start_interview_session(uuid[]) from public, anon;
revoke execute on function submit_interview_session(uuid, jsonb, boolean) from public, anon;
grant execute on function start_interview_session(uuid[]) to authenticated;
grant execute on function submit_interview_session(uuid, jsonb, boolean) to authenticated;
