import Link from "next/link";
import { getLesson } from "@/lib/app/lessons";
import { getSelectedChild } from "@/lib/app/children";
import LessonPlayer from "@/components/app/LessonPlayer";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ChildLessonPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const [lang, lesson, child] = await Promise.all([getLang(), getLesson(id), getSelectedChild()]);
  if (!lesson) {
    return (
      <div className="gw-card" style={{ padding: "24px", textAlign: "center", color: "var(--ink-soft)" }}>
        {t(lang, "lessonNotFound")}
      </div>
    );
  }
  return (
    <div style={{ maxWidth: "430px", margin: "0 auto" }}>
      <Link href="/child/learn">
        <button type="button" className="gw-btn gw-btn--ghost gw-btn--sm" style={{ marginBottom: "16px" }}>
          <span className="material-symbols-outlined">arrow_back</span>
          {t(lang, "allLessonsBtn")}
        </button>
      </Link>
      <LessonPlayer lesson={lesson} childId={child?.id ?? null} />
    </div>
  );
}
