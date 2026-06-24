import ParentAiChat from "@/components/app/ParentAiChat";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ParentAiPage() {
  const lang = await getLang();
  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-4">
        {t(lang, "parentAiTitle")}
      </h1>
      <ParentAiChat />
    </div>
  );
}
