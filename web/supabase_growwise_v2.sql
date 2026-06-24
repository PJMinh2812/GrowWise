-- ============================================================================
-- GrowWise v2 — Collect xu vào hũ + sổ Thu/Chi của con
-- Chạy 1 lần trên Supabase SQL editor (an toàn để chạy lại).
-- ============================================================================

-- 1) Xu của nhiệm vụ đã duyệt nhưng CHƯA được "collect" vào hũ
ALTER TABLE task_submissions
  ADD COLUMN IF NOT EXISTS collected boolean NOT NULL DEFAULT false;

-- 2) Sổ Thu/Chi (income = collect xu, expense = đổi quà / phụ huynh trừ)
CREATE TABLE IF NOT EXISTS child_transactions (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id   UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  type       TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount     INTEGER NOT NULL,
  note       TEXT,
  jar        TEXT,                       -- 'spend' | 'save' | 'share' (nếu có)
  created_by UUID,                       -- phụ huynh thực hiện (nếu có)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_child_transactions_child
  ON child_transactions (child_id, created_at DESC);

ALTER TABLE child_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read own child transactions" ON child_transactions;
CREATE POLICY "read own child transactions" ON child_transactions
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "service role full child transactions" ON child_transactions;
CREATE POLICY "service role full child transactions" ON child_transactions
  USING (true) WITH CHECK (true);
