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
        <div className="app-card p-10 text-center text-on-surface-variant">
          <span className="material-symbols-outlined text-5xl text-primary mb-2">photo_library</span>
          <p>Chưa có kỷ niệm mới.</p>
          <p className="text-sm mt-1">
            Mỗi khi con hoàn thành nhiệm vụ, kỷ niệm sẽ xuất hiện ở đây.{" "}
            <Link href="/parent" className="text-primary underline font-semibold">
              Về bảng điều khiển
            </Link>
          </p>
        </div>
      ) : (
        <MemoryGallery memories={memories} childMap={childMap} />
      )}
    </div>
  );
}
