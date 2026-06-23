import { getLessons, getCompletedLessonIds } from "@/lib/app/lessons";
import { getUserPlan, isPremiumPlan, FREE_LIMITS } from "@/lib/app/subscription";
import { getSelectedChild } from "@/lib/app/children";
import LearnContent from "@/components/app/LearnContent";

export const dynamic = "force-dynamic";

export default async function ChildLearnPage() {
  const [lessons, plan, child] = await Promise.all([
    getLessons("child"),
    getUserPlan(),
    getSelectedChild(),
  ]);
  const premium = isPremiumPlan(plan);
  const completedIds = child ? await getCompletedLessonIds(child.id) : [];
  return (
    <LearnContent
      lessons={lessons}
      premium={premium}
      freeLimit={FREE_LIMITS.lessons}
      completedIds={completedIds}
    />
  );
}
