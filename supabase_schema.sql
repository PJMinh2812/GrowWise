-- ============================================================================
-- GrowWise - Supabase Database Schema
-- Chạy file này trong Supabase Dashboard > SQL Editor
-- ============================================================================

-- 1. PROFILES TABLE (liên kết với Supabase Auth)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL CHECK (role IN ('parent', 'child')) DEFAULT 'parent',
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. FAMILIES TABLE (liên kết Parent - Child)
CREATE TABLE families (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  family_code TEXT NOT NULL UNIQUE DEFAULT substr(md5(random()::text), 1, 6),
  family_name TEXT NOT NULL DEFAULT 'Gia đình',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. CHILDREN TABLE (hồ sơ con)
CREATE TABLE children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL, -- nếu trẻ có tài khoản riêng
  name TEXT NOT NULL,
  age INTEGER NOT NULL DEFAULT 8 CHECK (age >= 3 AND age <= 18),
  avatar_emoji TEXT NOT NULL DEFAULT '👦',
  level INTEGER NOT NULL DEFAULT 1 CHECK (level >= 1),
  total_coins INTEGER NOT NULL DEFAULT 0 CHECK (total_coins >= 0),
  spend_jar INTEGER NOT NULL DEFAULT 0 CHECK (spend_jar >= 0),
  save_jar INTEGER NOT NULL DEFAULT 0 CHECK (save_jar >= 0),
  share_jar INTEGER NOT NULL DEFAULT 0 CHECK (share_jar >= 0),
  xp INTEGER NOT NULL DEFAULT 0 CHECK (xp >= 0),
  xp_to_next_level INTEGER NOT NULL DEFAULT 100,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. BADGES TABLE
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '⭐',
  earned_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. TASKS TABLE
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL CHECK (length(title) >= 2 AND length(title) <= 100),
  description TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT 'Việc nhà' CHECK (category IN ('Việc nhà', 'Học tập', 'Sức khỏe', 'Sáng tạo')),
  icon TEXT NOT NULL DEFAULT '📋',
  coin_reward INTEGER NOT NULL CHECK (coin_reward >= 1 AND coin_reward <= 1000),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'submitted', 'approved', 'rejected')),
  proof_image_url TEXT,
  parent_note TEXT,
  submitted_at TIMESTAMPTZ,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. DREAM ITEMS TABLE
CREATE TABLE dream_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (length(name) >= 1 AND length(name) <= 100),
  price INTEGER NOT NULL CHECK (price >= 1),
  icon TEXT NOT NULL DEFAULT '🎁',
  is_purchased BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. MEMORIES TABLE
CREATE TABLE memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  task_title TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '📷',
  note TEXT NOT NULL DEFAULT '',
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. SETTINGS TABLE (cài đặt per-user)
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,
  language TEXT NOT NULL DEFAULT 'vi',
  has_seen_onboarding BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) - Bảo mật dữ liệu
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE dream_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Profiles: user chỉ xem/sửa profile của mình
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================================
-- SECURITY DEFINER helper functions (tránh RLS infinite recursion)
-- Các function này bypass RLS để dùng trong policy mà không gây vòng lặp
-- ============================================================================

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

-- Families: parent xem gia đình mình tạo
CREATE POLICY "Parents can manage their families" ON families
  FOR ALL USING (auth.uid() = parent_id);
-- Children can view their family using SECURITY DEFINER function (tránh recursion)
CREATE POLICY "Children can view their family" ON families
  FOR SELECT USING (
    id = get_child_family_id(auth.uid())
  );

-- Children: parent quản lý; child xem info mình
-- Dùng get_family_parent_id() thay vì sub-select trực tiếp vào families (tránh recursion)
CREATE POLICY "Parents can manage children" ON children
  FOR ALL USING (
    get_family_parent_id(family_id) = auth.uid()
  );
CREATE POLICY "Children can view themselves" ON children
  FOR SELECT USING (user_id = auth.uid());

-- Tasks: family members xem tasks
CREATE POLICY "Family members can view tasks" ON tasks
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM families WHERE families.id = tasks.family_id AND families.parent_id = auth.uid())
    OR EXISTS (SELECT 1 FROM children WHERE children.id = tasks.child_id AND children.user_id = auth.uid())
  );
CREATE POLICY "Parents can create tasks" ON tasks
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM families WHERE families.id = tasks.family_id AND families.parent_id = auth.uid())
  );
CREATE POLICY "Parents can update tasks" ON tasks
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM families WHERE families.id = tasks.family_id AND families.parent_id = auth.uid())
  );
-- Children can submit tasks (update status to submitted)
CREATE POLICY "Children can submit tasks" ON tasks
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM children WHERE children.id = tasks.child_id AND children.user_id = auth.uid())
  );

-- Badges: child xem badges mình
CREATE POLICY "Family can view badges" ON badges
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM children c JOIN families f ON c.family_id = f.id
            WHERE c.id = badges.child_id AND (f.parent_id = auth.uid() OR c.user_id = auth.uid()))
  );
CREATE POLICY "System can insert badges" ON badges
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM children c JOIN families f ON c.family_id = f.id
            WHERE c.id = badges.child_id AND f.parent_id = auth.uid())
  );

-- Dream items
CREATE POLICY "Family can manage dream items" ON dream_items
  FOR ALL USING (
    EXISTS (SELECT 1 FROM children c JOIN families f ON c.family_id = f.id
            WHERE c.id = dream_items.child_id AND (f.parent_id = auth.uid() OR c.user_id = auth.uid()))
  );

-- Memories
CREATE POLICY "Family can view memories" ON memories
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM families WHERE families.id = memories.family_id AND families.parent_id = auth.uid())
    OR EXISTS (SELECT 1 FROM children WHERE children.id = memories.child_id AND children.user_id = auth.uid())
  );
CREATE POLICY "Parents can insert memories" ON memories
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM families WHERE families.id = memories.family_id AND families.parent_id = auth.uid())
  );

-- Settings
CREATE POLICY "Users manage own settings" ON user_settings
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- INDEXES cho performance
-- ============================================================================
CREATE INDEX idx_families_parent ON families(parent_id);
CREATE INDEX idx_children_family ON children(family_id);
CREATE INDEX idx_children_user ON children(user_id);
CREATE INDEX idx_tasks_family ON tasks(family_id);
CREATE INDEX idx_tasks_child ON tasks(child_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_badges_child ON badges(child_id);
CREATE INDEX idx_dream_items_child ON dream_items(child_id);
CREATE INDEX idx_memories_family ON memories(family_id);

-- ============================================================================
-- FUNCTION: Tự tạo profile khi user đăng ký
-- ============================================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'parent')
  );
  
  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- FUNCTION: Tự tạo family khi parent đăng ký xong
-- ============================================================================
CREATE OR REPLACE FUNCTION create_family_for_parent()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF NEW.role = 'parent' THEN
    INSERT INTO public.families (parent_id, family_name)
    VALUES (NEW.id, 'Gia đình ' || NEW.full_name);
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_parent_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_family_for_parent();

-- ============================================================================
-- Xong! Bây giờ bật Authentication > Email trong Supabase Dashboard
-- ============================================================================
