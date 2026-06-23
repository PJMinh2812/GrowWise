import Link from "next/link";
import { getFamilyForUser, getChildren } from "@/lib/app/children";
import { getMemories } from "@/lib/app/memories";
import MemoryGallery from "@/components/app/MemoryGallery";
import type { ChildMap } from "@/lib/memory-export";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function MemoriesPage() {
  const lang = await getLang();
  const family = await getFamilyForUser();
  const [memories, children] = family
    ? await Promise.all([getMemories(family.id), getChildren(family.id)])
    : [[], []];

  const childMap: ChildMap = {};
  for (const c of children) childMap[c.id] = { name: c.name, emoji: c.avatar_emoji };

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-1">
        {t(lang, "memoriesTitle")}
      </h1>
      <p className="text-on-surface-variant mb-6">{t(lang, "memoriesSub")}</p>

      {memories.length === 0 ? (
        <div className="gw-card" style={{ padding: "40px", textAlign: "center", color: "var(--ink-soft)" }}>
          <span className="material-symbols-outlined text-5xl text-primary mb-2">photo_library</span>
          <p>{t(lang, "memoriesEmptyTitle")}</p>
          <p className="text-sm mt-1">
            {t(lang, "memoriesEmptyDesc")}{" "}
            <Link href="/parent" className="text-primary underline font-semibold">
              {t(lang, "backToDashboard")}
            </Link>
          </p>
        </div>
      ) : (
        <MemoryGallery memories={memories} childMap={childMap} />
      )}
    </div>
  );
}
