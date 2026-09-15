-- ============================================================================
-- Security hardening: pin search_path on every function.
--
-- The Supabase security advisor flags "Function Search Path Mutable" on all
-- of these — none were pinned, going all the way back to migration 0003.
-- Without a fixed search_path, a security definer function is technically
-- exploitable if a malicious object of the same name as one it calls
-- unqualified gets created earlier in the caller's resolvable schema path.
-- Pinning search_path to just `public, pg_temp` closes that off. This
-- doesn't change any function's behavior — every unqualified reference
-- inside them already resolved to `public` in practice.
-- ============================================================================

alter function is_tracker() set search_path = public, pg_temp;
alter function handle_new_user() set search_path = public, pg_temp;
alter function derive_skill_level(numeric) set search_path = public, pg_temp;
alter function upsert_user_skill(uuid, text, numeric, numeric, numeric) set search_path = public, pg_temp;
alter function track_lesson_progress(uuid, text, int, int) set search_path = public, pg_temp;
alter function submit_quiz_attempt(uuid, jsonb, timestamptz) set search_path = public, pg_temp;
alter function submit_challenge_attempt(uuid, jsonb, jsonb, timestamptz) set search_path = public, pg_temp;
alter function bump_daily_stats(uuid, int, int, int, int, int, int) set search_path = public, pg_temp;
alter function recalculate_readiness(uuid) set search_path = public, pg_temp;
alter function readiness_level(numeric) set search_path = public, pg_temp;
alter function submit_capstone_project(uuid, jsonb, text[], boolean) set search_path = public, pg_temp;
alter function start_interview_session(uuid[]) set search_path = public, pg_temp;
alter function submit_interview_session(uuid, jsonb, boolean) set search_path = public, pg_temp;
