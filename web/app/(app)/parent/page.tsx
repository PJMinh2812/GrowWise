import Link from "next/link";
import { getFamilyForUser, getChildren } from "@/lib/app/children";
import {
  getPendingSubmissions,
  getRecentAutoApproved,
  getWeeklyCoins,
} from "@/lib/app/submissions";
import ApprovalQueue from "@/components/app/ApprovalQueue";
import ParentFinanceCard from "@/components/app/ParentFinanceCard";
import SurveyBanner from "@/components/app/SurveyBanner";
import SubscriptionBanner from "@/components/app/SubscriptionBanner";
import { getActiveSurveyFor } from "@/lib/app/surveys";
import { getRenewalState } from "@/lib/app/subscription";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

export default async function ParentDashboard() {
  const lang = await getLang();
  const family = await getFamilyForUser();
  const [children, pending, autoApproved, weeklyCoins] = family
    ? await Promise.all([
        getChildren(family.id),
        getPendingSubmissions(family.id),
        getRecentAutoApproved(family.id),
        getWeeklyCoins(family.id),
      ])
    : [[], [], [], 0];
  const survey = await getActiveSurveyFor("parent");
  const renewal = await getRenewalState();

  return (
    <div className="pt-4">
      <div className="mb-4 rise">
        <h1 className="text-2xl font-black text-primary mb-0.5">{t(lang, "navDashboard")}</h1>
        <p className="font-bold text-on-surface-variant">{t(lang, "manageAndTrack")}</p>
      </div>

      {(renewal.state === "expiring" || renewal.state === "expired") && (
        <div className="mb-4 rise rise-2">
          <SubscriptionBanner info={renewal} />
        </div>
      )}

      {survey && (
        <div className="mb-4 rise rise-2">
          <SurveyBanner survey={survey} />
        </div>
      )}

      {!family && (
        <div className="gw-card mb-4">
          <p className="text-on-surface font-semibold">
            {t(lang, "noFamilyMsg")}{" "}
            <Link href="/parent/settings" className="text-primary font-extrabold underline">
              {t(lang, "navSettings")}
            </Link>
            .
          </p>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-2 gap-3 mb-4 rise rise-3">
        <StatCard icon="hourglass_top" tone="primary" label={t(lang, "pendingReview")} value={String(pending.length)} />
        <StatCard icon="savings" tone="secondary" label={t(lang, "weeklyCoins")} value={weeklyCoins.toLocaleString("vi-VN")} />
        <StatCard icon="group" tone="tertiary" label={t(lang, "childrenCount")} value={String(children.length)} />
      </div>

      {/* Child finances (jars + deduct) */}
      <div className="rise rise-3">
        <ParentFinanceCard
          children={children.map((c) => ({
            id: c.id,
            name: c.name,
            emoji: c.avatar_emoji,
            total: c.total_coins,
            spend: c.spend_jar,
            save: c.save_jar,
            share: c.share_jar,
          }))}
        />
      </div>

      {/* Quick action → roadmap (create tasks) */}
      <div className="mb-5 rise rise-3">
        <Link href="/parent/roadmap" className="gw-btn gw-btn--primary">
          <Icon name="route" />
          {t(lang, "navRoadmap")}
        </Link>
      </div>

      <div className="rise rise-4">
        <ApprovalQueue pending={pending} autoApproved={autoApproved} />
      </div>
    </div>
  );
}

function StatCard({
  icon,
  label,
  value,
  tone,
}: {
  icon: string;
  label: string;
  value: string;
  tone: "primary" | "secondary" | "tertiary";
}) {
  const toneCls = {
    primary: "bg-primary-fixed text-on-primary-container",
    secondary: "bg-secondary-container text-secondary",
    tertiary: "bg-tertiary-fixed text-on-tertiary-container",
  }[tone];
  return (
    <div className="gw-card gw-card--press">
      <div className={`w-9 h-9 rounded-full flex items-center justify-center mb-3 ${toneCls}`}>
        <Icon name={icon} className="text-xl" />
      </div>
      <p className="text-2xl font-black text-on-surface">{value}</p>
      <p className="text-sm font-bold text-on-surface-variant">{label}</p>
    </div>
  );
}
