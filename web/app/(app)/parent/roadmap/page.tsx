import { getFamilyForUser, getChildren } from "@/lib/app/children";
import RoadmapManager from "@/components/app/RoadmapManager";
import CreateTaskForm from "@/components/app/CreateTaskForm";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ParentRoadmapPage() {
  const lang = await getLang();
  const family = await getFamilyForUser();
  const children = family ? await getChildren(family.id) : [];

  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-2">
        {t(lang, "roadmapPageTitle")}
      </h1>
      <p className="text-on-surface-variant mb-6">{t(lang, "roadmapRunning")}</p>

      {children.length === 0 ? (
        <div className="gw-card" style={{ padding: "24px" }}>
          <p className="text-on-surface">{t(lang, "needChildProfileMsg")}</p>
        </div>
      ) : (
        <>
          <RoadmapManager children={children.map((c) => ({ id: c.id, name: c.name, emoji: c.avatar_emoji }))} />
          <h2 className="font-extrabold text-on-surface mb-3">{t(lang, "createTaskBtn")}</h2>
          <CreateTaskForm children={children} />
        </>
      )}
    </div>
  );
}
