# GrowWise

GrowWise là ứng dụng Flutter hỗ trợ phụ huynh giao nhiệm vụ cho trẻ, theo dõi tiến độ, thưởng xu và xây dựng thói quen quản lý tài chính cá nhân cho trẻ theo hướng game hóa.

## Tính năng chính

- Đăng ký, đăng nhập bằng email/password
- Đăng nhập với Google qua Supabase OAuth
- Luồng onboarding và thiết lập hồ sơ gia đình
- Dashboard riêng cho phụ huynh và trẻ
- Quản lý nhiệm vụ: tạo, nộp, duyệt, từ chối
- Hệ thống xu và hũ (tiêu dùng, tiết kiệm, sẻ chia)
- Dream Jar: đặt mục tiêu và mua khi đủ xu
- Gửi lời khen (bonding message) từ phụ huynh cho trẻ

## Công nghệ sử dụng

- Flutter, Dart
- State management: Provider
- Backend/Auth/DB: Supabase
- Local secure storage: flutter_secure_storage

## Cấu trúc thư mục

```text
lib/
    data/           # data helpers và sample data
    models/         # model classes
    providers/      # app state
    screens/        # UI screens (parent/child/auth)
    services/       # Supabase service layer
    theme/          # theme configs
    utils/          # validators, helper utils
```

## Yêu cầu môi trường

- Flutter stable (khuyến nghị 3.41.x trở lên)
- Dart SDK theo phiên bản Flutter
- Android SDK + cmdline-tools
- JDK 17 (khuyến nghị cho Android build)

## Chạy project local

1. Clone repo

```bash
git clone https://github.com/PJMinh2812/GrowWise.git
cd GrowWise
```

2. Tạo file môi trường

```bash
cp .env.example .env
```

Điền thông tin Supabase vào `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Cài package

```bash
flutter pub get
```

4. Chạy app

```bash
flutter run
```

## Cấu hình Google Auth (Supabase)

1. Trong Google Cloud Console:

- Tạo OAuth consent screen
- Tạo OAuth client loại Web
- Thêm redirect URI:

```text
https://<your-project-ref>.supabase.co/auth/v1/callback
```

2. Trong Supabase Dashboard:

- Authentication -> Providers -> Google: Enable
- Dán Web Client ID và Client Secret

3. Trong Supabase URL Configuration, thêm redirect URL mobile:

```text
io.supabase.growwise://login-callback
```

4. Android deep link đã được khai báo trong `android/app/src/main/AndroidManifest.xml`.

## Trạng thái hiện tại

- Đã có luồng auth, nhiệm vụ, hũ xu, dream jar, parent/child dashboards
- Một số tính năng nâng cao đang ở mức demo/MVP

## Đóng góp

1. Tạo branch mới từ `main`
2. Commit theo Conventional Commits
3. Mở Pull Request

Ví dụ commit message:

```text
feat(auth): add Google OAuth callback handling
fix(tasks): use dynamic coin reward in approval flow
chore(repo): update gitignore for env and generated files
```

## License

Nội bộ cho mục đích học tập và demo.
