-- ============================================================================
-- Lesson completions — theo dõi trẻ đã hoàn thành bài học nào (cho lộ trình Learn)
-- Chạy 1 lần trên Supabase SQL editor (an toàn để chạy lại).
-- ============================================================================

CREATE TABLE IF NOT EXISTS lesson_completions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id     UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  lesson_id    UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (child_id, lesson_id)
);

ALTER TABLE lesson_completions ENABLE ROW LEVEL SECURITY;

-- Truy cập qua service role (server actions). Thêm policy đọc cho an toàn.
DROP POLICY IF EXISTS "Service role full access lesson_completions" ON lesson_completions;
CREATE POLICY "Service role full access lesson_completions" ON lesson_completions
  USING (true) WITH CHECK (true);
