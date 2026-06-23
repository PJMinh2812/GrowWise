import { getSubscriptionDetails } from "@/lib/app/subscription";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";
import { getPlanPrices } from "@/lib/app/plan-prices";
import PricingPlans from "@/components/app/PricingPlans";

export const dynamic = "force-dynamic";

export default async function ParentPricingPage() {
  const { name, scheduledPlan } = await getSubscriptionDetails();
  const lang = await getLang();

  // Prices come from the `plans` table so they always reflect admin edits.
  const prices = await getPlanPrices();

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-1 text-center">
        {t(lang, "pricingTitle")} 🌟
      </h1>
      <p className="text-on-surface-variant mb-8 text-center">
        {t(lang, "pricingSubtitle")}
      </p>
      <PricingPlans currentPlan={name} scheduledPlan={scheduledPlan} prices={prices} />
    </div>
  );
}
