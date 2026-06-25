import Link from "next/link";
import { getFamilyForUser, getChildren } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import { getRoadmapPlan } from "@/lib/app/roadmap";
import RoadmapManager from "@/components/app/RoadmapManager";
import RoadmapWizard from "@/components/app/RoadmapWizard";
import RoadmapPresets from "@/components/app/RoadmapPresets";
import RoadmapMilestones from "@/components/app/RoadmapMilestones";
import CreateTaskForm from "@/components/app/CreateTaskForm";
import Icon from "@/components/Icon";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ParentRoadmapPage() {
  const lang = await getLang();
  const family = await getFamilyForUser();
  const children = family ? await getChildren(family.id) : [];
  const tasks = family ? await getTaskTemplates(family.id, undefined, true) : [];
  const firstChild = children[0];
  const plan = firstChild ? await getRoadmapPlan(firstChild.id) : null;

  const lite = children.map((c) => ({ id: c.id, name: c.name, emoji: c.avatar_emoji, age: c.age }));

  return (
    <div className="max-w-2xl pt-2">
      <h1 className="text-2xl font-black text-primary mb-1" style={{ display: "inline-flex", alignItems: "center", gap: 8 }}>
        {t(lang, "roadmapPageTitle")}
      </h1>
      <p className="text-on-surface-variant mb-5">{t(lang, "roadmapRunning")}</p>

      {children.length === 0 ? (
        <div className="gw-card" style={{ padding: "24px" }}>
          <p className="text-on-surface">{t(lang, "needChildProfileMsg")}</p>
        </div>
      ) : (
        <>
          <RoadmapWizard children={lite} />
          <RoadmapPresets children={lite} />

          <div className="flex items-center justify-between mb-2">
            <h2 className="font-extrabold text-on-surface">{t(lang, "rmCurrentRoadmap")}</h2>
            <div className="flex items-center gap-3">
              {firstChild && plan?.stages?.length ? (
                <RoadmapMilestones childId={firstChild.id} currentStage={plan.current_stage} stages={plan.stages} />
              ) : null}
            </div>
          </div>

          {firstChild && (
            <Link href={`/parent/roadmap/timeline?child=${firstChild.id}`} className="gw-btn gw-btn--ghost gw-btn--sm mb-3" style={{ width: "auto" }}>
              <Icon name="route" className="text-base" /> {t(lang, "rmViewChildTimeline")}
            </Link>
          )}

          <RoadmapManager children={children} tasks={tasks} />

          <h2 className="font-extrabold text-on-surface mb-3">{t(lang, "createTaskBtn")}</h2>
          <CreateTaskForm children={children} />
        </>
      )}
    </div>
  );
}
