<p align="center">
  <img src="mobile/assets/images/app_logo.png" alt="GrowWise Logo" width="120" />
</p>

<h1 align="center">GrowWise</h1>

<p align="center">
  Nền tảng giáo dục tài chính dành cho trẻ em, được xây dựng bằng Flutter + Supabase
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-blue" alt="version" />
  <img src="https://img.shields.io/badge/flutter-3.x-54C5F8?logo=flutter" alt="flutter" />
  <img src="https://img.shields.io/badge/dart-^3.11-0175C2?logo=dart" alt="dart" />
  <img src="https://img.shields.io/badge/supabase-2.x-3ECF8E?logo=supabase" alt="supabase" />
  <img src="https://img.shields.io/badge/license-Internal-lightgrey" alt="license" />
</p>

---

## Giới thiệu

GrowWise giúp phụ huynh giao nhiệm vụ hằng ngày cho trẻ, thưởng xu khi hoàn thành, và dạy trẻ quản lý tiền qua hệ thống 3 hũ (tiêu dùng · tiết kiệm · sẻ chia). Ứng dụng được game hóa với XP, cấp độ, huy hiệu và gợi ý AI để trẻ luôn có động lực.

> **EXE201 — FPT University · Semester 8 · SU26**

---

## Tính năng nổi bật

| Nhóm | Tính năng |
|---|---|
| **Auth** | Email/password, Google OAuth, quên mật khẩu, xác nhận email |
| **Gia đình** | Đăng ký phụ huynh → tự động tạo gia đình → thêm hồ sơ trẻ |
| **Nhiệm vụ** | Tạo → nộp → duyệt/từ chối → thưởng xu tự động |
| **3 Hũ xu** | Chia xu tự động: Tiêu dùng 40% · Tiết kiệm 20% · Sẻ chia 40% |
| **Dream Jar** | Trẻ đặt mục tiêu tiết kiệm, theo dõi tiến trình |
| **AI** | Gợi ý nhiệm vụ cho phụ huynh, Dream Coach cho trẻ, báo cáo tổng hợp, tạo quiz tự động |
| **Gamification** | XP · cấp độ · huy hiệu · streak calendar · bảng thành tích |
| **Kết nối** | Bonding message từ phụ huynh, Memory Lane tự động sau mỗi nhiệm vụ |
| **Tiện ích** | Chia sẻ thành tích, thông báo push, bài học video |

---

## Kiến trúc

```
GrowWise/
├── mobile/                     # Flutter mobile app (iOS & Android)
│   └── lib/
│       ├── data/               # helpers, sample data
│       ├── models/             # data models
│       ├── providers/          # app state (Provider)
│       ├── screens/            # UI — auth / parent / child
│       ├── services/           # Supabase service layer
│       ├── theme/              # màu sắc, typography
│       └── utils/              # validators, helpers
└── admin/                      # Next.js admin panel
```

---

## Tech Stack

**Mobile (BE)**
- [Flutter](https://flutter.dev) · Dart `^3.11`
- State management: `provider ^6`
- Backend / Auth / Realtime DB: `supabase_flutter ^2`
- AI: Google Gemini API (`http`)
- Notifications: `flutter_local_notifications`
- Fonts: `google_fonts`, Animations: `flutter_animate`

**Admin Panel (FE)**
- [Next.js](https://nextjs.org) (App Router)
- TypeScript · Tailwind CSS
- Supabase JS client

---

## Yêu cầu

- Flutter stable ≥ 3.41
- Dart SDK theo phiên bản Flutter
- Android SDK + cmdline-tools (cho Android build)
- JDK 17+ (khuyến nghị)
- Node.js ≥ 18 (cho admin panel)
- Tài khoản [Supabase](https://supabase.com)

---

## Bắt đầu

### 1. Clone repo

```bash
git clone https://github.com/PJMinh2812/GrowWise.git
cd GrowWise
```

### 2. Cấu hình môi trường (Mobile)

```bash
cd BE
cp .env.example .env
```

Điền thông tin vào `.env`:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
GEMINI_API_KEY=<your-gemini-key>
```

### 3. Cài dependencies và chạy

```bash
# Mobile app
cd mobile
flutter pub get
flutter run

# Admin panel (terminal khác)
cd admin
npm install
npm run dev          # http://localhost:3000
```

---

## Cấu hình Google OAuth

1. **Google Cloud Console** → tạo OAuth client loại *Web* → thêm redirect URI:
   ```
   https://<your-project-ref>.supabase.co/auth/v1/callback
   ```

2. **Supabase Dashboard** → Authentication → Providers → Google → bật, dán Client ID & Secret.

3. **Supabase URL Configuration** → thêm redirect URL cho mobile:
   ```
   io.supabase.growwise://login-callback
   ```

> Deep link Android đã được khai báo trong `mobile/android/app/src/main/AndroidManifest.xml`.

---

## Database

Schema đầy đủ và migration scripts nằm trong `BE/`:

| File | Mục đích |
|---|---|
| `mobile/supabase_schema.sql` | Schema hoàn chỉnh với RLS, triggers, indexes |
| `mobile/supabase_rls_fix.sql` | Fix RLS infinite recursion (families ↔ children) |
| `mobile/supabase_migration_v2.sql` | Thêm `bonding_message`, `streak_days` |

---

## Đóng góp

1. Tạo branch từ `develop`
2. Commit theo [Conventional Commits](https://www.conventionalcommits.org/)
3. Mở Pull Request về `develop`

```
feat(auth):    add Google OAuth callback handling
fix(tasks):    use dynamic coin reward in approval flow
chore(repo):   update gitignore for env files
```

---

## License

Nội bộ — chỉ dùng cho mục đích học tập và demo tại FPT University.
