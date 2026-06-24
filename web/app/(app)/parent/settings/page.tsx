import { getFamilyForUser, getChildren } from "@/lib/app/children";
import { getSubscriptionDetails } from "@/lib/app/subscription";
import { getAppProfile } from "@/lib/app/auth";
import SettingsView from "@/components/app/SettingsView";
import ParentChildTools from "@/components/app/ParentChildTools";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

const PLAN_LABEL: Record<string, string> = {
  free: "Cơ Bản (Miễn phí)",
  premium: "Nâng Cao",
  family: "Gia Đình",
};

export default async function SettingsPage() {
  const lang = await getLang();
  const family = await getFamilyForUser();
  const [children, plan, profile] = await Promise.all([
    family ? getChildren(family.id) : Promise.resolve([]),
    getSubscriptionDetails(),
    getAppProfile(),
  ]);

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">{t(lang, "navSettings")}</h1>
      <SettingsView
        planLabel={PLAN_LABEL[plan.name] ?? plan.name}
        planName={plan.name}
        maxChildren={plan.maxChildren}
        periodEnd={plan.periodEnd}
        scheduledPlanLabel={plan.scheduledPlan ? (PLAN_LABEL[plan.scheduledPlan] ?? plan.scheduledPlan) : null}
        parentFullName={profile?.full_name ?? ""}
        parentAvatarUrl={profile?.avatar_url ?? ""}
        children={children.map((c) => ({
          id: c.id,
          name: c.name,
          emoji: c.avatar_emoji,
          age: c.age,
          dateOfBirth: c.date_of_birth ?? undefined,
          level: c.level,
          hasPin: Boolean(c.child_pin_hash),
        }))}
      />
      <ParentChildTools children={children.map((c) => ({ id: c.id, name: c.name, emoji: c.avatar_emoji }))} />
    </div>
  );
}
