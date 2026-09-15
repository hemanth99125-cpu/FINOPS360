-- ============================================================================
-- Row Level Security
--
-- Model: this is a private, single-learner deployment.
--   - A "learner" can only read/write rows where user_id = auth.uid().
--   - A "tracker" can READ (never write) any learner-owned row, so the
--     private dashboard can show real activity/skill/readiness data.
--   - Curriculum content (learning_paths/courses/modules/lessons/quizzes/
--     quiz_questions/challenges/capstone_projects) is readable by any
--     authenticated user (learner or tracker) and never client-writable —
--     it is managed via migrations/seed data or the service role only.
-- ============================================================================

alter table profiles enable row level security;
alter table learning_paths enable row level security;
alter table courses enable row level security;
alter table modules enable row level security;
alter table lessons enable row level security;
alter table user_lesson_progress enable row level security;
alter table quizzes enable row level security;
alter table quiz_questions enable row level security;
alter table quiz_attempts enable row level security;
alter table challenges enable row level security;
alter table challenge_attempts enable row level security;
alter table skills enable row level security;
alter table user_skills enable row level security;
alter table learning_activities enable row level security;
alter table learning_sessions enable row level security;
alter table daily_learning_stats enable row level security;
alter table readiness_history enable row level security;
alter table capability_assessments enable row level security;
alter table capstone_projects enable row level security;
alter table user_capstone_projects enable row level security;

-- Helper: is the current user a tracker?
create or replace function is_tracker()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'tracker'
  );
$$;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create policy "profiles_select_own_or_tracker"
  on profiles for select
  using (id = auth.uid() or is_tracker());

create policy "profiles_update_own"
  on profiles for update
  using (id = auth.uid());

create policy "profiles_insert_own"
  on profiles for insert
  with check (id = auth.uid());

-- ---------------------------------------------------------------------------
-- Curriculum content: readable by any signed-in user, no client writes
-- ---------------------------------------------------------------------------
create policy "learning_paths_read" on learning_paths for select using (auth.uid() is not null);
create policy "courses_read" on courses for select using (auth.uid() is not null);
create policy "modules_read" on modules for select using (auth.uid() is not null);
create policy "lessons_read" on lessons for select using (auth.uid() is not null);
create policy "quizzes_read" on quizzes for select using (auth.uid() is not null);
create policy "quiz_questions_read" on quiz_questions for select using (auth.uid() is not null);
create policy "challenges_read" on challenges for select using (auth.uid() is not null);
create policy "skills_read" on skills for select using (auth.uid() is not null);
create policy "capstone_projects_read" on capstone_projects for select using (auth.uid() is not null);

-- ---------------------------------------------------------------------------
-- Learner-owned data: own read/write, tracker read-only
-- ---------------------------------------------------------------------------
create policy "lesson_progress_rw_own" on user_lesson_progress
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "lesson_progress_read_tracker" on user_lesson_progress
  for select using (is_tracker());

create policy "quiz_attempts_rw_own" on quiz_attempts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "quiz_attempts_read_tracker" on quiz_attempts
  for select using (is_tracker());

create policy "challenge_attempts_rw_own" on challenge_attempts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "challenge_attempts_read_tracker" on challenge_attempts
  for select using (is_tracker());

create policy "user_skills_rw_own" on user_skills
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "user_skills_read_tracker" on user_skills
  for select using (is_tracker());

create policy "activities_rw_own" on learning_activities
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "activities_read_tracker" on learning_activities
  for select using (is_tracker());

create policy "sessions_rw_own" on learning_sessions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "sessions_read_tracker" on learning_sessions
  for select using (is_tracker());

create policy "daily_stats_rw_own" on daily_learning_stats
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "daily_stats_read_tracker" on daily_learning_stats
  for select using (is_tracker());

create policy "readiness_rw_own" on readiness_history
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "readiness_read_tracker" on readiness_history
  for select using (is_tracker());

create policy "assessments_rw_own" on capability_assessments
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "assessments_read_tracker" on capability_assessments
  for select using (is_tracker());

create policy "user_capstone_rw_own" on user_capstone_projects
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "user_capstone_read_tracker" on user_capstone_projects
  for select using (is_tracker());
