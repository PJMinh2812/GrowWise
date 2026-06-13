"use client";

import { useState } from "react";
import PaymentQrModal from "./PaymentQrModal";

interface Plan {
  key: "free" | "premium" | "family";
  name: string;
  price: string;
  sub: string;
  features: string[];
  highlight?: boolean;
}

const PLANS: Plan[] = [
  {
    key: "free",
    name: "Cơ Bản 🌱",
    price: "0₫",
    sub: "/ tháng",
    features: ["3 bài học video", "Hệ thống 3 hũ", "Tối đa 3 nhiệm vụ", "Chat AI 5 tin/ngày", "1 hồ sơ con"],
  },
  {
    key: "premium",
    name: "Nâng Cao 🚀",
    price: "79.000₫",
    sub: "/ tháng · ~2.600₫/ngày",
    highlight: true,
    features: [
      "Tất cả bài học",
      "Nhiệm vụ không giới hạn",
      "Chat AI không giới hạn",
      "Báo cáo AI thông minh",
      "Huy hiệu riêng",
      "1 hồ sơ con",
    ],
  },
  {
    key: "family",
    name: "Gia Đình 👨‍👩‍👧‍👦",
    price: "149.000₫",
    sub: "/ tháng",
    features: [
      "Tất cả tính năng Nâng Cao",
      "Tối đa 3 hồ sơ con",
      "Dashboard phụ huynh",
      "So sánh tiến độ các con",
    ],
  },
];

export default function PricingPlans() {
  const [pay, setPay] = useState<null | "premium" | "family">(null);

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
      {PLANS.map((p) => (
        <div
          key={p.key}
          className={`app-card p-6 flex flex-col ${
            p.highlight ? "ring-2 ring-primary relative" : ""
          }`}
        >
          {p.highlight && (
            <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-primary text-on-primary text-xs font-bold px-3 py-1 rounded-full">
              PHỔ BIẾN NHẤT
            </span>
          )}
          <h3 className="text-xl font-extrabold text-on-surface">{p.name}</h3>
          <div className="mt-2">
            <span className="text-2xl font-extrabold text-primary">{p.price}</span>
            <span className="text-sm text-on-surface-variant"> {p.sub}</span>
          </div>
          <ul className="mt-4 space-y-2 flex-1">
            {p.features.map((f) => (
              <li key={f} className="flex items-start gap-2 text-sm text-on-surface">
                <span className="text-green-600">✓</span>
                {f}
              </li>
            ))}
          </ul>
          {p.key === "free" ? (
            <button
              disabled
              className="mt-5 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-bold"
            >
              Đang dùng
            </button>
          ) : (
            <button
              onClick={() => setPay(p.key as "premium" | "family")}
              className={`mt-5 py-2.5 rounded-[14px] font-bold ${
                p.highlight
                  ? "bg-primary text-on-primary"
                  : "bg-tertiary text-on-tertiary"
              }`}
            >
              Nâng cấp →
            </button>
          )}
        </div>
      ))}

      {pay && (
        <PaymentQrModal
          planName={pay}
          billingInterval="monthly"
          onClose={() => setPay(null)}
        />
      )}
    </div>
  );
}
