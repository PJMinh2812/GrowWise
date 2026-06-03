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
