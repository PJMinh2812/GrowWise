# GrowWise — Web App

Landing page + Admin panel cho nền tảng giáo dục tài chính GrowWise, xây dựng bằng Next.js 16 (App Router) và Supabase.

🌐 **Live:** [growwise.io.vn](https://www.growwise.io.vn)

---

## Gồm những gì

| Route | Mô tả |
|---|---|
| `/` | Landing page (giới thiệu sản phẩm, bảng giá, FAQ) |
| `/sign-in` `/sign-up` | Xác thực người dùng qua Supabase Auth |
| `/parent/*` | Giao diện phụ huynh: quản lý trẻ, nhiệm vụ, hũ xu |
| `/child/*` | Giao diện trẻ em: nhiệm vụ, hũ xu, bảng thành tích |
| `/admin/*` | Admin panel: dashboard, bài học, định giá, người dùng |
| `/api/*` | API routes: MoMo IPN, PayOS webhook, Vercel cron |

## Tech Stack

- **Next.js 16** · TypeScript · App Router
- **Tailwind CSS v4** · Stitch design system
- **Supabase** SSR — Auth, PostgreSQL, RLS
- **Google Analytics 4** — event tracking
- **Vercel** — deploy + cron jobs

## Chạy local

```bash
cd web
pnpm install
cp .env.example .env.local   # điền các biến môi trường
pnpm dev                     # http://localhost:3000
```

Xem file `.env.example` để biết danh sách biến cần thiết (Supabase, MoMo, PayOS, Gemini).
