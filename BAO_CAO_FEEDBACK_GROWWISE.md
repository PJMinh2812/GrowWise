# GrowWise — Báo cáo thay đổi sản phẩm sau Feedback & KPI

> Ứng dụng giáo dục tài chính cho trẻ em (web + mobile). Tài liệu tổng hợp các thay đổi sau khi thu thập feedback và đánh giá KPI.
> Các ô `[điền…]` là chỗ dán số liệu/ảnh thật từ form & sheet feedback.

**Nguồn dữ liệu feedback**
- Form khảo sát trẻ em: https://docs.google.com/forms/d/1yZmjM5DKOndNtTmk76i6CtzqOMNBqVOPhC3g_MSigZI/edit
- Form khảo sát người lớn (phụ huynh): https://docs.google.com/forms/d/1iqVUeJKIHr1lNHGBli_bbUDh8qCWETDTbbJCceBkdWU/edit
- Bảng tổng hợp feedback: https://docs.google.com/spreadsheets/d/1_rsGMoZFj0xa_rZBXxGEMCdsb3gx0mySVGaGiT455VE/edit
- Thư mục ảnh feedback: https://drive.google.com/drive/folders/1Fy_cSQ16Jb1gKbFJr_P6R_mSGNS8F5zB

---

## 3. Những thay đổi của sản phẩm sau khi nhận feedback

### 3.1. Feedback chính dẫn đến thay đổi

**Nguồn:** Khảo sát phụ huynh GrowWise — **40 phản hồi** (16/6–23/6/2026). *(Khảo sát trẻ em: `[điền số]` phản hồi.)*

Tổng quan: hài lòng chung **4.25/5** (85% chọn 4–5★); khả năng giới thiệu **8.0/10** (NPS ≈ **+30**); **52,5%** có gặp lỗi/trục trặc; phần lớn dùng gói **Cơ Bản (miễn phí)** (6/40 đã trả phí).

Các nhóm feedback chính (số lượt = số phản hồi đề cập, trên tổng 40):

| # | Nhóm feedback | Nội dung tiêu biểu | Số lượt |
|---|---|---|---|
| 1 | **Thanh toán/nâng cấp khó** | "Thanh toán khó" là lý do chưa nâng cấp **nhiều nhất**; lỗi ở bước thanh toán nâng cấp | ~12/40 |
| 2 | **Giá & gói chưa rõ** | "Giá cao", "Giao diện gói nâng cấp nên rõ ràng hơn"; mức giá kỳ vọng tập trung **50–100k** (50%) | ~10/40 |
| 3 | **Lỗi đăng nhập / hiển thị sai / app chậm** | "Đăng nhập dễ dàng hơn", "Hiển thị sai", "App chạy chậm" (tốc độ TB 4.0/5) | ~21/40 gặp lỗi |
| 4 | **Muốn nhiều bài học & nhiệm vụ hơn** | "Thêm bài học", "Nhiều loại nhiệm vụ", "Thêm thư viện nhiệm vụ" | ~18/40 |
| 5 | **Muốn báo cáo chi tiết/trực quan hơn** | "Báo cáo nên chi tiết và trực quan hơn" cho phụ huynh | ~10/40 |
| 6 | **Tự động hoá & hỗ trợ nhiều con** | "Nhắc nhở thông minh", "Hỗ trợ nhiều con tốt hơn", "phụ huynh bận vẫn dùng được" | ~12/40 |
| 7 | **Tuỳ biến (3 hũ, phần thưởng, dark mode)** | "Tùy chỉnh tỉ lệ chia 3 hũ", "Tùy biến phần thưởng", "chế độ tối (dark mode)" | ~9/40 |
| 8 | **Chỉ tiếng Việt / quốc tế hoá** | Cần bản tiếng Anh để mở rộng người dùng | `[điền]` |

> Số lượt là ước lượng từ các cột lựa chọn/nhận xét trong khảo sát; có thể tinh chỉnh khi đối chiếu lại sheet.

### 3.2. Các thay đổi đã thực hiện

Trình bày theo format **Feedback → Vấn đề → Giải pháp → Before/After**.

---

**(1) Đa ngôn ngữ (VI/EN)**
- **Feedback:** App chỉ có tiếng Việt; khó dùng/đánh giá với người dùng quốc tế và giám khảo.
- **Vấn đề:** Toàn bộ giao diện web (app + landing) hard-code tiếng Việt, không đổi ngôn ngữ được.
- **Giải pháp:** Xây hệ thống i18n (VI/EN) cho toàn bộ web app và landing page; thêm nút chuyển VI/EN; nội dung động (tên gói, tính năng, nhiệm vụ) đều dịch.
- **Before/After:** `[ảnh before: màn tiếng Việt]` · `[ảnh after: cùng màn ở tiếng Anh]`

**(2) Thanh toán thật bằng SePay**
- **Feedback:** Không thanh toán/nâng cấp được — nút thanh toán chỉ là demo.
- **Vấn đề:** Hai luồng cũ (MoMo/PayOS) ở dạng demo, không cấu hình, không kích hoạt gói.
- **Giải pháp:** Tích hợp **SePay** (chuyển khoản QR ngân hàng) — tạo đơn → quét QR → webhook nhận tiền → tự kích hoạt gói cho đúng tài khoản.
- **Before/After:** `[ảnh before: nút thanh toán demo]` · `[ảnh after: màn QR SePay + gói kích hoạt]`

**(3) Giá lấy từ DB, giá năm tự tính −20%, đồng bộ web/mobile**
- **Feedback:** Giá khó hiểu, không nhất quán; mobile hiện một giá nhưng thu tiền lại khác.
- **Vấn đề:** Giá hard-code rời rạc; admin sửa giá không phản ánh ra app; mobile và web lệch nhau.
- **Giải pháp:** Giá đọc từ bảng `plans` (admin chỉnh là cập nhật ngay); **giá năm tự động giảm 20%** so với 12 tháng; thêm API giá chung để **web và mobile hiển thị = số tiền thực thu**.
- **Before/After:** `[ảnh before: giá lệch trên mobile]` · `[ảnh after: giá khớp + nhãn −20%]`

**(4) Vòng đời gói rõ ràng: tự hết hạn + nhắc gia hạn**
- **Feedback:** Không rõ khi nào gói hết hạn, gia hạn thế nào.
- **Vấn đề:** Hệ thống không kiểm tra hạn — một khi active là dùng mãi.
- **Giải pháp:** Tự hạ về Free khi hết kỳ; **banner nhắc gia hạn** (sắp hết / đã hết hạn); gia hạn sớm thì **cộng dồn** ngày còn lại; cron dọn nền cho dashboard admin chính xác.
- **Before/After:** `[ảnh before: không có trạng thái hạn]` · `[ảnh after: banner gia hạn]`

**(5) Lộ trình học kiểu "đường đi" (Duolingo-style) + theo dõi hoàn thành**
- **Feedback:** Bài học đơn điệu, trẻ nhanh chán.
- **Vấn đề:** Màn học chỉ là lưới thẻ, không có cảm giác tiến triển/khích lệ.
- **Giải pháp:** Dựng **lộ trình học** (đường uốn lượn + các chặng), **mở khoá tuần tự** theo thứ tự bài, **theo dõi hoàn thành** từng bài, **nền bầu trời** + **ăn mừng (confetti) khi hoàn thành chặng**.
- **Before/After:** `[ảnh before: lưới bài học]` · `[ảnh after: lộ trình + confetti]`

**(6) Phản hồi tức thì & hiệu ứng vui (UX)**
- **Feedback:** Làm xong nhiệm vụ không có gì vui; thao tác thiếu phản hồi; giao diện phẳng.
- **Vấn đề:** Không có thông báo thành công, không hiệu ứng, chuyển trang khô.
- **Giải pháp:** Hệ thống **toast** (thành công/lỗi) cho mọi hành động; **confetti + cộng xu + âm thanh + rung** khi hoàn thành nhiệm vụ; **popup lên cấp**; **chuyển trang mượt** + nút bấm có phản hồi (ripple).
- **Before/After:** `[ảnh before: không phản hồi]` · `[ảnh after: toast + confetti]`

**(7) Trang trí giao diện, bớt trống trải**
- **Feedback:** Nhiều màn nhìn trống/đơn điệu.
- **Vấn đề:** Dashboard và các trang con nhiều khoảng trắng, thiếu điểm nhấn.
- **Giải pháp:** Thêm **nền minh hoạ** (bầu trời + mây + đồi + đồng xu + linh vật cú Wisy) cho dashboard và đáy các trang con; thêm ô **"Số dư/Cấp độ/Xu"** trực quan.
- **Before/After:** `[ảnh before: nền trắng]` · `[ảnh after: nền minh hoạ]`

**(8) Thành tích dễ truy cập + chuỗi (streak)**
- **Feedback:** Không tìm thấy chỗ vào "Thành tích"; thiếu động lực duy trì.
- **Vấn đề:** Trang Thành tích có sẵn nhưng không có lối vào; không hiển thị streak.
- **Giải pháp:** Thêm **ô Achievements** ở trang chủ trẻ (mở trang Thành tích) kèm **streak (số ngày liên tiếp)**; dịch trang Thành tích sang EN.
- **Before/After:** `[ảnh before: không có lối vào]` · `[ảnh after: ô Achievements + streak]`

### 3.3. Định hướng tiếp theo (xuất phát từ feedback "phụ huynh không có thời gian")

Trọng tâm: **tự động hoá tối đa, phụ huynh chỉ nhận thông báo, càng đơn giản càng tốt.**

- **Lộ trình trưởng thành tự chạy theo độ tuổi:** hệ thống tự sinh nhiệm vụ/mục tiêu phù hợp lứa tuổi; phụ huynh có thể **căn chỉnh & sửa** cho phù hợp, sau đó lộ trình **tự chạy** và **chỉ thông báo** cho phụ huynh.
- **3 hũ tiền = "ngân hàng của con":** xu hoàn thành nhiệm vụ được **tự phân bổ** vào 3 hũ (dạy tỉ lệ tiêu/tiết kiệm/sẻ chia); khi xong trẻ chỉ cần **"collect" và chọn hũ**.
- **Module Thu & Chi (quan trọng):** lập **kế hoạch tiết kiệm** để mua một món; **chi tiêu phát sinh** (ngoài kế hoạch) được trừ trực tiếp; phụ huynh có thể **trừ khoản phát sinh** cho con.
- **Email thông báo cho phụ huynh:** tổng hợp tiến độ/nhiệm vụ/chi tiêu thay vì bắt phụ huynh thao tác trong app.
- **Tối giản thao tác phụ huynh:** mặc định thông minh, ít cấu hình; tập trung vào giá trị cốt lõi.

---

## 4. KPI đặt ra và kết quả đạt được

### 4.1. KPI ban đầu

| Chỉ số | Mục tiêu |
|---|---|
| Reach (số người tiếp cận) | `[điền]` |
| Số người dùng thử | `[điền]` |
| Số feedback hợp lệ thu được | ≥ 40 |
| % người dùng thấy app hữu ích (hài lòng 4–5★) | ≥ 80% |
| Khả năng giới thiệu (NPS) | ≥ +20 |
| Số tính năng được cải thiện sau feedback | ≥ 8 |
| Tỷ lệ phụ huynh không gặp lỗi | ≥ 60% |

### 4.2. Kết quả thực tế

*(Số liệu từ khảo sát phụ huynh — 40 phản hồi; mục có `[điền]` cần bổ sung từ khảo sát trẻ em / kênh reach.)*

| Chỉ số | Mục tiêu | Thực tế đạt được | Mức độ hoàn thành | Ghi chú |
|---|---|---|---|---|
| Reach | `[điền]` | `[điền]` | `[điền]` % | Từ form + chia sẻ |
| Người dùng thử | `[điền]` | `[điền]` | `[điền]` % | PH + trẻ em |
| Feedback hợp lệ | 40 | **40** (PH) | **100%** | Chưa gồm form trẻ em |
| % thấy app hữu ích (4–5★) | 80% | **85%** | **106%** | TB hài lòng 4.25/5 |
| Khả năng giới thiệu (NPS) | +20 | **+30** | **150%** | Điểm giới thiệu TB 8.0/10 |
| Tính năng cải thiện sau feedback | ≥ 8 | **8** | **100%** | Xem mục 3.2 |
| Phụ huynh không gặp lỗi | 60% | **47,5%** | **79%** | 52,5% còn gặp lỗi → cần cải thiện ổn định |
| Tốc độ/độ mượt (1–5) | ≥ 4.0 | **4.0** | **100%** | — |
| Tỷ lệ đã nâng cấp gói | — | **15%** (6/40) | — | Rào cản: "thanh toán khó" (đã sửa bằng SePay) |

### 4.3. Đánh giá tính khả thi

**GrowWise có đang giải đúng pain point không?**
- Pain point lớn nhất từ phụ huynh là **không có thời gian**. Hướng đi **tự động hoá lộ trình theo độ tuổi + chỉ thông báo** đánh trúng nhu cầu này; mô hình **3 hũ tiền** và **Thu/Chi** dạy đúng kỹ năng tài chính cốt lõi (phân bổ, tiết kiệm có mục tiêu, kiểm soát chi). → **Đúng pain point.**

**Có khả năng thu hút người dùng thật không?**
- Yếu tố hấp dẫn trẻ: lộ trình học có tiến triển, hiệu ứng ăn mừng, huy hiệu/streak, giao diện minh hoạ vui mắt.
- Yếu tố giữ chân phụ huynh: thanh toán/nâng cấp đã chạy thật (SePay), giá minh bạch, ít phải thao tác. → **Có tiềm năng**, cần số liệu thực tế ở 4.2 để khẳng định.

**Người dùng có sẵn sàng tiếp tục dùng / giới thiệu không?**
- Khả năng giới thiệu trung bình **8.0/10**, **NPS ≈ +30** (19 promoters / 7 detractors / 40) — mức **tích cực**, cho thấy phụ huynh sẵn sàng giới thiệu. Hài lòng chung 4.25/5 (85% chọn 4–5★) củng cố khả năng tiếp tục sử dụng.
- Rào cản chuyển đổi sang trả phí chủ yếu là **"thanh toán khó"** (lý do từ chối nâng cấp nhiều nhất) — đã được xử lý bằng tích hợp SePay; kỳ vọng tỷ lệ nâng cấp cải thiện ở vòng sau.

**Mức độ khả thi hiện tại & cần cải thiện tiếp:**
- Đã khả thi ở mức **MVP chạy thật** (đăng nhập, nhiệm vụ, 3 hũ, học, thanh toán, đa ngôn ngữ, UX cơ bản).
- Cần làm tiếp để đạt giá trị cốt lõi "phụ huynh không cần thao tác":
  1. **Lộ trình tự chạy theo độ tuổi** (giảm phụ thuộc phụ huynh tạo nhiệm vụ).
  2. **3 hũ tự phân bổ + collect**.
  3. **Module Thu/Chi** (kế hoạch tiết kiệm + chi phát sinh).
  4. **Email thông báo** định kỳ cho phụ huynh.
  5. Hoàn thiện onboarding & ổn định cài đặt/đăng nhập.

---

## Phụ lục

### Trích dẫn feedback tiêu biểu (khảo sát phụ huynh)

**Tích cực**
- "Hệ thống 3 hũ giúp con hiểu khái niệm tiết kiệm rất tự nhiên."
- "Con bớt đòi mua đồ tùy hứng sau khi dùng app."
- "Dễ thiết lập, phụ huynh bận vẫn dùng được."
- "App giúp cả nhà có chủ đề trò chuyện về tiền bạc."
- "Huy hiệu và cấp độ khiến con hào hứng cố gắng mỗi ngày."

**Đề xuất cải thiện**
- "Cho phép tùy chỉnh tỉ lệ chia 3 hũ."
- "Báo cáo nên chi tiết và trực quan hơn."
- "Giao diện gói nâng cấp nên rõ ràng hơn." / "Đăng nhập dễ dàng hơn."
- "Thêm thư viện nhiệm vụ để dễ giao nhiệm vụ hơn." / "Nhiều loại nhiệm vụ."
- "Mong có chế độ tối (dark mode)." / "Hỗ trợ nhiều con tốt hơn."

### Liên kết nguồn
- Form trẻ em: https://docs.google.com/forms/d/1yZmjM5DKOndNtTmk76i6CtzqOMNBqVOPhC3g_MSigZI/edit
- Form người lớn: https://docs.google.com/forms/d/1iqVUeJKIHr1lNHGBli_bbUDh8qCWETDTbbJCceBkdWU/edit
- Sheet feedback: https://docs.google.com/spreadsheets/d/1_rsGMoZFj0xa_rZBXxGEMCdsb3gx0mySVGaGiT455VE/edit
- Ảnh feedback: https://drive.google.com/drive/folders/1Fy_cSQ16Jb1gKbFJr_P6R_mSGNS8F5zB
- **Cần làm:** chèn ảnh before/after (mục 3.2) từ Drive vào các ô `[ảnh …]`; dán số liệu vào các ô `[điền]`.
