# Plan: Hoàn tất i18n còn sót + dịch bài học (AI) + đồng bộ avatar

## Context

Đợt trước đã làm avatar upload + dịch các label chính. Nhưng khi chạy thật, **nhiều chỗ vẫn còn tiếng Việt** không đổi khi bật EN (xem ảnh user gửi: SurveyBanner "Khảo sát trải nghiệm GrowWise", EmotionCheckIn "Tâm trạng hôm nay / Vì sao nên dùng?", placeholder, aria-label, alt, error, mảng dữ liệu...). Ngoài ra có 2 yêu cầu mới:

1. **Bài học**: `title`/`description` do người tạo viết tiếng Việt → cần hiển thị tiếng Anh. **Quyết định (user chọn): AI dịch sẵn lưu DB** (cột `title_en`/`description_en`, sinh khi admin lưu + backfill bài cũ, render bản EN khi lang=en).
2. **Đồng bộ avatar**: top bar (AppShell) đã ưu tiên `avatar_url`, nhưng nhiều chỗ vẫn render thẳng `avatar_emoji` → ảnh upload không hiện đồng nhất. Cần ưu tiên ảnh ở **mọi** nơi.

**Phạm vi (user chọn):** core in-app pages/components + **Login/Register** + **Mobile** + **Landing làm lại** (redesign showcase + sửa pricing, KHÔNG chỉ dịch). KHÔNG đụng `/admin/*`.

**Cập nhật hướng landing (user chốt):** làm lại landing kiểu showcase nổi bật cả 4 nhóm chức năng; quy trình **Stitch prompt trước → user duyệt đẹp → tôi code**; pricing **tôi đề xuất danh sách gọn** rồi đồng bộ (xem Phase E).

Quy tắc xuyên suốt: chỉ đổi chuỗi hiển thị, **không đổi logic**. Giá trị lưu DB / so khớp (category "Tiết kiệm", task category key "Việc nhà", plan key) **giữ nguyên** — chỉ dịch *nhãn hiển thị* qua map.

---

## Phase A — Web in-app: dọn hết VI còn sót

Thêm key thiếu vào `web/lib/i18n.ts` (`dict`), rồi convert. Client component thêm `const { t } = useLang()`; server component dùng `t(lang, key)` (lang từ `getLang()`).

**Component chưa convert (visible UI):**
- `components/app/EmotionCheckIn.tsx` — tiêu đề, bullets "Vì sao nên dùng", nút Đóng/Nâng cấp/Thử lại, error camera/kết nối, "AI đang phân tích…", "Ảnh không được lưu…", "📸 Chụp".
- `components/app/SurveyBanner.tsx` — "Khảo sát…", "Làm khảo sát/Mở lại", "Để sau", "Banner tự ẩn…", "Tải lại", aria "Đóng".
- `components/app/ChildTaskList.tsx` — empty state, status labels (`rejected/todo/submitted/done` — dịch *label*, giữ key), "Ba/mẹ nhắn", cảnh báo auto-approve, error gửi/ảnh.
- `components/app/LearnContent.tsx` — tabs "Bài học/Đọc truyện", "Học bài", empty, "Truyện/Video", "phút". **CATEGORIES** (`["Tất cả","Tiết kiệm",...]`): giữ value để lọc `l.category`, thêm map value→label hiển thị.
- `components/app/StoryReader.tsx` — "Hoàn thành truyện", "Đọc lại/Trước/Làm bài/Xong", aria "Đọc to", empty.
- `components/app/ComingSoon.tsx` — "Tính năng đang được hoàn thiện."

**Component đã convert nhưng còn sót** (placeholder/aria/alt/fallback/mảng dữ liệu):
- `PricingPlans.tsx` — mảng `PLANS` (name/sub/features) tiếng Việt → chuyển sang key i18n (mỗi plan: name, sub, list features).
- `CreateTaskForm.tsx` — `CATEGORIES` key giữ nguyên + map label; placeholder "VD: Dọn phòng ngủ", "Hướng dẫn ngắn…".
- `PaymentQrModal.tsx` — title "Thanh toán Nâng Cao/Gia Đình", "Quét bằng app…", "Nội dung", alt QR.
- `DreamsView.tsx`, `JarsView.tsx` — placeholder input.
- `ApprovalQueue.tsx` — `timeAgo` ("phút/giờ/ngày trước", "vừa xong"), placeholder lý do từ chối, alt.
- `WisyChat.tsx` — `SUGGESTIONS`, greeting đầu, fallback "Hết lượt chat", placeholder "Hỏi Wisy…", aria "Gửi".

**Trang (app) còn VI** (đa số server component → `t(lang, key)`):
`child/page.tsx`, `child/market/page.tsx`, `child/achievements/page.tsx`, `child/learn/[id]/page.tsx`, `parent/lessons/page.tsx`, `parent/lessons/[id]/page.tsx`, `parent/memories/page.tsx`, `parent/tasks/new/page.tsx`, `parent/settings/page.tsx` (PLAN_LABEL map → giữ key, dịch nhãn).

---

## Phase B — Đồng bộ avatar (web)

Tạo helper dùng chung **`web/components/app/Avatar.tsx`**: nhận `{ url?, emoji?, name?, size? }`, render `<img>` tròn nếu có `url`, ngược lại badge emoji (đúng style AppShell hiện tại). Dùng lại ở mọi nơi đang render emoji thẳng:

- `app/(app)/child/page.tsx:51` (lời chào "Hi Minh!") — dùng `child.avatar_url` ưu tiên.
- `app/(app)/child/achievements/page.tsx:18`.
- `components/app/RolePicker.tsx:94` (card con) + `:194` (PIN modal) — `Child` đã có `avatar_url`.
- `components/app/SettingsView.tsx` — thêm `url?` vào `interface ChildInfo`, render ở list (`:146`) + truyền vào EditChildDialog/PIN modal; ở `app/(app)/parent/settings/page.tsx` map `url: c.avatar_url ?? undefined`.
- `app/(app)/parent/memories/page.tsx:19` `childMap` thêm `url`, render nơi dùng (MemoryGallery) ưu tiên ảnh.
- (Tùy chọn) thay block emoji trong `AppShell.tsx` bằng `<Avatar>` để thống nhất.

EditChildDialog/AddChildDialog: avatar dialog đã có; đảm bảo hiển thị ảnh nếu `avatar_url`.

---

## Phase C — Dịch bài học bằng AI, lưu DB (Option A)

### C.1 Migration `web/supabase_lessons_i18n.sql` (user chạy)
```sql
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS description_en TEXT;
```

### C.2 Util dịch — `web/lib/translate.ts` (server-only)
`translateToEn(items: {title:string; description?:string}[]) → {title_en, description_en}[]`, gọi Groq (tái dùng `GROQ_ENDPOINT`/`GROQ_MODEL`/`GROQ_API_KEY` như `app/api/ai-chat/route.ts:11-12,56`), prompt: dịch sang tiếng Anh tự nhiên cho trẻ em, trả JSON.

### C.3 Route server
- `app/api/admin/lessons/translate/route.ts` (POST `{title, description}` → `{title_en, description_en}`) — LessonForm gọi.
- `app/api/admin/lessons/backfill-translations/route.ts` (POST) — tìm lesson `title_en IS NULL`, dịch theo lô, update. Nút "Dịch sang EN (AI)" ở `app/admin/lessons/page.tsx`.

### C.4 LessonForm — `components/LessonForm.tsx` `save()`
Trước khi `insert`/`update`: POST title/description sang route C.3, gộp `title_en`/`description_en` vào `payload` (1 lần ghi). Lỗi dịch → vẫn lưu, EN để trống (fallback VI).

### C.5 Type + render
- `web/lib/types.ts` `Lesson`: thêm `title_en?: string | null; description_en?: string | null`.
- Hiển thị: `lang === 'en' ? (title_en || title) : title` (tương tự description) tại: `LearnContent.tsx` (client, `useLang`), `child/learn/[id]/page.tsx`, `parent/lessons/page.tsx`, `parent/lessons/[id]/page.tsx` (server, `lang`), `StoryReader` header nếu cần.
- Đảm bảo query đọc lessons (`lib/app/lessons.ts`) select 2 cột mới (nếu select tường minh).

> Ghi chú: chỉ dịch title/description (đúng yêu cầu). Nội dung trang truyện (`story_pages.text`) để sau.

---

## Phase D — Login & Register i18n
`app/(app)/login/page.tsx`, `app/(app)/register/page.tsx` (đã có `LangProvider` + một phần `t()`): dịch nốt error mật khẩu/Google, aria "Hiện/Ẩn mật khẩu", placeholder "Nguyễn Văn A", "Đến trang đăng nhập", info xác nhận email... Thêm key vào `i18n.ts`.

---

## Phase E — Landing redesign (Stitch-first) + Pricing revision

User muốn **làm lại landing** kiểu showcase nổi bật **cả 4 nhóm** chức năng chính, và **sửa pricing** (tôi đề xuất danh sách gọn). Quy trình: **viết Stitch prompt trước → user xem/đẹp → gửi lại → tôi code**.

### E.1 Stitch prompt (deliverable — user dán vào Stitch để xem)
Dùng prompt tiếng Anh (Stitch chạy tốt EN). Prompt mẫu (sẽ tinh chỉnh):

> Design a modern, playful-yet-trustworthy **landing page** for **GrowWise** — a financial-education app that teaches kids aged 6–12 to manage money, on web + mobile. Warm friendly fintech style: cream/amber background (#FFF8E7), green accent (#3DBE6E), purple highlight (#7C4DFF), rounded-3xl cards, soft shadows, big bold headings, lots of whitespace, subtle mascot owl "Wisy". Sections in order:
> 1. **Sticky header**: logo + nav (Features, How it works, Pricing) + EN/VI toggle + "Get the app" button.
> 2. **Hero**: bold headline "Raise money-smart kids", subcopy, two CTAs (App Store / Google Play), phone mockup of the child dashboard (coins, 3 jars, tasks).
> 3. **Feature spotlight (4 groups, alternating image/text rows)**: (a) **3 Jars + gamified chores** — assign → do → approve → earn coins, XP, levels, badges, streaks; (b) **Wisy AI + lessons** — kid-friendly AI money coach chat + video & comic-story lessons with quizzes; (c) **Dream Jar + AI mood check-in** — savings goals with progress + selfie emotion check-in; (d) **Parent dashboard + Memory Lane** — weekly AI report, approve tasks, keepsake memories, up to 3 kids.
> 4. **How it works**: 3 steps (Parent assigns → Kid completes & learns → Earn & save).
> 5. **Pricing**: 3 cards (Free, Premium "most popular", Family) with monthly/yearly toggle.
> 6. **Testimonials** (parent quotes) + **Download CTA** + **Footer**.
> Mobile-responsive. Cute but premium, suitable for Vietnamese parents.

→ Sau khi user chốt design, tôi implement bằng Tailwind hiện có (giữ stack, không đổi framework).

### E.2 Implement (sau khi có design)
- Redesign `components/landing/*` (hero, features, how-it-works, pricing, testimonials, footer, header, download-cta) theo layout đã duyệt — spotlight 4 nhóm chức năng.
- **Song ngữ**: landing đang **ngoài** `LangProvider`. Bọc provider cho cây landing (client wrapper ở `app/page.tsx`, KHÔNG đụng metadata ở root server layout) + thêm `LanguageToggle` vào header. Text qua `useLang().t()`, key nhóm `landing.*`.

### E.3 Pricing — đề xuất danh sách gọn (đồng bộ landing + in-app + DB)
Chỉ quảng cáo tính năng **thật sự có** (xác minh trước khi ghi: mini-game / savings analytics — nếu chưa build thì **bỏ**).
- **Cơ Bản (Free)**: 3 hũ tiền · tối đa 3 nhiệm vụ · 3 bài học video · Wisy AI 5 tin/ngày · 1 hồ sơ con.
- **Nâng Cao (Premium)**: Tất cả gói Free + bài học không giới hạn (video + truyện) · nhiệm vụ không giới hạn · Wisy AI không giới hạn · báo cáo AI tuần · check-in cảm xúc · huy hiệu riêng.
- **Gia Đình (Family)**: Tất cả gói Premium + tối đa 3 hồ sơ con · dashboard so sánh tiến độ · Memory Lane.

Đồng bộ ở: `components/landing/pricing.tsx` (PLANS+FAQ), `components/app/PricingPlans.tsx` (PLANS), và (tùy chọn) bảng `plans.features` trong `supabase_admin_schema.sql` / admin pricing. Bỏ feature không có thật ("2 mini-game", "Savings Analytics", "Advanced task templates"...) nếu chưa tồn tại.

> Lưu ý: Stitch prompt là deliverable ở E.1; phần code E.2/E.3 chờ user chốt design rồi mới làm.

---

## Phase F — Mobile: VI còn sót + avatar emoji-only

- Rà `grep` VI trong `mobile/lib/screens/**` (ngoài 8 file đã làm) — bổ sung getter `app_strings.dart` + convert (vd `child_task_market.dart`, các dialog còn sót).
- Avatar: tìm chỗ render `avatarEmoji` thẳng mà bỏ qua `avatarUrl` (vd role/child card, achievement) → ưu tiên `CachedNetworkImage` nếu có `avatarUrl` (đã có sẵn ở `child_dashboard`).

---

## Files chính

**Web mới:** `lib/translate.ts`, `components/app/Avatar.tsx`, `app/api/admin/lessons/translate/route.ts`, `app/api/admin/lessons/backfill-translations/route.ts`, `supabase_lessons_i18n.sql`
**Web sửa:** `lib/i18n.ts`, `lib/types.ts`, `lib/app/lessons.ts`, `components/LessonForm.tsx`, `components/app/{EmotionCheckIn,SurveyBanner,ChildTaskList,LearnContent,StoryReader,ComingSoon,PricingPlans,CreateTaskForm,PaymentQrModal,DreamsView,JarsView,ApprovalQueue,WisyChat,RolePicker,SettingsView,AppShell}.tsx`, `app/(app)/{child/page,child/market/page,child/achievements/page,child/learn/[id]/page,parent/lessons/page,parent/lessons/[id]/page,parent/memories/page,parent/tasks/new/page,parent/settings/page,login/page,register/page}.tsx`, `app/admin/lessons/page.tsx` (nút backfill)
**Web landing redesign:** `components/landing/*` (8 file: hero, features, how-it-works, pricing, testimonials, header, footer, download-cta) + `app/page.tsx` (client wrapper bọc LangProvider) + `components/landing/header.tsx` (LanguageToggle); pricing đồng bộ `components/app/PricingPlans.tsx` (+ tùy chọn `supabase_admin_schema.sql` plans.features). Stitch prompt = deliverable (E.1).
**Mobile sửa:** `lib/l10n/app_strings.dart` + các screen còn VI / avatar emoji-only

---

## Verification

1. **Web typecheck:** `cd web && node node_modules/typescript/bin/tsc --noEmit` → 0 lỗi.
2. **Grep VI:** chuỗi VI hiển thị trong `components/app`, `app/(app)`, `components/landing` về ~0 (bỏ qua comment, prompt AI, value lưu DB cố ý). Bật EN → SurveyBanner, EmotionCheckIn, tabs Learn, status task… đổi hết.
3. **Avatar:** upload ảnh con → hiện đồng nhất ở child dashboard, achievements, RolePicker, parent Settings list, memories (không còn chỗ emoji lệch).
4. **Bài học:** chạy SQL C.1 → admin lưu/ tạo bài → `title_en/description_en` được sinh; nút backfill điền bài cũ; bật EN ở child Learn → hiện tiêu đề/mô tả tiếng Anh, thiếu EN thì fallback VI.
5. **Mobile:** `flutter analyze` 0 lỗi; đổi ngôn ngữ đổi hết; avatar ảnh hiện đồng nhất.
6. **Landing:** E.1 giao Stitch prompt cho user xem trước; sau khi duyệt design → landing mới chạy `npm run dev`, responsive, EN/VI toggle ở header đổi hết text, spotlight đủ 4 nhóm; pricing landing + in-app trùng danh sách feature đã duyệt.
7. **User chạy SQL:** `web/supabase_lessons_i18n.sql`.

## Rủi ro
- Đừng dịch *value* dùng để lọc/lưu (category, plan key, task category) — chỉ dịch *label*. Sai chỗ này vỡ logic lọc bài học/nhiệm vụ.
- Groq dịch có thể fail/timeout → luôn fallback giữ VI, không chặn lưu bài.
- Landing cần provider ngoài `(app)`; nếu root layout là server + có metadata, bọc provider ở client wrapper cho cây landing để không phá SSR/metadata.
- Khối lượng lớn → làm theo phase, typecheck sau mỗi phase web.
