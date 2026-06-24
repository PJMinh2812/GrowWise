"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import type { RenewalInfo } from "@/lib/app/subscription";
import Icon from "@/components/Icon";

export default function SubscriptionBanner({ info }: { info: RenewalInfo }) {
  const router = useRouter();
  const { t } = useLang();
  const [hidden, setHidden] = useState(false);

  if (hidden) return null;
  if (info.state !== "expiring" && info.state !== "expired") return null;

  const expired = info.state === "expired";
  const title = `${info.displayName} ${expired ? t("renewExpiredSuffix") : t("renewExpiringSuffix")}`;
  const desc = expired
    ? t("renewExpiredHint")
    : `${t("renewDaysLeftPrefix")} ${info.daysLeft} ${t("renewDaysUnit")}. ${t("renewExpiringHint")}`;

  return (
    <div
      className="gw-card flex items-start gap-3"
      style={{
        borderLeft: `4px solid ${expired ? "var(--error, #d33)" : "var(--primary)"}`,
      }}
    >
      <Icon name={expired ? "error" : "schedule"} className="text-primary" />
      <div className="flex-1 min-w-0">
        <h3 className="font-extrabold text-on-surface">{title}</h3>
        <p className="text-sm text-on-surface-variant mt-0.5">{desc}</p>
        <div className="flex gap-3 mt-3">
          <button
            onClick={() => router.push("/parent/pricing")}
            className="gw-btn gw-btn--primary"
          >
            {t("renewCta")}
          </button>
          {!expired && (
            <button onClick={() => setHidden(true)} className="gw-btn gw-btn--ghost">
              {t("renewLater")}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
