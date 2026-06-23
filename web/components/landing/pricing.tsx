"use client";

import { useState } from "react";
import { Check, Lock, Zap } from "lucide-react";
import type { PlanKey, PlanPrice } from "@/lib/app/plan-prices";
import { useLang } from "@/components/app/LangProvider";
import type { TKey } from "@/lib/i18n";

const PLANS: {
  id: PlanKey;
  nameKey: TKey;
  emoji: string;
  monthlyPrice: number;
  yearlyPrice: number;
  subtitleKey: TKey;
  color: string;
  buttonStyle: string;
  buttonTextKey: TKey;
  buttonDisabled: boolean;
  badgeKey: TKey | null;
  featureKeys: TKey[];
  lockedKeys: TKey[];
}[] = [
  {
    id: "free",
    nameKey: "planFreeName",
    emoji: "🌱",
    monthlyPrice: 0,
    yearlyPrice: 0,
    subtitleKey: "lpForever",
    color: "border-gray-200 bg-white",
    buttonStyle: "border border-gray-300 text-gray-400 cursor-default",
    buttonTextKey: "lpFreeBtn",
    buttonDisabled: true,
    badgeKey: null,
    featureKeys: ["lpFreeF1", "lpFreeF2", "lpFreeF3", "lpFreeF4", "lpFreeF5", "lpFreeF6"],
    lockedKeys: ["lpLockReports", "lpLockAnalytics"],
  },
  {
    id: "premium",
    nameKey: "planPremiumName",
    emoji: "🚀",
    monthlyPrice: 79000,
    yearlyPrice: 758000,
    subtitleKey: "lpPremiumSubtitle",
    color: "border-[#7C4DFF] bg-[#F3E5F5]",
    buttonStyle: "bg-[#7C4DFF] hover:bg-[#6C3FEE] text-white",
    buttonTextKey: "lpTrial7",
    buttonDisabled: false,
    badgeKey: "lpBadgePopular",
    featureKeys: ["lpPremF1", "lpPremF2", "lpPremF3", "lpPremF4", "lpPremF5", "lpPremF6", "lpPremF7", "lpPremF8"],
    lockedKeys: [],
  },
  {
    id: "family",
    nameKey: "planFamilyName",
    emoji: "👨‍👩‍👧‍👦",
    monthlyPrice: 149000,
    yearlyPrice: 1430000,
    subtitleKey: "lpFamilySubtitle",
    color: "border-secondary bg-secondary/5",
    buttonStyle: "bg-secondary hover:bg-secondary/90 text-white",
    buttonTextKey: "lpChooseFamily",
    buttonDisabled: false,
    badgeKey: null,
    featureKeys: ["lpFamF1", "lpFamF2", "lpFamF3", "lpFamF4"],
    lockedKeys: [],
  },
];

function formatVND(amount: number) {
  return amount.toLocaleString("vi-VN") + "₫";
}

const FAQ: { qKey: TKey; aKey: TKey }[] = [
  { qKey: "lpFaq1Q", aKey: "lpFaq1A" },
  { qKey: "lpFaq2Q", aKey: "lpFaq2A" },
  { qKey: "lpFaq3Q", aKey: "lpFaq3A" },
];

export function Pricing({ prices }: { prices?: Record<PlanKey, PlanPrice> }) {
  const { t } = useLang();
  const [isYearly, setIsYearly] = useState(false);
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  return (
    <section id="pricing" className="py-16 sm:py-24 bg-[#FFF8E7]">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-10">
          <span className="inline-block bg-secondary/10 text-secondary px-4 py-1.5 rounded-full text-sm font-medium mb-4">
            {t("lpPricingEyebrow")}
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 text-balance">
            {t("lpPricingTitle")}
          </h2>
          <p className="mt-3 text-lg text-gray-500">{t("pricingSubtitle")}</p>
        </div>

        {/* Billing toggle */}
        <div className="flex justify-center mb-10">
          <div className="inline-flex items-center bg-white border border-gray-200 rounded-full p-1 shadow-sm">
            <button
              onClick={() => setIsYearly(false)}
              className={`px-5 py-2 rounded-full text-sm font-semibold transition-all ${
                !isYearly ? "bg-secondary text-white shadow" : "text-gray-500 hover:text-gray-900"
              }`}
            >
              {t("billingMonthly")}
            </button>
            <button
              onClick={() => setIsYearly(true)}
              className={`px-5 py-2 rounded-full text-sm font-semibold transition-all flex items-center gap-1.5 ${
                isYearly ? "bg-secondary text-white shadow" : "text-gray-500 hover:text-gray-900"
              }`}
            >
              {t("billingYearly")}
              <span className="bg-green-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">
                -20%
              </span>
            </button>
          </div>
        </div>

        {/* Plan cards */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
          {PLANS.map((plan) => {
            // Prefer DB prices (admin-managed); fall back to static defaults.
            const dbp = prices?.[plan.id];
            const monthlyPrice = dbp?.monthly ?? plan.monthlyPrice;
            const yearlyPrice = dbp?.yearly ?? plan.yearlyPrice;
            const yearlyMonthlyEquiv = yearlyPrice > 0 ? Math.round(yearlyPrice / 12) : 0;
            const yearlySaving = yearlyPrice > 0 ? Math.max(0, monthlyPrice * 12 - yearlyPrice) : 0;
            const displayPrice = isYearly ? yearlyPrice : monthlyPrice;
            const showSaving = isYearly && yearlySaving > 0;

            return (
              <div
                key={plan.id}
                className={`relative rounded-3xl border-2 p-6 flex flex-col transition-shadow hover:shadow-xl ${plan.color} ${
                  plan.id === "premium" ? "md:-mt-3 md:mb-3 shadow-lg" : ""
                }`}
              >
                {/* Badge */}
                {plan.badgeKey && (
                  <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 bg-[#7C4DFF] text-white text-xs font-bold px-4 py-1 rounded-full whitespace-nowrap shadow">
                    {t(plan.badgeKey)}
                  </div>
                )}

                {/* Saving badge (yearly) */}
                {showSaving && (
                  <div className="absolute top-4 right-4 bg-green-500 text-white text-[11px] font-bold px-2.5 py-1 rounded-full">
                    {t("saveLabel")} {formatVND(yearlySaving)}
                  </div>
                )}

                {/* Plan header */}
                <div className="mb-5">
                  <div className="text-3xl mb-2">{plan.emoji}</div>
                  <h3 className="text-xl font-bold text-gray-900">{t(plan.nameKey)}</h3>

                  <div className="mt-3">
                    {monthlyPrice === 0 ? (
                      <div className="text-3xl font-extrabold text-gray-900">{t("priceFree")}</div>
                    ) : (
                      <>
                        <div className="text-3xl font-extrabold text-gray-900">
                          {formatVND(displayPrice)}
                          <span className="text-base font-normal text-gray-500">
                            {isYearly ? t("lpPerYear") : t("lpPerMonth")}
                          </span>
                        </div>
                        {isYearly && yearlyMonthlyEquiv > 0 && (
                          <p className="text-sm text-green-600 font-medium mt-0.5">
                            ≈ {formatVND(yearlyMonthlyEquiv)}{t("lpPerMonth")}
                          </p>
                        )}
                        {!isYearly && (
                          <p className="text-sm text-gray-500 mt-0.5">{t(plan.subtitleKey)}</p>
                        )}
                      </>
                    )}
                  </div>
                </div>

                {/* Features */}
                <ul className="space-y-2.5 flex-1 mb-6">
                  {plan.featureKeys.map((fk) => (
                    <li key={fk} className="flex items-start gap-2 text-sm text-gray-900">
                      <Check className="w-4 h-4 text-green-500 mt-0.5 shrink-0" />
                      {t(fk)}
                    </li>
                  ))}
                  {plan.lockedKeys.map((lk) => (
                    <li key={lk} className="flex items-start gap-2 text-sm text-gray-500/60">
                      <Lock className="w-4 h-4 mt-0.5 shrink-0" />
                      {t(lk)}
                    </li>
                  ))}
                </ul>

                {/* CTA */}
                <button
                  disabled={plan.buttonDisabled}
                  className={`w-full py-3 px-4 rounded-2xl font-bold text-sm transition-all ${plan.buttonStyle} ${
                    !plan.buttonDisabled ? "active:scale-95" : ""
                  }`}
                >
                  {plan.id === "premium" && isYearly
                    ? `${t("lpTrial7Short")} • ${formatVND(yearlyPrice)}${t("lpPerYear")}`
                    : t(plan.buttonTextKey)}
                </button>
              </div>
            );
          })}
        </div>

        {/* Trust badges */}
        <div className="flex flex-wrap justify-center gap-6 mb-12 text-sm text-gray-500">
          <span className="flex items-center gap-1.5">
            <span className="text-base">🔒</span> {t("lpTrustSecure")}
          </span>
          <span className="flex items-center gap-1.5">
            <span className="text-base">✅</span> {t("lpTrustCancel")}
          </span>
          <span className="flex items-center gap-1.5">
            <span className="text-base">🎁</span> {t("lpTrust7day")}
          </span>
          <span className="flex items-center gap-1.5">
            <Zap className="w-4 h-4 text-yellow-500" /> {t("lpTrustMethods")}
          </span>
        </div>

        {/* FAQ */}
        <div className="max-w-2xl mx-auto">
          <h3 className="text-xl font-bold text-gray-900 text-center mb-6">{t("lpFootFaq")}</h3>
          <div className="space-y-3">
            {FAQ.map((item, i) => (
              <div key={i} className="bg-white rounded-2xl border border-gray-200 overflow-hidden">
                <button
                  onClick={() => setOpenFaq(openFaq === i ? null : i)}
                  className="w-full text-left px-5 py-4 font-semibold text-gray-900 flex justify-between items-center hover:bg-gray-100/30 transition-colors"
                >
                  {t(item.qKey)}
                  <span className="text-gray-500 text-lg leading-none">
                    {openFaq === i ? "−" : "+"}
                  </span>
                </button>
                {openFaq === i && (
                  <div className="px-5 pb-4 text-sm text-gray-500">{t(item.aKey)}</div>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
