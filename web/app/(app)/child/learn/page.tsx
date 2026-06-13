import Link from "next/link";
import { getLessons } from "@/lib/app/lessons";
import { getUserPlan, isPremiumPlan, FREE_LIMITS } from "@/lib/app/subscription";

export const dynamic = "force-dynamic";

export default async function ChildLearnPage() {
  const [lessons, plan] = await Promise.all([getLessons("child"), getUserPlan()]);
  const premium = isPremiumPlan(plan);

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">Học bài</h1>
      {lessons.length === 0 ? (
        <div className="app-card p-8 text-center text-on-surface-variant">
          Chưa có bài học nào.
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {lessons.map((l, i) => {
            const locked = !premium && i >= FREE_LIMITS.lessons;
            const card = (
              <div className="app-card overflow-hidden h-full">
                <div className="h-24 bg-primary-container/30 flex items-center justify-center text-5xl relative">
                  {l.thumbnail_emoji}
                  {locked && (
                    <span className="absolute inset-0 bg-black/40 flex items-center justify-center text-white">
                      <span className="material-symbols-outlined text-3xl">lock</span>
                    </span>
                  )}
                </div>
                <div className="p-4">
                  <p className="font-bold text-on-surface">{l.title}</p>
                  <p className="text-xs text-on-surface-variant mt-1 line-clamp-2">
                    {l.description}
                  </p>
                  <p className="text-xs text-on-surface-variant mt-2">
                    {locked ? "🔒 Premium" : `⏱ ${Math.round(l.duration_seconds / 60)} phút`}
                  </p>
                </div>
              </div>
            );
            return locked ? (
              <Link key={l.id} href="/parent/settings" className="block">
                {card}
              </Link>
            ) : (
              <Link
                key={l.id}
                href={`/child/learn/${l.id}`}
                className="block hover:-translate-y-0.5 transition-transform"
              >
                {card}
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
