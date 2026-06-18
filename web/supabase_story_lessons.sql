-- GrowWise web app migration — chạy 1 lần trong Supabase SQL Editor.
-- Thêm loại bài học "Truyện tranh" (story): trẻ đọc từng trang ảnh + lời kể.

-- 1) Cột phân loại bài học và dữ liệu trang truyện.
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS lesson_type TEXT NOT NULL DEFAULT 'video'
    CHECK (lesson_type IN ('video', 'story'));

-- Mỗi phần tử: { "image_url": "...", "caption": "..." }
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS story_pages JSONB NOT NULL DEFAULT '[]'::jsonb;

-- Ảnh thumbnail tùy chọn cho bài học / truyện (nếu rỗng → dùng thumbnail_emoji).
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- Bài truyện không có video → cho phép youtube_id rỗng/null.
ALTER TABLE lessons ALTER COLUMN youtube_id DROP NOT NULL;

-- 2) Bucket lưu ảnh truyện (công khai, đọc tự do; ghi cần đăng nhập).
INSERT INTO storage.buckets (id, name, public)
VALUES ('lesson-images', 'lesson-images', true)
ON CONFLICT (id) DO NOTHING;

-- Ai cũng đọc được ảnh truyện (bucket công khai).
DROP POLICY IF EXISTS "Public read lesson images" ON storage.objects;
CREATE POLICY "Public read lesson images" ON storage.objects
  FOR SELECT USING (bucket_id = 'lesson-images');

-- Người dùng đã đăng nhập (admin) được upload / sửa / xóa ảnh truyện.
DROP POLICY IF EXISTS "Authenticated write lesson images" ON storage.objects;
CREATE POLICY "Authenticated write lesson images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'lesson-images');

DROP POLICY IF EXISTS "Authenticated update lesson images" ON storage.objects;
CREATE POLICY "Authenticated update lesson images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'lesson-images')
  WITH CHECK (bucket_id = 'lesson-images');

DROP POLICY IF EXISTS "Authenticated delete lesson images" ON storage.objects;
CREATE POLICY "Authenticated delete lesson images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'lesson-images');
