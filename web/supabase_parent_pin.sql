-- GrowWise web app migration — chạy 1 lần trong Supabase SQL Editor.

-- 1) PIN bảo vệ chế độ Cha mẹ (web + mobile).
--    Lưu hash SHA-256 của (user_id:pin); không lưu PIN dạng plain.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS parent_pin_hash TEXT;

-- 2) RPC tăng/giảm approval_count cho task template.
CREATE OR REPLACE FUNCTION increment_task_approval_count(p_task_id UUID)
RETURNS void LANGUAGE sql AS $$
  UPDATE tasks SET approval_count = approval_count + 1 WHERE id = p_task_id;
$$;

CREATE OR REPLACE FUNCTION decrement_task_approval_count(p_task_id UUID)
RETURNS void LANGUAGE sql AS $$
  UPDATE tasks SET approval_count = GREATEST(0, approval_count - 1) WHERE id = p_task_id;
$$;
