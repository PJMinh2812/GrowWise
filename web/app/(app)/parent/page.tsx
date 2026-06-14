import Link from "next/link";
import { getFamilyForUser, getChildren } from "@/lib/app/children";
import {
  getPendingSubmissions,
  getRecentAutoApproved,
  getWeeklyCoins,
} from "@/lib/app/submissions";
import ApprovalQueue from "@/components/app/ApprovalQueue";
import EmotionCheckIn from "@/components/app/EmotionCheckIn";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

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

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-1">
          {t(lang, "navDashboard")}
        </h1>
        <p className="text-on-surface-variant">{t(lang, "manageAndTrack")}</p>
      </div>

      <div className="mb-6">
        <EmotionCheckIn />
      </div>

      {!family && (
        <div className="app-card p-6 mb-6">
          <p className="text-on-surface">
            Bạn chưa có hồ sơ gia đình. Hãy tạo hồ sơ con trong{" "}
            <Link href="/parent/settings" className="text-primary font-semibold underline">
              Cài đặt
            </Link>
            .
          </p>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <StatCard icon="hourglass_top" label={t(lang, "pendingReview")} value={String(pending.length)} />
        <StatCard
          icon="savings"
          label={t(lang, "weeklyCoins")}
          value={weeklyCoins.toLocaleString("vi-VN")}
        />
        <StatCard icon="group" label={t(lang, "childrenCount")} value={String(children.length)} />
      </div>

      {/* Quick action */}
      <div className="mb-8">
        <Link
          href="/parent/tasks/new"
          className="inline-flex items-center gap-2 px-5 py-3 rounded-[14px] bg-primary text-on-primary font-bold"
        >
          <span className="material-symbols-outlined">add_task</span>
          {t(lang, "newTask")}
        </Link>
      </div>

      <ApprovalQueue pending={pending} autoApproved={autoApproved} />
    </div>
  );
}

function StatCard({ icon, label, value }: { icon: string; label: string; value: string }) {
  return (
    <div className="app-card p-5">
      <div className="w-10 h-10 rounded-full bg-primary-container/30 flex items-center justify-center text-primary mb-3">
        <span className="material-symbols-outlined">{icon}</span>
      </div>
      <p className="text-2xl font-extrabold text-on-surface">{value}</p>
      <p className="text-sm text-on-surface-variant">{label}</p>
    </div>
  );
}
