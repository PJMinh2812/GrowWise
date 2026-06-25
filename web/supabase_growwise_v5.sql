-- GrowWise v5 — expert 1-year roadmap: scheduled timeline tasks + 12 monthly stages.

-- 1. Scheduling fields on tasks (time-of-day timeline, duration, frequency, stage).
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS scheduled_time time;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS duration_minutes int NOT NULL DEFAULT 15;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS frequency text NOT NULL DEFAULT 'daily';
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS stage int NOT NULL DEFAULT 1;

-- 2. Mark a submission that was handed in after its scheduled time (late → -%).
ALTER TABLE task_submissions ADD COLUMN IF NOT EXISTS was_late boolean NOT NULL DEFAULT false;

-- 3. Per-child year plan: the 12 monthly money-skill stages + which one is active.
CREATE TABLE IF NOT EXISTS roadmap_plans (
  child_id uuid PRIMARY KEY REFERENCES children(id) ON DELETE CASCADE,
  current_stage int NOT NULL DEFAULT 1,
  stages jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE roadmap_plans ENABLE ROW LEVEL SECURITY;

-- Parents can read/write the plan for children in their own family.
DROP POLICY IF EXISTS roadmap_plans_owner ON roadmap_plans;
CREATE POLICY roadmap_plans_owner ON roadmap_plans
  USING (
    child_id IN (
      SELECT c.id FROM children c
      JOIN families f ON f.id = c.family_id
      WHERE f.parent_id = auth.uid()
    )
  )
  WITH CHECK (
    child_id IN (
      SELECT c.id FROM children c
      JOIN families f ON f.id = c.family_id
      WHERE f.parent_id = auth.uid()
    )
  );
