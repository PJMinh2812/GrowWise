"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import PaymentQrModal from "./PaymentQrModal";
import { scheduleDowngrade } from "@/lib/app/subscription-actions";
import { useLang } from "./LangProvider";
import type { TKey } from "@/lib/i18n";
import type { PlanPrice } from "@/lib/app/plan-prices";
import Emoji, { type EmojiName } from "@/components/Emoji";

type PlanKey = "free" | "premium" | "family";
type Billing = "monthly" | "yearly";

const RANK: Record<PlanKey, number> = { free: 0, premium: 1, family: 2 };

interface PlanMeta {
  key: PlanKey;
  nameKey: TKey;
  emoji: EmojiName;
  featureKeys: TKey[];
  highlight?: boolean;
}

// Static layout (name/feature i18n keys + emoji); the price comes from the DB
// so it always reflects what admin sets in the pricing manager.
const PLAN_META: PlanMeta[] = [
  {
    key: "free",
    nameKey: "planFreeName",
    emoji: "seedling",
    featureKeys: ["featLessons3", "featJars3", "featTasks3", "featChat5", "featProfile1"],
  },
  {
    key: "premium",
    nameKey: "planPremiumName",
    emoji: "rocket",
    highlight: true,
    featureKeys: [
      "featAllLessons",
      "featTasksUnlimited",
      "featChatUnlimited",
      "featAiReports",
      "featCustomBadges",
      "featProfile1",
    ],
  },
  {
    key: "family",
    nameKey: "planFamilyName",
    emoji: "family",
    featureKeys: ["featAllPremium", "featProfiles3", "featParentDashboard", "featCompareKids"],
  },
];

export default function PricingPlans({
  currentPlan = "free",
  scheduledPlan = null,
  prices = {},
}: {
  currentPlan?: PlanKey;
  scheduledPlan?: PlanKey | null;
  prices?: Partial<Record<PlanKey, PlanPrice>>;
}) {
  const router = useRouter();
  const { t } = useLang();
  const [pay, setPay] = useState<null | "premium" | "family">(null);
  const [billing, setBilling] = useState<Billing>("monthly");
  const [pending, startTransition] = useTransition();
  const [note, setNote] = useState("");

  const isYearly = billing === "yearly";

  function fmt(amount: number): string {
    return `${amount.toLocaleString("vi-VN")}₫`;
  }

  /** Price actually shown for a plan given the selected billing interval. */
  function amountFor(key: PlanKey): number {
    const p = prices[key];
    if (!p) return 0;
    if (isYearly) return p.yearly ?? p.monthly * 12;
    return p.monthly;
  }

  /** Yearly saving vs paying monthly for 12 months (0 if none). */
  function yearlySaving(key: PlanKey): number {
    const p = prices[key];
    if (!p || !p.yearly) return 0;
    return Math.max(0, p.monthly * 12 - p.yearly);
  }

  function priceLabel(key: PlanKey): string {
    const amount = amountFor(key);
    return amount === 0 ? t("priceFree") : fmt(amount);
  }

  function priceSub(key: PlanKey): string {
    const amount = amountFor(key);
    if (amount === 0) return t("perMonth");
    if (isYearly) {
      const perMonth = Math.round((amount / 12) / 1000) * 1000;
      return `${t("perYear")} · ≈ ${fmt(perMonth)}${t("approxPerMonth")}`;
    }
    const perDay = Math.round(amount / 30 / 1000) * 1000;
    return `${t("perMonth")} · ~${fmt(perDay)}/${t("perDayUnit")}`;
  }

  function downgrade(target: PlanKey) {
    setNote("");
    startTransition(async () => {
      const res = await scheduleDowngrade(target);
      if (res.ok) {
        setNote(t("scheduledDowngradeMsg"));
        router.refresh();
      } else {
        setNote(res.error ?? t("scheduleError"));
      }
    });
  }

  return (
    <>
      {/* Billing interval toggle */}
      <div className="flex justify-center mb-8">
        <div className="inline-flex items-center rounded-full p-1 bg-surface-container-high">
          <button
            onClick={() => setBilling("monthly")}
            className={`px-5 py-2 rounded-full text-sm font-semibold transition-all ${
              !isYearly ? "bg-primary text-on-primary shadow" : "text-on-surface-variant"
            }`}
          >
            {t("billingMonthly")}
          </button>
          <button
            onClick={() => setBilling("yearly")}
            className={`px-5 py-2 rounded-full text-sm font-semibold transition-all flex items-center gap-1.5 ${
              isYearly ? "bg-primary text-on-primary shadow" : "text-on-surface-variant"
            }`}
          >
            {t("billingYearly")}
            <span className="bg-green-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">
              -20%
            </span>
          </button>
        </div>
      </div>

      <div className="gw-grid">
        {PLAN_META.map((p) => {
          const isCurrent = p.key === currentPlan;
          const isUpgrade = RANK[p.key] > RANK[currentPlan];
          const isScheduled = scheduledPlan === p.key;
          const saving = isYearly ? yearlySaving(p.key) : 0;
          return (
            <div
              key={p.key}
              className={`gw-card ${p.highlight ? "gw-card--glow" : ""}`}
              style={{ display: "flex", flexDirection: "column", position: "relative" }}
            >
              {p.highlight && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-primary text-on-primary text-xs font-bold px-3 py-1 rounded-full">
                  {t("mostPopular")}
                </span>
              )}
              {saving > 0 && (
                <span className="absolute top-3 right-3 bg-green-500 text-white text-[11px] font-bold px-2 py-0.5 rounded-full">
                  {t("saveLabel")} {fmt(saving)}
                </span>
              )}
              <h3 className="text-xl font-extrabold text-on-surface" style={{ display: "inline-flex", alignItems: "center", gap: "6px" }}>{t(p.nameKey)} <Emoji name={p.emoji} size={20} /></h3>
              <div className="mt-2">
                <span className="text-2xl font-extrabold text-primary">{priceLabel(p.key)}</span>
                <span className="text-sm text-on-surface-variant"> {priceSub(p.key)}</span>
              </div>
              <ul className="mt-4 space-y-2 flex-1">
                {p.featureKeys.map((fk) => (
                  <li key={fk} className="flex items-start gap-2 text-sm text-on-surface">
                    <span className="text-green-600">✓</span>
                    {t(fk)}
                  </li>
                ))}
              </ul>

              {isCurrent ? (
                <button
                  disabled
                  className="gw-btn gw-btn--ghost"
                  style={{ marginTop: "20px" }}
                >
                  {t("currentPlanBtn")}
                </button>
              ) : isUpgrade ? (
                <button
                  onClick={() => setPay(p.key as "premium" | "family")}
                  className={`gw-btn ${p.highlight ? "gw-btn--primary" : "gw-btn--tertiary"}`}
                  style={{ marginTop: "20px" }}
                >
                  {t("upgradeArrow")}
                </button>
              ) : isScheduled ? (
                <button
                  disabled
                  className="gw-btn gw-btn--ghost"
                  style={{ marginTop: "20px" }}
                >
                  {t("scheduledPlanBtn")}
                </button>
              ) : (
                <button
                  onClick={() => downgrade(p.key)}
                  disabled={pending}
                  className="gw-btn gw-btn--ghost"
                  style={{ marginTop: "20px" }}
                >
                  {t("downgradeAtEnd")}
                </button>
              )}
            </div>
          );
        })}
      </div>

      {note && <p className="mt-4 text-center text-sm text-on-surface-variant">{note}</p>}

      {pay && (
        <PaymentQrModal planName={pay} billingInterval={billing} onClose={() => setPay(null)} />
      )}
    </>
  );
}
