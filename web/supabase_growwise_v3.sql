-- ============================================================================
-- GrowWise v3 — phân loại mục tiêu ngắn hạn / dài hạn cho dream_items
-- Chạy 1 lần trên Supabase SQL editor (an toàn để chạy lại).
-- ============================================================================

-- 'short' = Mục tiêu ngắn hạn (sắp mua), 'long' = Mục tiêu lớn (dài hạn)
ALTER TABLE dream_items
  ADD COLUMN IF NOT EXISTS term text NOT NULL DEFAULT 'short';
