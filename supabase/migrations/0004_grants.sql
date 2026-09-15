-- Only signed-in (authenticated) users may call the tracking/scoring RPCs.
-- Anonymous/public callers get nothing.
revoke execute on function track_lesson_progress(uuid, text, int, int) from public, anon;
revoke execute on function submit_quiz_attempt(uuid, jsonb, timestamptz) from public, anon;
revoke execute on function submit_challenge_attempt(uuid, jsonb, jsonb, timestamptz) from public, anon;
revoke execute on function recalculate_readiness(uuid) from public, anon;
revoke execute on function bump_daily_stats(uuid, int, int, int, int, int, int) from public, anon;
revoke execute on function upsert_user_skill(uuid, text, numeric, numeric, numeric) from public, anon;

grant execute on function track_lesson_progress(uuid, text, int, int) to authenticated;
grant execute on function submit_quiz_attempt(uuid, jsonb, timestamptz) to authenticated;
grant execute on function submit_challenge_attempt(uuid, jsonb, jsonb, timestamptz) to authenticated;
grant execute on function readiness_level(numeric) to authenticated, anon;
grant execute on function derive_skill_level(numeric) to authenticated;

-- recalculate_readiness / bump_daily_stats / upsert_user_skill are only ever
-- called from inside the other security-definer functions above, not directly
-- from the client, so authenticated does not need direct execute on them —
-- but Postgres still checks the caller's privilege inside definer functions
-- for nested calls, so authenticated needs it too:
grant execute on function recalculate_readiness(uuid) to authenticated;
grant execute on function bump_daily_stats(uuid, int, int, int, int, int, int) to authenticated;
grant execute on function upsert_user_skill(uuid, text, numeric, numeric, numeric) to authenticated;
