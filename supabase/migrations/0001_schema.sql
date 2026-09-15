-- ============================================================================
-- FinOps Career Accelerator — Core Schema
-- One learner, one tracker. No multi-tenant / billing / org tables.
-- ============================================================================

create extension if not exists "uuid-ossp";

-- ----------------------------------------------------------------------------
-- PROFILES (extends auth.users)
-- ----------------------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  avatar_url text,
  role text not null check (role in ('learner', 'tracker')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- CURRICULUM: learning_paths -> courses -> modules -> lessons
-- ----------------------------------------------------------------------------
create table learning_paths (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  level text not null,               -- Beginner / Foundation / Intermediate / Advanced / Professional
  sequence_order int not null,
  estimated_duration_minutes int
);

create table courses (
  id uuid primary key default uuid_generate_v4(),
  learning_path_id uuid not null references learning_paths(id) on delete cascade,
  title text not null,
  description text,
  level text not null,
  sequence_order int not null,
  estimated_duration_minutes int
);

create table modules (
  id uuid primary key default uuid_generate_v4(),
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  description text,
  sequence_order int not null,
  difficulty_level text
);

create table lessons (
  id uuid primary key default uuid_generate_v4(),
  module_id uuid not null references modules(id) on delete cascade,
  title text not null,
  description text,
  content jsonb not null default '{}'::jsonb, -- structured lesson body (sections, examples)
  lesson_type text not null check (lesson_type in
    ('concept','example','practical','exercise','scenario','case_study','simulation')),
  estimated_duration_minutes int,
  sequence_order int not null
);

-- ----------------------------------------------------------------------------
-- LEARNER PROGRESS ON LESSONS
-- ----------------------------------------------------------------------------
create table user_lesson_progress (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  lesson_id uuid not null references lessons(id) on delete cascade,
  status text not null default 'not_started' check (status in ('not_started','in_progress','completed')),
  progress_percentage int not null default 0 check (progress_percentage between 0 and 100),
  started_at timestamptz,
  completed_at timestamptz,
  active_learning_seconds int not null default 0,
  updated_at timestamptz not null default now(),
  unique (user_id, lesson_id)
);

-- ----------------------------------------------------------------------------
-- QUIZZES
-- ----------------------------------------------------------------------------
create table quizzes (
  id uuid primary key default uuid_generate_v4(),
  module_id uuid not null references modules(id) on delete cascade,
  title text not null,
  description text,
  difficulty text,
  passing_score int not null default 70
);

create table quiz_questions (
  id uuid primary key default uuid_generate_v4(),
  quiz_id uuid not null references quizzes(id) on delete cascade,
  question text not null,
  question_type text not null check (question_type in
    ('multiple_choice','true_false','calculation','scenario','data_analysis','decision_making')),
  options jsonb,                 -- array of {id, text} for choice-based questions
  correct_answer text not null,  -- option id, "true"/"false", or numeric/string answer
  explanation text not null,
  difficulty text,
  skill_category text,           -- references skills.skill_name for scoring
  sequence_order int not null default 0
);

create table quiz_attempts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  quiz_id uuid not null references quizzes(id) on delete cascade,
  score int not null,
  total_questions int not null,
  correct_answers int not null,
  incorrect_answers int not null,
  answers jsonb not null default '[]'::jsonb, -- [{question_id, given_answer, correct}]
  started_at timestamptz not null,
  completed_at timestamptz not null default now(),
  attempt_number int not null default 1
);

-- ----------------------------------------------------------------------------
-- CHALLENGES (scenario-based practical work)
-- ----------------------------------------------------------------------------
create table challenges (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  difficulty text,
  scenario text not null,
  scenario_data jsonb not null default '{}'::jsonb, -- simulated dataset for the scenario
  instructions text not null,
  skills_tested text[] not null default '{}',
  scoring_rules jsonb not null default '{}'::jsonb   -- expected answers / rubric
);

create table challenge_attempts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  challenge_id uuid not null references challenges(id) on delete cascade,
  answers jsonb not null default '{}'::jsonb,
  decisions jsonb not null default '{}'::jsonb,
  score int,
  feedback text,
  started_at timestamptz not null,
  completed_at timestamptz
);

-- ----------------------------------------------------------------------------
-- SKILLS
-- ----------------------------------------------------------------------------
create table skills (
  id uuid primary key default uuid_generate_v4(),
  skill_name text not null unique,
  description text,
  category text not null -- cloud / finops / data / professional
);

create table user_skills (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  skill_id uuid not null references skills(id) on delete cascade,
  skill_score numeric(5,2) not null default 0,      -- composite 0-100
  skill_level text not null default 'Beginner' check (skill_level in
    ('Beginner','Learning','Intermediate','Proficient','Advanced','Industry Ready')),
  knowledge_score numeric(5,2) not null default 0,   -- from quizzes
  practical_score numeric(5,2) not null default 0,   -- from challenges/exercises
  assessment_score numeric(5,2) not null default 0,  -- from capability assessments
  confidence_score numeric(5,2) not null default 0,  -- consistency of correct answers over time
  last_updated timestamptz not null default now(),
  unique (user_id, skill_id)
);

-- ----------------------------------------------------------------------------
-- ACTIVITY TRACKING
-- ----------------------------------------------------------------------------
create table learning_activities (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  activity_type text not null check (activity_type in
    ('login','lesson_started','lesson_resumed','lesson_completed',
     'quiz_started','quiz_completed','challenge_started','challenge_completed',
     'simulation_started','simulation_completed','exercise_completed',
     'assessment_completed','project_started','project_completed')),
  course_id uuid references courses(id),
  module_id uuid references modules(id),
  lesson_id uuid references lessons(id),
  related_item_id uuid, -- quiz_id / challenge_id / project_id depending on activity_type
  duration_seconds int not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table learning_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  active_duration_seconds int not null default 0,
  idle_duration_seconds int not null default 0,
  device_type text
);

create table daily_learning_stats (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  date date not null,
  active_learning_minutes int not null default 0,
  lessons_completed int not null default 0,
  quizzes_completed int not null default 0,
  quiz_average_score numeric(5,2),
  challenges_completed int not null default 0,
  exercises_completed int not null default 0,
  progress_change numeric(5,2) not null default 0,
  readiness_score numeric(5,2),
  unique (user_id, date)
);

-- ----------------------------------------------------------------------------
-- READINESS + CAPABILITY
-- ----------------------------------------------------------------------------
create table readiness_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  overall_score numeric(5,2) not null,
  cloud_score numeric(5,2) not null default 0,
  finops_score numeric(5,2) not null default 0,
  practical_score numeric(5,2) not null default 0,
  data_analysis_score numeric(5,2) not null default 0,
  problem_solving_score numeric(5,2) not null default 0,
  communication_score numeric(5,2) not null default 0,
  consistency_score numeric(5,2) not null default 0,
  recorded_at timestamptz not null default now()
);

create table capability_assessments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  assessment_name text not null,
  assessment_type text not null,
  overall_score numeric(5,2) not null,
  skills_evaluated jsonb not null default '[]'::jsonb,
  strengths text[] not null default '{}',
  weaknesses text[] not null default '{}',
  recommendations text[] not null default '{}',
  completed_at timestamptz not null default now()
);

create table capstone_projects (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  scenario text not null,
  requirements text[] not null default '{}',
  evaluation_criteria text[] not null default '{}'
);

create table user_capstone_projects (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  project_id uuid not null references capstone_projects(id) on delete cascade,
  status text not null default 'not_started' check (status in ('not_started','in_progress','completed')),
  submission_data jsonb not null default '{}'::jsonb,
  score numeric(5,2),
  feedback text,
  started_at timestamptz,
  completed_at timestamptz
);

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
create index idx_activities_user_created on learning_activities(user_id, created_at desc);
create index idx_progress_user on user_lesson_progress(user_id);
create index idx_quiz_attempts_user on quiz_attempts(user_id, completed_at desc);
create index idx_challenge_attempts_user on challenge_attempts(user_id, completed_at desc);
create index idx_user_skills_user on user_skills(user_id);
create index idx_daily_stats_user_date on daily_learning_stats(user_id, date desc);
create index idx_readiness_user on readiness_history(user_id, recorded_at desc);
