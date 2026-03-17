-- ============================================================================
-- GrowWise - RLS Infinite Recursion Fix
-- Chạy file này trong Supabase Dashboard > SQL Editor
-- Lỗi: code 42P17 - infinite recursion detected in policy for relation "families"
-- Nguyên nhân: families policy tham chiếu children, children policy tham chiếu families
-- Giải pháp: dùng SECURITY DEFINER functions để tránh vòng lặp
-- ============================================================================

-- Bước 1: Xóa các policy gây recursion
DROP POLICY IF EXISTS "Children can view their family" ON families;
DROP POLICY IF EXISTS "Parents can manage children" ON children;

-- Bước 2: Tạo helper functions với SECURITY DEFINER (bypass RLS)

-- Lấy parent_id của một family (dùng trong children policy)
CREATE OR REPLACE FUNCTION get_family_parent_id(family_uuid UUID)
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT parent_id FROM public.families WHERE id = family_uuid;
$$;

-- Lấy family_id của một child user (dùng trong families policy)
CREATE OR REPLACE FUNCTION get_child_family_id(user_uuid UUID)
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT family_id FROM public.children WHERE user_id = user_uuid LIMIT 1;
$$;

-- Bước 3: Tạo lại policies dùng helper functions (không còn recursion)

-- families: children xem family của mình
CREATE POLICY "Children can view their family" ON families
  FOR SELECT USING (
    id = get_child_family_id(auth.uid())
  );

-- children: parents quản lý con
CREATE POLICY "Parents can manage children" ON children
  FOR ALL USING (
    get_family_parent_id(family_id) = auth.uid()
  );

-- ============================================================================
-- Xong! Test bằng cách đăng nhập lại vào app
-- ============================================================================
