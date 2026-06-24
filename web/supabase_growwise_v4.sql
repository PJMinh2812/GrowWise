-- GrowWise v4 — daily task cycle (auto-approve at midnight + penalty for missed)
-- Allow the new 'missed' submission status and speed up "today's submissions".

-- task_submissions.status may have a CHECK constraint limiting the allowed values.
-- Drop it (if present) and recreate it to include 'missed'. Safe if the column
-- was previously free text (the DROP is conditional, the values already exist).
ALTER TABLE task_submissions
  DROP CONSTRAINT IF EXISTS task_submissions_status_check;

ALTER TABLE task_submissions
  ADD CONSTRAINT task_submissions_status_check
  CHECK (status IN ('pending', 'submitted', 'approved', 'rejected', 'missed'));

-- "Today's submissions" lookup (child/tasks page + daily-rollover cron).
CREATE INDEX IF NOT EXISTS idx_task_submissions_child_created
  ON task_submissions (child_id, created_at);
