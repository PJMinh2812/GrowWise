# Kỹ thuật SEO áp dụng trong GrowWise

## Tổng quan

SEO (Search Engine Optimization) là tập hợp kỹ thuật giúp trang web xuất hiện cao hơn trên Google và
các công cụ tìm kiếm. Dự án GrowWise áp dụng 3 nhóm kỹ thuật chính.

---

## 1. On-page Metadata

**File:** `app/layout.tsx`

### Metadata cơ bản

```ts
metadataBase: new URL("https://www.growwise.io.vn"),
title: "GrowWise - Dạy con yêu tiền, đúng cách, đúng lúc",
description: "...",
keywords: ["giáo dục tài chính", "trẻ em", ...],
alternates: { canonical: "/" },
robots: { index: true, follow: true },
```

| Field | Tác dụng |
|---|---|
| `metadataBase` | Làm base URL cho tất cả link tương đối (og:image, canonical). **Thiếu cái này thì OG image bị broken.** |
| `title` | Dòng tiêu đề hiển thị trên tab trình duyệt và kết quả tìm kiếm Google |
| `description` | Đoạn mô tả ngắn hiển thị dưới tiêu đề trên Google (~160 ký tự) |
| `keywords` | Từ khóa gợi ý cho Googlebot (ít quan trọng hơn trước nhưng vẫn tốt có) |
| `canonical` | Tránh bị phạt duplicate content khi URL có nhiều dạng khác nhau |
| `robots` | Cho phép Googlebot crawl và index trang này |

### Open Graph (Facebook, Zalo, Messenger...)

```ts
openGraph: {
  title: "...",
  description: "...",
  type: "website",
  locale: "vi_VN",
  url: "https://www.growwise.io.vn",
  siteName: "GrowWise",
  images: [{ url: "/og-image.png", width: 1200, height: 630 }],
},
```

Khi ai đó share link GrowWise lên Facebook/Zalo, Facebook đọc các thẻ `og:*` này để hiển thị
preview đẹp với hình ảnh, tiêu đề và mô tả.

> ⚠️ **Quan trọng:** Cần thêm file `public/og-image.png` kích thước **1200×630px** để hiện hình preview.
> Dùng Figma hoặc Canva để thiết kế banner với logo + tagline GrowWise.

### Twitter Card

```ts
twitter: {
  card: "summary_large_image",
  title: "...",
  description: "...",
  images: ["/og-image.png"],
},
```

Tương tự Open Graph nhưng dành riêng cho Twitter/X.

---

## 2. Crawl Hints

### robots.txt — `app/robots.ts`

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /payment/
Sitemap: https://www.growwise.io.vn/sitemap.xml
```

File này chỉ cho Googlebot biết:
- Trang nào **được phép** crawl (landing page, trang public)
- Trang nào **không nên** crawl (admin, API, thanh toán)
- Nơi tìm sitemap

Next.js 16 App Router tự generate file `robots.txt` từ `app/robots.ts` — không cần tạo file tĩnh.

Kiểm tra: truy cập `https://www.growwise.io.vn/robots.txt`

### sitemap.xml — `app/sitemap.ts`

```xml
<urlset>
  <url><loc>https://www.growwise.io.vn</loc><priority>1.0</priority></url>
  <url><loc>https://www.growwise.io.vn/pricing</loc><priority>0.8</priority></url>
  <url><loc>https://www.growwise.io.vn/login</loc><priority>0.3</priority></url>
  <url><loc>https://www.growwise.io.vn/register</loc><priority>0.3</priority></url>
</urlset>
```

Sitemap là "bản đồ" toàn bộ trang web, giúp Google tìm và crawl đúng các trang quan trọng.
`priority` (0–1) gợi ý thứ tự ưu tiên crawl.

Kiểm tra: truy cập `https://www.growwise.io.vn/sitemap.xml`

---

## 3. Structured Data (JSON-LD)

**File:** `components/landing/json-ld.tsx`

JSON-LD (JavaScript Object Notation for Linked Data) là cách nhúng dữ liệu có cấu trúc vào HTML
để Google hiểu nội dung trang ở mức sâu hơn, từ đó hiển thị **rich snippets** trên kết quả tìm kiếm.

### a) WebSite Schema

```json
{
  "@type": "WebSite",
  "name": "GrowWise",
  "url": "https://www.growwise.io.vn"
}
```

Khai báo thông tin cơ bản về website. Google có thể thêm sitelinks (danh sách link phụ) dưới
kết quả tìm kiếm chính.

### b) SoftwareApplication Schema

```json
{
  "@type": "SoftwareApplication",
  "applicationCategory": "EducationApplication",
  "aggregateRating": { "ratingValue": "4.9", "ratingCount": "10000" },
  "offers": [
    { "price": "0", "name": "Free" },
    { "price": "79000", "name": "Premium" },
    { "price": "149000", "name": "Family" }
  ]
}
```

**Kết quả:** Google có thể hiển thị sao đánh giá ⭐⭐⭐⭐⭐ và thông tin giá ngay trên trang
kết quả tìm kiếm mà không cần người dùng phải vào trang web.

### c) FAQPage Schema

```json
{
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Tôi có thể hủy không?",
      "acceptedAnswer": { "text": "Có, bạn có thể hủy bất kỳ lúc nào..." }
    }
  ]
}
```

**Kết quả:** Google có thể mở rộng kết quả tìm kiếm để hiển thị trực tiếp các câu hỏi và câu trả
lời, chiếm nhiều diện tích hơn trên trang kết quả → tăng tỷ lệ click.

---

## Cách hoạt động tổng thể

```
Người dùng Google "app dạy tài chính cho trẻ em"
         ↓
Googlebot đã crawl GrowWise nhờ sitemap.xml
         ↓
Đọc metadata → hiểu tiêu đề, mô tả, từ khóa
         ↓
Đọc JSON-LD → hiển thị rich snippet: sao 4.9⭐, giá từ 0đ, FAQ
         ↓
Người dùng click → thấy preview đẹp nhờ og:image khi share
```

---

## Checklist kiểm tra

| Mục | Cách kiểm tra |
|---|---|
| robots.txt | Truy cập `/robots.txt` trên trình duyệt |
| sitemap.xml | Truy cập `/sitemap.xml` trên trình duyệt |
| OG image | Dán URL vào [Facebook Debugger](https://developers.facebook.com/tools/debug/) |
| JSON-LD | Dán URL vào [Google Rich Results Test](https://search.google.com/test/rich-results) |
| Metadata | Mở DevTools → tab Elements → tìm trong `<head>` |

---

## Lưu ý quan trọng

- **`og:image` cần tạo thủ công:** Tạo file `public/og-image.png` (1200×630px) bằng Figma/Canva.
  Nếu chưa có file này thì preview khi share sẽ hiển thị trống.
- **JSON-LD không cần `'use client'`:** Component `LandingJsonLd` là Server Component — render phía
  server để Googlebot đọc được ngay, không cần chờ JavaScript chạy phía client.
- **Robots.txt chặn `/admin/`:** Trang quản trị sẽ không bị Google index.
