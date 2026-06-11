<p align="center">
  <img src="mobile/assets/images/app_logo.png" alt="GrowWise Logo" width="120" />
</p>

<h1 align="center">GrowWise</h1>

<p align="center">
  Nền tảng giáo dục tài chính dành cho trẻ em, được xây dựng bằng Flutter + Next.js + Supabase
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-2.2.0-blue" alt="version" />
  <img src="https://img.shields.io/badge/flutter-3.x-54C5F8?logo=flutter" alt="flutter" />
  <img src="https://img.shields.io/badge/dart-^3.11-0175C2?logo=dart" alt="dart" />
  <img src="https://img.shields.io/badge/next.js-15-black?logo=next.js" alt="nextjs" />
  <img src="https://img.shields.io/badge/supabase-2.x-3ECF8E?logo=supabase" alt="supabase" />
  <img src="https://img.shields.io/badge/license-Internal-lightgrey" alt="license" />
</p>

---

## Giới thiệu

GrowWise giúp phụ huynh giao nhiệm vụ hằng ngày cho trẻ, thưởng xu khi hoàn thành, và dạy trẻ quản lý tiền qua hệ thống 3 hũ (tiêu dùng · tiết kiệm · sẻ chia). Ứng dụng được game hóa với XP, cấp độ, huy hiệu và gợi ý AI để trẻ luôn có động lực.

> **EXE101 — FPT University · Semester 9 · SU26**

---

## Tính năng nổi bật

### Mobile App

| Nhóm | Tính năng |
|---|---|
| **Auth** | Email/password, Google OAuth, quên mật khẩu, xác nhận email |
| **Gia đình** | Đăng ký phụ huynh → tự động tạo gia đình → thêm hồ sơ trẻ |
| **Nhiệm vụ** | Tạo → nộp → duyệt/từ chối → thưởng xu tự động |
| **3 Hũ xu** | Chia xu tự động: Tiêu dùng 40% · Tiết kiệm 20% · Sẻ chia 40% |
| **Dream Jar** | Trẻ đặt mục tiêu tiết kiệm, theo dõi tiến trình |
| **AI Wisy** | Gợi ý nhiệm vụ cho phụ huynh, Dream Coach cho trẻ, báo cáo tổng hợp, tạo quiz tự động |
| **Gamification** | XP · cấp độ · huy hiệu · streak calendar · bảng thành tích |
| **Kết nối** | Bonding message từ phụ huynh, Memory Lane tự động sau mỗi nhiệm vụ |
| **Bài học** | Video lessons với quiz trắc nghiệm, lọc theo chủ đề |
| **Thanh toán** | MoMo deeplink · Chuyển khoản QR (PayOS/VietQR) |
| **Gói dịch vụ** | Free · Premium (79k/tháng) · Family (149k/tháng) |

### Admin Panel (Web)

| Nhóm | Tính năng |
|---|---|
| **Dashboard** | Thống kê doanh thu, người dùng, gói đăng ký; xuất báo cáo CSV |
| **Bài học** | Quản lý video lessons, quiz, phân loại, bật/tắt xuất bản |
| **Định giá** | Chỉnh giá, tên gói, tự tính giá năm theo % giảm giá |
| **Nhân sự** | Mời staff/admin, cấp/thu hồi quyền, khóa tài khoản, lọc theo vai trò |
| **Giao dịch** | Tự động hủy giao dịch pending quá 15 phút |
| **Phân quyền** | Admin: toàn quyền — Staff: chỉ xem dashboard/bài học/định giá |

---

## Kiến trúc

```
GrowWise/
├── mobile/                     # Flutter mobile app (iOS & Android)
│   └── lib/
│       ├── data/               # helpers, sample data
│       ├── models/             # data models
│       ├── providers/          # app state (Provider)
│       ├── screens/
│       │   ├── child/          # giao diện trẻ em
│       │   ├── parent/         # giao diện phụ huynh
│       │   └── shared/         # video lessons, pricing, AI chat
│       ├── services/           # Supabase, Payment, Gemini
│       ├── theme/              # màu sắc, typography
│       └── utils/              # validators, helpers
└── admin/                      # Next.js 15 admin panel
    ├── app/
    │   ├── admin/              # dashboard, lessons, pricing, users
    │   ├── api/
    │   │   ├── admin/          # stats, pricing, users API
    │   │   ├── payment/        # MoMo IPN, PayOS webhook
    │   │   └── cron/           # expire-payments (Vercel cron)
    │   └── page.tsx            # landing page
    ├── components/
    │   ├── landing/            # hero, features, pricing, footer...
    │   └── Admin*.tsx          # sidebar, shell
    └── proxy.ts                # auth guard + role-based routing
```

---

## Tech Stack

**Mobile**
- [Flutter](https://flutter.dev) · Dart `^3.11`
- State management: `provider ^6`
- Backend / Auth / DB: `supabase_flutter ^2`
- AI: Google Gemini API
- Thanh toán: MoMo deeplink · [PayOS](https://payos.vn) VietQR
- Notifications: `flutter_local_notifications`
- Fonts: `google_fonts` · Animations: `flutter_animate`

**Admin Panel**
- [Next.js 15](https://nextjs.org) (App Router) · TypeScript
- Tailwind CSS v4 (Stitch design system)
- Supabase SSR (`@supabase/ssr`)
- Vercel Cron Jobs (tự động expire giao dịch)
- Deployed on [Vercel](https://vercel.com)

**Backend**
- [Supabase](https://supabase.com): Auth · PostgreSQL · Row Level Security
- Supabase Edge Functions (webhook handler)

---

## Yêu cầu

- Flutter stable ≥ 3.41
- Dart SDK theo phiên bản Flutter
- Android SDK + cmdline-tools
- JDK 17+
- Node.js ≥ 18 + pnpm (cho admin panel)
- Tài khoản [Supabase](https://supabase.com)
- Tài khoản [PayOS](https://payos.vn) (sandbox miễn phí)
- Tài khoản MoMo Business (cho thanh toán thực)

---

## Bắt đầu

### 1. Clone repo

```bash
git clone https://github.com/PJMinh2812/GrowWise.git
cd GrowWise
```

### 2. Cấu hình môi trường Mobile

Tạo file `mobile/lib/supabase_config.dart` (hoặc dùng env):

```dart
const supabaseUrl = 'https://<your-project-ref>.supabase.co';
const supabaseAnonKey = '<your-anon-key>';
```

### 3. Cấu hình môi trường Admin

```bash
cd admin
cp .env.example .env.local   # hoặc tạo mới
```

```env
NEXT_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
ADMIN_EMAILS=your@email.com
GEMINI_API_KEY=<your-gemini-key>

# MoMo (UAT sandbox)
MOMO_PARTNER_CODE=MOMOBKUN20180529
MOMO_ACCESS_KEY=<your-access-key>
MOMO_SECRET_KEY=<your-secret-key>

# PayOS (VietQR)
PAYOS_CLIENT_ID=<your-client-id>
PAYOS_API_KEY=<your-api-key>
PAYOS_CHECKSUM_KEY=<your-checksum-key>

NEXT_PUBLIC_APP_URL=https://your-domain.vercel.app

# Vercel cron authentication
CRON_SECRET=<random-secret-string>
```

### 4. Chạy local

```bash
# Mobile app
cd mobile
flutter pub get
flutter run

# Admin panel (terminal khác)
cd admin
pnpm install
pnpm dev          # http://localhost:3000
```

### 5. Build APK

```bash
cd mobile
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Cấu hình Google OAuth

1. **Google Cloud Console** → tạo OAuth client *Web* → thêm redirect URI:
   ```
   https://<your-project-ref>.supabase.co/auth/v1/callback
   ```

2. **Supabase Dashboard** → Authentication → Providers → Google → bật, dán Client ID & Secret.

3. **Supabase URL Configuration** → thêm redirect URL:
   ```
   io.supabase.growwise://login-callback
   ```

> Deep link Android đã được khai báo trong `mobile/android/app/src/main/AndroidManifest.xml`.

---

## Database

| File | Mục đích |
|---|---|
| `mobile/supabase_schema.sql` | Schema hoàn chỉnh với RLS, triggers, indexes |
| `mobile/supabase_rls_fix.sql` | Fix RLS infinite recursion (families ↔ children) |
| `mobile/supabase_migration_v2.sql` | Thêm `bonding_message`, `streak_days` |
| `admin/supabase_admin_schema.sql` | Admin profiles, plans, subscriptions, transactions |

---

## Phân quyền Admin

| Trang | Admin | Staff |
|---|---|---|
| Dashboard (Thống kê) | ✅ | ✅ |
| Bài học | ✅ | ✅ |
| Định giá | ✅ | ✅ |
| Người dùng | ✅ | ❌ |

---

## Changelog

### v2.2.0 (2025-06-11)
- Admin: pricing page — edit tên, giá tháng, tự tính giá năm theo % giảm giá
- Admin: dashboard — auto-expire pending payments >15 phút, xuất CSV
- Admin: lessons — filter tab động theo category thực tế trong DB
- Admin: users — nút khóa/mở khóa luôn hiển thị, filter dropdown hoạt động
- Admin: phân quyền staff/admin đúng theo route (proxy.ts)
- Mobile: pricing screen đổi màu cam → tím (matching parent theme)

### v2.1.0 (2025-05)
- Admin dashboard redesign (Stitch design system)
- VietQR thanh toán qua PayOS
- Landing page với toggle tháng/năm

### v2.0.0
- Tích hợp MoMo UAT deeplink
- Hệ thống subscription (Free/Premium/Family)
- AI Wisy chat, báo cáo AI

---

## Đóng góp

1. Tạo branch từ `develop`
2. Commit theo [Conventional Commits](https://www.conventionalcommits.org/)
3. Mở Pull Request về `develop`

```
feat(auth):     add Google OAuth callback handling
fix(payment):   auto-expire pending transactions after 15 minutes
chore(mobile):  bump version to 2.2.0+5
```

---

## License

Nội bộ — chỉ dùng cho mục đích học tập và demo tại FPT University.
