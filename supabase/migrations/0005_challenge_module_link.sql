-- ============================================================================
-- Fix: challenges had no module_id, so the app could only ever show a single
-- global challenge (app/(learner)/learn/[lessonId]/page.tsx did
-- `.from("challenges").select(...).limit(1)`). That was harmless with exactly
-- one challenge in the whole database, but breaks the moment a second one
-- exists. This adds the missing link and backfills the existing challenge
-- onto its module (Level 2 — Cloud Computing Foundations).
-- ============================================================================

alter table challenges add column module_id uuid references modules(id) on delete cascade;
create index idx_challenges_module on challenges(module_id);

-- Backfill: the one existing seeded challenge ("Diagnose the Surprise Cloud
-- Bill") belongs to the Level 2 "Core Cloud Concepts" module.
update challenges
set module_id = (
  select m.id
  from modules m
  join courses c on c.id = m.course_id
  join learning_paths lp on lp.id = c.learning_path_id
  where lp.sequence_order = 2
  limit 1
)
where title = 'Diagnose the Surprise Cloud Bill' and module_id is null;
