-- ============================================================================
-- GrowWise — toàn bộ migration (chạy trên Supabase SQL editor).
-- An toàn để chạy lại nhiều lần (idempotent). Chạy SAU khi đã có schema gốc
-- (families, children, tasks, task_submissions, dream_items, lessons,
--  payment_transactions, user_subscriptions, ...).
-- Thứ tự: v2 → v3 → v4 → v5 → lesson_completions → SePay.
-- ============================================================================


-- ============================================================================
-- GrowWise v2 — Collect xu vào hũ + sổ Thu/Chi của con
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


-- ============================================================================
-- GrowWise v3 — phân loại mục tiêu ngắn hạn / dài hạn cho dream_items
-- 'short' = Mục tiêu ngắn hạn (sắp mua), 'long' = Mục tiêu lớn (dài hạn)
-- ============================================================================

ALTER TABLE dream_items
  ADD COLUMN IF NOT EXISTS term text NOT NULL DEFAULT 'short';


-- ============================================================================
-- GrowWise v4 — chu trình nhiệm vụ theo ngày (auto-duyệt cuối ngày + phạt bỏ lỡ)
-- ============================================================================

-- Cho phép trạng thái 'missed' (bỏ lỡ) ở task_submissions.
ALTER TABLE task_submissions
  DROP CONSTRAINT IF EXISTS task_submissions_status_check;
ALTER TABLE task_submissions
  ADD CONSTRAINT task_submissions_status_check
  CHECK (status IN ('pending', 'submitted', 'approved', 'rejected', 'missed'));

-- Tra cứu "bài nộp hôm nay" (trang nhiệm vụ + cron daily-rollover).
CREATE INDEX IF NOT EXISTS idx_task_submissions_child_created
  ON task_submissions (child_id, created_at);


-- ============================================================================
-- GrowWise v5 — lộ trình chuyên gia 1 năm: timeline theo giờ + 12 chặng
-- ============================================================================

-- 1) Lịch cho nhiệm vụ (giờ hẹn / thời lượng / tần suất / chặng).
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS scheduled_time time;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS duration_minutes int NOT NULL DEFAULT 15;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS frequency text NOT NULL DEFAULT 'daily';
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS stage int NOT NULL DEFAULT 1;

-- 2) Đánh dấu bài nộp trễ giờ (bị giảm thưởng).
ALTER TABLE task_submissions ADD COLUMN IF NOT EXISTS was_late boolean NOT NULL DEFAULT false;

-- 3) Kế hoạch năm của mỗi bé: 12 chặng kỹ năng tiền + chặng hiện tại.
CREATE TABLE IF NOT EXISTS roadmap_plans (
  child_id uuid PRIMARY KEY REFERENCES children(id) ON DELETE CASCADE,
  current_stage int NOT NULL DEFAULT 1,
  stages jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE roadmap_plans ENABLE ROW LEVEL SECURITY;

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


-- ============================================================================
-- Lesson completions — theo dõi bé đã hoàn thành bài học nào (lộ trình Learn)
-- ============================================================================

CREATE TABLE IF NOT EXISTS lesson_completions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id     UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  lesson_id    UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (child_id, lesson_id)
);

ALTER TABLE lesson_completions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role full access lesson_completions" ON lesson_completions;
CREATE POLICY "Service role full access lesson_completions" ON lesson_completions
  USING (true) WITH CHECK (true);


-- ============================================================================
-- SePay — chỉ cho phép 'sepay' làm payment provider / payment method
-- Thứ tự: DROP ràng buộc cũ → UPDATE dữ liệu cũ → ADD ràng buộc mới.
-- ============================================================================

-- 1) Gỡ ràng buộc cũ
ALTER TABLE payment_transactions DROP CONSTRAINT IF EXISTS payment_transactions_provider_check;
ALTER TABLE user_subscriptions   DROP CONSTRAINT IF EXISTS user_subscriptions_payment_method_check;

-- 2) Dọn dữ liệu cũ về 'sepay'
UPDATE payment_transactions SET provider = 'sepay' WHERE provider <> 'sepay';
UPDATE user_subscriptions   SET payment_method = 'sepay' WHERE payment_method IS NOT NULL AND payment_method <> 'sepay';

-- 3) Thêm ràng buộc mới (chỉ 'sepay') + đổi default
ALTER TABLE payment_transactions ALTER COLUMN provider SET DEFAULT 'sepay';
ALTER TABLE payment_transactions
  ADD CONSTRAINT payment_transactions_provider_check
  CHECK (provider = 'sepay');

-- user_subscriptions.payment_method vẫn cho phép NULL cho gói dùng thử
ALTER TABLE user_subscriptions
  ADD CONSTRAINT user_subscriptions_payment_method_check
  CHECK (payment_method = 'sepay');
