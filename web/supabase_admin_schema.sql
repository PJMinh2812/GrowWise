-- ============================================================================
-- GrowWise Admin Panel — Supabase Schema
-- Chạy trong Supabase Dashboard > SQL Editor
-- ============================================================================

CREATE TABLE IF NOT EXISTS admin_profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('admin', 'staff')),
  is_banned     BOOLEAN NOT NULL DEFAULT false,
  access_granted BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Chỉ service role mới được đọc/ghi (middleware dùng service role key)
ALTER TABLE admin_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role full access" ON admin_profiles
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- Sau khi chạy SQL này, vào Vercel Dashboard > Project Settings > Environment
-- Variables và thêm:
--   SUPABASE_SERVICE_ROLE_KEY = (lấy từ Supabase Dashboard > Settings > API)
--   ADMIN_EMAILS              = email của admin, vd: admin@gmail.com
-- ============================================================================

-- ============================================================================
-- Pricing & Subscription Tables
-- ============================================================================

CREATE TABLE IF NOT EXISTS plans (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                  TEXT NOT NULL UNIQUE CHECK (name IN ('free', 'premium', 'family')),
  display_name          TEXT NOT NULL,
  price_monthly         INTEGER NOT NULL DEFAULT 0,  -- VND
  price_yearly          INTEGER,                     -- VND với discount 20%
  max_children          INTEGER NOT NULL DEFAULT 1,
  max_daily_ai_messages INTEGER NOT NULL DEFAULT 5,
  max_active_tasks      INTEGER NOT NULL DEFAULT 3,
  max_lessons           INTEGER NOT NULL DEFAULT 3,  -- 999 = unlimited
  features              JSONB,
  is_active             BOOLEAN NOT NULL DEFAULT true,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed 3 default plans
INSERT INTO plans (name, display_name, price_monthly, price_yearly, max_children, max_daily_ai_messages, max_active_tasks, max_lessons, features)
VALUES
  ('free',    'Cơ Bản',   0,      NULL,    1, 5,   3,   3,   '["lessons_basic","jars","tasks_basic","ai_chat_limited","minigame_2"]'::jsonb),
  ('premium', 'Nâng Cao', 79000,  749000,  1, 999, 999, 999, '["lessons_all","jars","tasks_unlimited","ai_chat_unlimited","minigame_all","ai_reports","savings_analytics","custom_badges","task_templates"]'::jsonb),
  ('family',  'Gia Đình', 149000, 1419000, 3, 999, 999, 999, '["lessons_all","jars","tasks_unlimited","ai_chat_unlimited","minigame_all","ai_reports","savings_analytics","custom_badges","task_templates","multi_children","family_dashboard"]'::jsonb)
ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id               UUID NOT NULL REFERENCES plans(id),
  status                TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'expired', 'trial')),
  billing_interval      TEXT NOT NULL DEFAULT 'monthly' CHECK (billing_interval IN ('monthly', 'yearly')),
  trial_ends_at         TIMESTAMPTZ,
  current_period_start  TIMESTAMPTZ NOT NULL DEFAULT now(),
  current_period_end    TIMESTAMPTZ,
  payment_method        TEXT CHECK (payment_method IN ('momo', 'vnpay', 'zalopay', 'card', 'payos')),
  -- Scheduled (downgrade) plan applied at the end of the current period.
  scheduled_plan_name   TEXT CHECK (scheduled_plan_name IN ('free', 'premium', 'family')),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

CREATE TABLE IF NOT EXISTS daily_ai_usage (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date          DATE NOT NULL DEFAULT CURRENT_DATE,
  message_count INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, date)
);

-- Daily emotion check-in usage (free 1 / premium 3 / family unlimited).
CREATE TABLE IF NOT EXISTS daily_emotion_usage (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date    DATE NOT NULL DEFAULT CURRENT_DATE,
  count   INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, date)
);

-- RLS: users only access their own subscription/usage; admin via service role
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_ai_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_emotion_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read plans" ON plans FOR SELECT USING (true);
CREATE POLICY "Service role full access plans" ON plans USING (true) WITH CHECK (true);

CREATE POLICY "Users read own subscription" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service role full access subscriptions" ON user_subscriptions
  USING (true) WITH CHECK (true);

CREATE POLICY "Users manage own ai usage" ON daily_ai_usage
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Service role full access ai usage" ON daily_ai_usage
  USING (true) WITH CHECK (true);

CREATE POLICY "Users manage own emotion usage" ON daily_emotion_usage
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Service role full access emotion usage" ON daily_emotion_usage
  USING (true) WITH CHECK (true);

-- ── Migration for existing databases (run once on the live DB) ────────────────
-- ALTER TABLE user_subscriptions
--   ADD COLUMN IF NOT EXISTS scheduled_plan_name TEXT
--   CHECK (scheduled_plan_name IN ('free', 'premium', 'family'));
--
-- CREATE TABLE IF NOT EXISTS daily_emotion_usage (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
--   date DATE NOT NULL DEFAULT CURRENT_DATE,
--   count INTEGER NOT NULL DEFAULT 0,
--   UNIQUE(user_id, date)
-- );
-- ALTER TABLE daily_emotion_usage ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users manage own emotion usage" ON daily_emotion_usage
--   USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Service role full access emotion usage" ON daily_emotion_usage
--   USING (true) WITH CHECK (true);

-- ── RPC function: upsert + increment daily AI usage ──────────────────────────
-- Cần chạy sau khi tạo bảng daily_ai_usage
CREATE OR REPLACE FUNCTION increment_ai_usage(p_user_id UUID, p_date DATE)
RETURNS void AS $$
BEGIN
  INSERT INTO daily_ai_usage (user_id, date, message_count)
  VALUES (p_user_id, p_date, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET message_count = daily_ai_usage.message_count + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Payment Transactions
-- ============================================================================

CREATE TABLE IF NOT EXISTS payment_transactions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id                TEXT NOT NULL UNIQUE,
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_name               TEXT NOT NULL,
  billing_interval        TEXT NOT NULL DEFAULT 'monthly',
  amount                  INTEGER NOT NULL,
  status                  TEXT NOT NULL DEFAULT 'pending'
                            CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
  provider                TEXT NOT NULL DEFAULT 'momo'
                            CHECK (provider IN ('momo', 'vnpay', 'zalopay', 'card', 'payos')),
  provider_transaction_id TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own payments" ON payment_transactions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service role full access payments" ON payment_transactions
  USING (true) WITH CHECK (true);
