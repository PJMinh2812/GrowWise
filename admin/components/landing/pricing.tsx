"use client";

import { useState } from "react";
import { Check, Lock, Zap } from "lucide-react";

const PLANS = [
  {
    id: "free",
    name: "Cơ Bản",
    emoji: "🌱",
    monthlyPrice: 0,
    yearlyPrice: 0,
    yearlyMonthlyEquiv: 0,
    yearlySaving: 0,
    subtitle: "Miễn phí mãi mãi",
    color: "border-border bg-background",
    buttonStyle:
      "border border-muted-foreground/30 text-muted-foreground cursor-default",
    buttonText: "Đang dùng miễn phí",
    buttonDisabled: true,
    badge: null,
    features: [
      "3 bài học video",
      "Hệ thống 3 lọ tiền",
      "Tối đa 3 nhiệm vụ active",
      "Chat AI Wisy (5 tin/ngày)",
      "2 mini-game",
      "1 hồ sơ trẻ",
    ],
    locked: [],
  },
  {
    id: "premium",
    name: "Nâng Cao",
    emoji: "🚀",
    monthlyPrice: 79000,
    yearlyPrice: 749000,
    yearlyMonthlyEquiv: 62417,
    yearlySaving: 200000,
    subtitle: "~2.600₫/ngày — ít hơn 1 tô phở!",
    color: "border-[#7C4DFF] bg-[#F3E5F5]",
    buttonStyle: "bg-[#7C4DFF] hover:bg-[#6C3FEE] text-white",
    buttonText: "Dùng thử 7 ngày miễn phí",
    buttonDisabled: false,
    badge: "Phổ biến nhất ⭐",
    features: [
      "Tất cả bài học (không giới hạn)",
      "Nhiệm vụ không giới hạn",
      "Chat AI Wisy không giới hạn",
      "Tất cả mini-game",
      "Báo cáo AI thông minh",
      "Savings Analytics",
      "Custom badge riêng",
      "Advanced task templates",
    ],
    locked: [],
  },
  {
    id: "family",
    name: "Gia Đình",
    emoji: "👨‍👩‍👧‍👦",
    monthlyPrice: 149000,
    yearlyPrice: 1419000,
    yearlyMonthlyEquiv: 118250,
    yearlySaving: 369000,
    subtitle: "Tối đa 3 hồ sơ trẻ",
    color: "border-primary bg-primary/5",
    buttonStyle: "bg-primary hover:bg-primary/90 text-white",
    buttonText: "Chọn gói Gia Đình",
    buttonDisabled: false,
    badge: null,
    features: [
      "Tất cả tính năng Nâng Cao",
      "Tối đa 3 hồ sơ trẻ",
      "Dashboard phụ huynh chia sẻ",
      "So sánh tiến độ các con",
    ],
    locked: [],
  },
];

function formatVND(amount: number) {
  return amount.toLocaleString("vi-VN") + "₫";
}

const FAQ = [
  {
    q: "Tôi có thể hủy không?",
    a: "Có, bạn có thể hủy bất kỳ lúc nào mà không mất thêm phí. Gói dùng thử 7 ngày hoàn toàn miễn phí.",
  },
  {
    q: "Dùng thử có cần nhập thẻ không?",
    a: "Không cần! 7 ngày dùng thử hoàn toàn miễn phí, không cần thông tin thanh toán.",
  },
  {
    q: "Gói Gia Đình dùng được mấy thiết bị?",
    a: "Mỗi hồ sơ trẻ được dùng trên 1 thiết bị. Gói Gia Đình cho phép tối đa 3 hồ sơ trẻ.",
  },
];

export function Pricing() {
  const [isYearly, setIsYearly] = useState(false);
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  return (
    <section id="pricing" className="py-16 sm:py-24 bg-[#FFF8E7]">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-10">
          <span className="inline-block bg-primary/10 text-primary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            Bảng giá
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-foreground text-balance">
            Chọn gói phù hợp 🌟
          </h2>
          <p className="mt-3 text-lg text-muted-foreground">
            Đầu tư nhỏ, tương lai lớn
          </p>
        </div>

        {/* Billing toggle */}
        <div className="flex justify-center mb-10">
          <div className="inline-flex items-center bg-white border border-border rounded-full p-1 shadow-sm">
            <button
              onClick={() => setIsYearly(false)}
              className={`px-5 py-2 rounded-full text-sm font-semibold transition-all ${
                !isYearly
                  ? "bg-primary text-white shadow"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              Hàng tháng
            </button>
            <button
              onClick={() => setIsYearly(true)}
              className={`px-5 py-2 rounded-full text-sm font-semibold transition-all flex items-center gap-1.5 ${
                isYearly
                  ? "bg-primary text-white shadow"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              Hàng năm
              <span className="bg-green-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">
                -20%
              </span>
            </button>
          </div>
        </div>

        {/* Plan cards */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
          {PLANS.map((plan) => {
            const displayPrice = isYearly
              ? plan.yearlyPrice
              : plan.monthlyPrice;
            const showSaving = isYearly && plan.yearlySaving > 0;

            return (
              <div
                key={plan.id}
                className={`relative rounded-3xl border-2 p-6 flex flex-col transition-shadow hover:shadow-xl ${plan.color} ${
                  plan.id === "premium" ? "md:-mt-3 md:mb-3 shadow-lg" : ""
                }`}
              >
                {/* Badge */}
                {plan.badge && (
                  <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 bg-[#7C4DFF] text-white text-xs font-bold px-4 py-1 rounded-full whitespace-nowrap shadow">
                    {plan.badge}
                  </div>
                )}

                {/* Saving badge (yearly) */}
                {showSaving && (
                  <div className="absolute top-4 right-4 bg-green-500 text-white text-[11px] font-bold px-2.5 py-1 rounded-full">
                    Tiết kiệm {formatVND(plan.yearlySaving)}
                  </div>
                )}

                {/* Plan header */}
                <div className="mb-5">
                  <div className="text-3xl mb-2">{plan.emoji}</div>
                  <h3 className="text-xl font-bold text-foreground">
                    {plan.name}
                  </h3>

                  <div className="mt-3">
                    {plan.monthlyPrice === 0 ? (
                      <div className="text-3xl font-extrabold text-foreground">
                        Miễn phí
                      </div>
                    ) : (
                      <>
                        <div className="text-3xl font-extrabold text-foreground">
                          {formatVND(displayPrice)}
                          <span className="text-base font-normal text-muted-foreground">
                            {isYearly ? "/năm" : "/tháng"}
                          </span>
                        </div>
                        {isYearly && plan.yearlyMonthlyEquiv > 0 && (
                          <p className="text-sm text-green-600 font-medium mt-0.5">
                            ≈ {formatVND(plan.yearlyMonthlyEquiv)}/tháng
                          </p>
                        )}
                        {!isYearly && (
                          <p className="text-sm text-muted-foreground mt-0.5">
                            {plan.subtitle}
                          </p>
                        )}
                      </>
                    )}
                  </div>
                </div>

                {/* Features */}
                <ul className="space-y-2.5 flex-1 mb-6">
                  {plan.features.map((f, i) => (
                    <li
                      key={i}
                      className="flex items-start gap-2 text-sm text-foreground"
                    >
                      <Check className="w-4 h-4 text-green-500 mt-0.5 shrink-0" />
                      {f}
                    </li>
                  ))}
                  {plan.id === "free" && (
                    <>
                      <li className="flex items-start gap-2 text-sm text-muted-foreground/60">
                        <Lock className="w-4 h-4 mt-0.5 shrink-0" />
                        Báo cáo AI
                      </li>
                      <li className="flex items-start gap-2 text-sm text-muted-foreground/60">
                        <Lock className="w-4 h-4 mt-0.5 shrink-0" />
                        Savings Analytics
                      </li>
                    </>
                  )}
                </ul>

                {/* CTA */}
                <button
                  disabled={plan.buttonDisabled}
                  className={`w-full py-3 px-4 rounded-2xl font-bold text-sm transition-all ${plan.buttonStyle} ${
                    !plan.buttonDisabled ? "active:scale-95" : ""
                  }`}
                >
                  {plan.id === "premium" && isYearly
                    ? `Dùng thử 7 ngày • ${formatVND(plan.yearlyPrice)}/năm`
                    : plan.buttonText}
                </button>
              </div>
            );
          })}
        </div>

        {/* Trust badges */}
        <div className="flex flex-wrap justify-center gap-6 mb-12 text-sm text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <span className="text-base">🔒</span> Thanh toán an toàn
          </span>
          <span className="flex items-center gap-1.5">
            <span className="text-base">✅</span> Hủy bất cứ lúc nào
          </span>
          <span className="flex items-center gap-1.5">
            <span className="text-base">🎁</span> 7 ngày dùng thử miễn phí
          </span>
          <span className="flex items-center gap-1.5">
            <Zap className="w-4 h-4 text-yellow-500" /> MoMo · VNPay · ZaloPay ·
            Thẻ
          </span>
        </div>

        {/* FAQ */}
        <div className="max-w-2xl mx-auto">
          <h3 className="text-xl font-bold text-foreground text-center mb-6">
            Câu hỏi thường gặp
          </h3>
          <div className="space-y-3">
            {FAQ.map((item, i) => (
              <div
                key={i}
                className="bg-white rounded-2xl border border-border overflow-hidden"
              >
                <button
                  onClick={() => setOpenFaq(openFaq === i ? null : i)}
                  className="w-full text-left px-5 py-4 font-semibold text-foreground flex justify-between items-center hover:bg-muted/30 transition-colors"
                >
                  {item.q}
                  <span className="text-muted-foreground text-lg leading-none">
                    {openFaq === i ? "−" : "+"}
                  </span>
                </button>
                {openFaq === i && (
                  <div className="px-5 pb-4 text-sm text-muted-foreground">
                    {item.a}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
