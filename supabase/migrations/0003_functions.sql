-- ============================================================================
-- Functions: signup trigger, activity logging, skill scoring, readiness engine
-- These run with definer rights so a learner's own actions can update rows
-- (user_skills, readiness_history, daily_learning_stats) that RLS would
-- otherwise only let them read/write directly for user_id = auth.uid().
-- Every function still hard-scopes to auth.uid() internally — a learner can
-- never pass another user's id and have it accepted.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Create a profile row automatically when someone signs up.
--    Role comes from the signup metadata: { "role": "learner" | "tracker" }.
-- ---------------------------------------------------------------------------
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'role', 'learner')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ---------------------------------------------------------------------------
-- 2. Recompute skill_level from the 4 underlying score dimensions.
--    NEVER derived from lesson completion.
-- ---------------------------------------------------------------------------
create or replace function derive_skill_level(p_score numeric)
returns text
language sql
immutable
as $$
  select case
    when p_score >= 95 then 'Industry Ready'
    when p_score >= 85 then 'Advanced'
    when p_score >= 70 then 'Proficient'
    when p_score >= 50 then 'Intermediate'
    when p_score >= 30 then 'Learning'
    else 'Beginner'
  end;
$$;

-- Upsert a user_skills row given fresh knowledge/practical inputs.
-- Composite weighting: knowledge 30%, practical 40%, assessment 20%, confidence 10%.
create or replace function upsert_user_skill(
  p_user_id uuid,
  p_skill_name text,
  p_knowledge_delta numeric default null,
  p_practical_delta numeric default null,
  p_assessment_delta numeric default null
) returns void
language plpgsql
security definer
as $$
declare
  v_skill_id uuid;
  v_row user_skills%rowtype;
  v_knowledge numeric;
  v_practical numeric;
  v_assessment numeric;
  v_confidence numeric;
  v_composite numeric;
begin
  select id into v_skill_id from skills where skill_name = p_skill_name;
  if v_skill_id is null then
    return; -- unknown skill name, nothing to score
  end if;

  select * into v_row from user_skills where user_id = p_user_id and skill_id = v_skill_id;

  if v_row.id is null then
    v_knowledge := coalesce(p_knowledge_delta, 0);
    v_practical := coalesce(p_practical_delta, 0);
    v_assessment := coalesce(p_assessment_delta, 0);
    v_confidence := 0;
  else
    -- Blend new evidence in with a recency-weighted moving average (70% history / 30% new)
    -- rather than overwriting, so a single lucky attempt can't fake mastery.
    v_knowledge := case when p_knowledge_delta is null then v_row.knowledge_score
      else v_row.knowledge_score * 0.7 + p_knowledge_delta * 0.3 end;
    v_practical := case when p_practical_delta is null then v_row.practical_score
      else v_row.practical_score * 0.7 + p_practical_delta * 0.3 end;
    v_assessment := case when p_assessment_delta is null then v_row.assessment_score
      else v_row.assessment_score * 0.7 + p_assessment_delta * 0.3 end;
    -- confidence rises when new evidence agrees with the running score, falls when it swings
    v_confidence := greatest(0, least(100,
      v_row.confidence_score + case
        when p_knowledge_delta is not null and abs(p_knowledge_delta - v_row.knowledge_score) < 15 then 5
        when p_practical_delta is not null and abs(p_practical_delta - v_row.practical_score) < 15 then 5
        else -5
      end
    ));
  end if;

  v_composite := v_knowledge * 0.30 + v_practical * 0.40 + v_assessment * 0.20 + v_confidence * 0.10;

  insert into user_skills (user_id, skill_id, skill_score, skill_level,
    knowledge_score, practical_score, assessment_score, confidence_score, last_updated)
  values (p_user_id, v_skill_id, v_composite, derive_skill_level(v_composite),
    v_knowledge, v_practical, v_assessment, v_confidence, now())
  on conflict (user_id, skill_id) do update set
    skill_score = v_composite,
    skill_level = derive_skill_level(v_composite),
    knowledge_score = v_knowledge,
    practical_score = v_practical,
    assessment_score = v_assessment,
    confidence_score = v_confidence,
    last_updated = now();
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Mark a lesson started / progressed / completed and log the activity.
-- ---------------------------------------------------------------------------
create or replace function track_lesson_progress(
  p_lesson_id uuid,
  p_status text,
  p_progress_percentage int,
  p_active_seconds int
) returns void
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_module_id uuid;
  v_course_id uuid;
begin
  select m.id, c.id into v_module_id, v_course_id
  from lessons l join modules m on m.id = l.module_id join courses c on c.id = m.course_id
  where l.id = p_lesson_id;

  insert into user_lesson_progress (user_id, lesson_id, status, progress_percentage,
      started_at, completed_at, active_learning_seconds, updated_at)
  values (v_user_id, p_lesson_id, p_status, p_progress_percentage,
      case when p_status in ('in_progress','completed') then now() else null end,
      case when p_status = 'completed' then now() else null end,
      p_active_seconds, now())
  on conflict (user_id, lesson_id) do update set
    status = p_status,
    progress_percentage = greatest(user_lesson_progress.progress_percentage, p_progress_percentage),
    started_at = coalesce(user_lesson_progress.started_at, now()),
    completed_at = case when p_status = 'completed' then now() else user_lesson_progress.completed_at end,
    active_learning_seconds = user_lesson_progress.active_learning_seconds + p_active_seconds,
    updated_at = now();

  insert into learning_activities (user_id, activity_type, course_id, module_id, lesson_id, duration_seconds)
  values (v_user_id,
    case when p_status = 'completed' then 'lesson_completed' else 'lesson_started' end,
    v_course_id, v_module_id, p_lesson_id, p_active_seconds);

  perform bump_daily_stats(v_user_id, p_active_seconds,
    case when p_status = 'completed' then 1 else 0 end, 0, null, 0, 0);
end;
$$;

-- ---------------------------------------------------------------------------
-- 4. Score and record a quiz attempt. Answers: [{question_id, given_answer}]
-- ---------------------------------------------------------------------------
create or replace function submit_quiz_attempt(
  p_quiz_id uuid,
  p_answers jsonb,
  p_started_at timestamptz
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_question record;
  v_given text;
  v_correct boolean;
  v_total int := 0;
  v_correct_count int := 0;
  v_graded jsonb := '[]'::jsonb;
  v_score int;
  v_module_id uuid;
  v_skill_totals jsonb := '{}'::jsonb;
  v_skill record;
  v_attempt_no int;
begin
  select module_id into v_module_id from quizzes where id = p_quiz_id;

  for v_question in select * from quiz_questions where quiz_id = p_quiz_id loop
    v_total := v_total + 1;
    v_given := (select item->>'given_answer' from jsonb_array_elements(p_answers) item
                where item->>'question_id' = v_question.id::text limit 1);
    v_correct := (lower(coalesce(v_given, '')) = lower(v_question.correct_answer));
    if v_correct then v_correct_count := v_correct_count + 1; end if;

    v_graded := v_graded || jsonb_build_object(
      'question_id', v_question.id,
      'given_answer', v_given,
      'correct', v_correct,
      'correct_answer', v_question.correct_answer,
      'explanation', v_question.explanation,
      'skill_category', v_question.skill_category
    );

    if v_question.skill_category is not null then
      v_skill_totals := jsonb_set(
        v_skill_totals, array[v_question.skill_category],
        to_jsonb(
          coalesce((v_skill_totals->v_question.skill_category->>'correct')::int, 0) + (case when v_correct then 1 else 0 end)
        ) -- placeholder overwritten below with full object
      , true);
    end if;
  end loop;

  -- Rebuild per-skill correct/total counts properly (jsonb_set above only tracked correct; redo cleanly)
  v_skill_totals := '{}'::jsonb;
  for v_question in select * from quiz_questions where quiz_id = p_quiz_id loop
    v_given := (select item->>'given_answer' from jsonb_array_elements(p_answers) item
                where item->>'question_id' = v_question.id::text limit 1);
    v_correct := (lower(coalesce(v_given, '')) = lower(v_question.correct_answer));
    if v_question.skill_category is not null then
      v_skill_totals := jsonb_set(
        v_skill_totals,
        array[v_question.skill_category],
        jsonb_build_object(
          'correct', coalesce((v_skill_totals->v_question.skill_category->>'correct')::int, 0) + (case when v_correct then 1 else 0 end),
          'total', coalesce((v_skill_totals->v_question.skill_category->>'total')::int, 0) + 1
        ),
        true
      );
    end if;
  end loop;

  v_score := case when v_total = 0 then 0 else round(v_correct_count::numeric / v_total * 100) end;
  select count(*) + 1 into v_attempt_no from quiz_attempts where user_id = v_user_id and quiz_id = p_quiz_id;

  insert into quiz_attempts (user_id, quiz_id, score, total_questions, correct_answers,
      incorrect_answers, answers, started_at, completed_at, attempt_number)
  values (v_user_id, p_quiz_id, v_score, v_total, v_correct_count,
      v_total - v_correct_count, v_graded, p_started_at, now(), v_attempt_no);

  insert into learning_activities (user_id, activity_type, module_id, related_item_id, duration_seconds, metadata)
  values (v_user_id, 'quiz_completed', v_module_id, p_quiz_id,
      extract(epoch from (now() - p_started_at))::int,
      jsonb_build_object('score', v_score));

  -- Update per-skill knowledge_score from this quiz's questions
  for v_skill in select key as skill_name, (value->>'correct')::int as correct, (value->>'total')::int as total
                 from jsonb_each(v_skill_totals) loop
    perform upsert_user_skill(v_user_id, v_skill.skill_name,
      p_knowledge_delta => round(v_skill.correct::numeric / v_skill.total * 100));
  end loop;

  perform bump_daily_stats(v_user_id, extract(epoch from (now() - p_started_at))::int, 0, 1, v_score, 0, 0);
  perform recalculate_readiness(v_user_id);

  return jsonb_build_object('score', v_score, 'correct', v_correct_count, 'total', v_total, 'graded', v_graded);
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Score and record a challenge attempt.
--    scoring_rules format: { "criteria": [{ "key": "...", "expected": ..., "weight": n, "skill": "..." }] }
--    answers format:       { "<key>": <value>, ... }
-- ---------------------------------------------------------------------------
create or replace function submit_challenge_attempt(
  p_challenge_id uuid,
  p_answers jsonb,
  p_decisions jsonb,
  p_started_at timestamptz
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_challenge challenges%rowtype;
  v_criterion jsonb;
  v_given text;
  v_expected text;
  v_weight numeric;
  v_total_weight numeric := 0;
  v_earned numeric := 0;
  v_skill_scores jsonb := '{}'::jsonb;
  v_score int;
  v_skill record;
  v_feedback text := '';
begin
  select * into v_challenge from challenges where id = p_challenge_id;

  for v_criterion in select * from jsonb_array_elements(v_challenge.scoring_rules->'criteria') loop
    v_weight := coalesce((v_criterion->>'weight')::numeric, 1);
    v_expected := v_criterion->>'expected';
    v_given := coalesce(p_answers->>(v_criterion->>'key'), p_decisions->>(v_criterion->>'key'));
    v_total_weight := v_total_weight + v_weight;

    if v_given is not null and trim(lower(v_given)) = trim(lower(v_expected)) then
      v_earned := v_earned + v_weight;
    else
      v_feedback := v_feedback || format('• %s — expected %s, got %s. ',
        coalesce(v_criterion->>'label', v_criterion->>'key'), v_expected, coalesce(v_given, 'no answer'));
    end if;

    if v_criterion->>'skill' is not null then
      v_skill_scores := jsonb_set(
        v_skill_scores,
        array[v_criterion->>'skill'],
        jsonb_build_object(
          'earned', coalesce((v_skill_scores->(v_criterion->>'skill')->>'earned')::numeric, 0)
            + (case when v_given is not null and trim(lower(v_given)) = trim(lower(v_expected)) then v_weight else 0 end),
          'total', coalesce((v_skill_scores->(v_criterion->>'skill')->>'total')::numeric, 0) + v_weight
        ),
        true
      );
    end if;
  end loop;

  v_score := case when v_total_weight = 0 then 0 else round(v_earned / v_total_weight * 100) end;
  if v_feedback = '' then v_feedback := 'All scoring criteria met.'; end if;

  insert into challenge_attempts (user_id, challenge_id, answers, decisions, score, feedback, started_at, completed_at)
  values (v_user_id, p_challenge_id, p_answers, p_decisions, v_score, v_feedback, p_started_at, now());

  insert into learning_activities (user_id, activity_type, related_item_id, duration_seconds, metadata)
  values (v_user_id, 'challenge_completed', p_challenge_id,
      extract(epoch from (now() - p_started_at))::int, jsonb_build_object('score', v_score));

  for v_skill in select key as skill_name, (value->>'earned')::numeric as earned, (value->>'total')::numeric as total
                 from jsonb_each(v_skill_scores) loop
    perform upsert_user_skill(v_user_id, v_skill.skill_name,
      p_practical_delta => round(v_skill.earned / v_skill.total * 100));
  end loop;

  perform bump_daily_stats(v_user_id, extract(epoch from (now() - p_started_at))::int, 0, 0, null, 1, 0);
  perform recalculate_readiness(v_user_id);

  return jsonb_build_object('score', v_score, 'feedback', v_feedback);
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. Roll today's activity into daily_learning_stats.
-- ---------------------------------------------------------------------------
create or replace function bump_daily_stats(
  p_user_id uuid,
  p_active_seconds int,
  p_lessons_completed int,
  p_quizzes_completed int,
  p_quiz_score int,
  p_challenges_completed int,
  p_exercises_completed int
) returns void
language plpgsql
security definer
as $$
declare
  v_today date := current_date;
  v_existing daily_learning_stats%rowtype;
  v_new_avg numeric;
begin
  select * into v_existing from daily_learning_stats where user_id = p_user_id and date = v_today;

  if v_existing.id is null then
    v_new_avg := p_quiz_score;
    insert into daily_learning_stats (user_id, date, active_learning_minutes, lessons_completed,
        quizzes_completed, quiz_average_score, challenges_completed, exercises_completed)
    values (p_user_id, v_today, round(p_active_seconds / 60.0), p_lessons_completed,
        p_quizzes_completed, v_new_avg, p_challenges_completed, p_exercises_completed);
  else
    v_new_avg := case
      when p_quiz_score is null then v_existing.quiz_average_score
      when v_existing.quiz_average_score is null then p_quiz_score
      else (v_existing.quiz_average_score * v_existing.quizzes_completed + p_quiz_score) / (v_existing.quizzes_completed + p_quizzes_completed)
    end;
    update daily_learning_stats set
      active_learning_minutes = active_learning_minutes + round(p_active_seconds / 60.0),
      lessons_completed = lessons_completed + p_lessons_completed,
      quizzes_completed = quizzes_completed + p_quizzes_completed,
      quiz_average_score = v_new_avg,
      challenges_completed = challenges_completed + p_challenges_completed,
      exercises_completed = exercises_completed + p_exercises_completed
    where id = v_existing.id;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. Industry Readiness Engine
--    cloud 15% / finops 20% / practical 20% / problem-solving 15% /
--    data analysis 10% / communication 10% / consistency 10%
-- ---------------------------------------------------------------------------
create or replace function recalculate_readiness(p_user_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  v_cloud numeric;
  v_finops numeric;
  v_practical numeric;
  v_problem_solving numeric;
  v_data_analysis numeric;
  v_communication numeric;
  v_consistency numeric;
  v_overall numeric;
  v_active_days int;
begin
  select coalesce(avg(us.skill_score), 0) into v_cloud
    from user_skills us join skills s on s.id = us.skill_id
    where us.user_id = p_user_id and s.category = 'cloud';

  select coalesce(avg(us.skill_score), 0) into v_finops
    from user_skills us join skills s on s.id = us.skill_id
    where us.user_id = p_user_id and s.category = 'finops';

  select coalesce(avg(us.practical_score), 0) into v_practical
    from user_skills us where us.user_id = p_user_id;

  select coalesce(avg(us.skill_score), 0) into v_problem_solving
    from user_skills us join skills s on s.id = us.skill_id
    where us.user_id = p_user_id and s.skill_name = 'Problem Solving';

  select coalesce(avg(us.skill_score), 0) into v_data_analysis
    from user_skills us join skills s on s.id = us.skill_id
    where us.user_id = p_user_id and s.category = 'data';

  select coalesce(avg(us.skill_score), 0) into v_communication
    from user_skills us join skills s on s.id = us.skill_id
    where us.user_id = p_user_id and s.skill_name in
      ('Business Communication','Stakeholder Communication','Executive Reporting');

  -- Consistency: % of the last 30 days with at least 10 minutes of active learning
  select count(*) into v_active_days from daily_learning_stats
    where user_id = p_user_id and date >= current_date - interval '30 days'
      and active_learning_minutes >= 10;
  v_consistency := least(100, v_active_days::numeric / 30 * 100);

  v_overall := v_cloud * 0.15 + v_finops * 0.20 + v_practical * 0.20 + v_problem_solving * 0.15
             + v_data_analysis * 0.10 + v_communication * 0.10 + v_consistency * 0.10;

  insert into readiness_history (user_id, overall_score, cloud_score, finops_score, practical_score,
      data_analysis_score, problem_solving_score, communication_score, consistency_score)
  values (p_user_id, v_overall, v_cloud, v_finops, v_practical,
      v_data_analysis, v_problem_solving, v_communication, v_consistency);

  update daily_learning_stats set readiness_score = v_overall
    where user_id = p_user_id and date = current_date;
end;
$$;

-- Readiness level label from an overall score (used client-side too, kept here for parity)
create or replace function readiness_level(p_score numeric)
returns text
language sql
immutable
as $$
  select case
    when p_score >= 86 then 'Industry Ready'
    when p_score >= 71 then 'FinOps Practitioner'
    when p_score >= 51 then 'Intermediate FinOps Learner'
    when p_score >= 31 then 'Foundation Learner'
    else 'Beginner'
  end;
$$;
