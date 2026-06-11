-- ============================================================================
-- FIX: Cho phép phụ huynh XÓA task template + submissions
-- Nguyên nhân lỗi "xóa rồi reload vẫn còn":
--   1. task_submissions.task_id là FK tới tasks(id) KHÔNG có ON DELETE CASCADE
--      → xóa task bị chặn khi còn submission tham chiếu.
--   2. Bảng tasks / task_submissions thiếu RLS policy cho DELETE
--      → Supabase âm thầm từ chối lệnh delete.
-- Chạy toàn bộ file này 1 lần trong Supabase SQL Editor.
-- ============================================================================

-- 1) Thêm ON DELETE CASCADE: xóa task tự động xóa hết submission của nó
ALTER TABLE task_submissions
  DROP CONSTRAINT IF EXISTS task_submissions_task_id_fkey;

ALTER TABLE task_submissions
  ADD CONSTRAINT task_submissions_task_id_fkey
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE;

-- 2) DELETE policy cho tasks: phụ huynh chỉ xóa task thuộc family của mình
DROP POLICY IF EXISTS "Parents delete own tasks" ON tasks;
CREATE POLICY "Parents delete own tasks" ON tasks
  FOR DELETE
  USING (
    family_id IN (
      SELECT id FROM families WHERE parent_id = auth.uid()
    )
  );

-- 3) DELETE policy cho task_submissions: phụ huynh xóa submission thuộc task của mình
DROP POLICY IF EXISTS "Parents delete own submissions" ON task_submissions;
CREATE POLICY "Parents delete own submissions" ON task_submissions
  FOR DELETE
  USING (
    task_id IN (
      SELECT t.id
      FROM tasks t
      JOIN families f ON t.family_id = f.id
      WHERE f.parent_id = auth.uid()
    )
  );
