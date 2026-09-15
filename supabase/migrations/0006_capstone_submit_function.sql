-- ============================================================================
-- Capstone project support:
-- 1. user_capstone_projects had no unique(user_id, project_id) constraint —
--    unlike every other "one row per user per content item" table
--    (user_lesson_progress, user_skills) — so nothing prevented duplicate
--    rows from piling up every time a learner saved progress. Fixed here.
-- 2. submit_capstone_project(): the client-facing entry point for
--    starting/saving/submitting the capstone. Unlike quizzes and challenges,
--    a capstone has no single correct answer to hide server-side — it's an
--    open-ended deliverable — so this function's "score" is a transparent,
--    self-assessed completeness percentage (how many of the project's own
--    published evaluation_criteria the learner has checked off against their
--    own submission), not an algorithmic grade. That distinction is
--    surfaced in the UI, not hidden.
-- ============================================================================

alter table user_capstone_projects
  add constraint user_capstone_projects_user_project_uniq unique (user_id, project_id);

create or replace function submit_capstone_project(
  p_project_id uuid,
  p_submission_data jsonb,
  p_checked_criteria text[],
  p_final boolean default false
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_user_id uuid := auth.uid();
  v_total_criteria text[];
  v_total int;
  v_checked int;
  v_score numeric;
  v_status text := case when p_final then 'completed' else 'in_progress' end;
begin
  select evaluation_criteria into v_total_criteria from capstone_projects where id = p_project_id;
  v_total := coalesce(array_length(v_total_criteria, 1), 0);
  v_checked := coalesce(array_length(p_checked_criteria, 1), 0);
  v_score := case when v_total > 0 then round(100.0 * least(v_checked, v_total) / v_total, 2) else null end;

  insert into user_capstone_projects (user_id, project_id, status, submission_data, score, started_at, completed_at)
  values (v_user_id, p_project_id, v_status, p_submission_data, v_score, now(),
    case when p_final then now() else null end)
  on conflict (user_id, project_id) do update set
    status = v_status,
    submission_data = p_submission_data,
    score = v_score,
    started_at = coalesce(user_capstone_projects.started_at, now()),
    completed_at = case when p_final then now() else user_capstone_projects.completed_at end;

  insert into learning_activities (user_id, activity_type, related_item_id, metadata)
  values (v_user_id, case when p_final then 'project_completed' else 'project_started' end,
    p_project_id, jsonb_build_object('self_assessed_completeness', v_score));

  return jsonb_build_object('status', v_status, 'self_assessed_completeness', v_score,
    'checked', v_checked, 'total', v_total);
end;
$$;

revoke execute on function submit_capstone_project(uuid, jsonb, text[], boolean) from public, anon;
grant execute on function submit_capstone_project(uuid, jsonb, text[], boolean) to authenticated;
