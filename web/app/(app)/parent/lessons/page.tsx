import Link from "next/link";
import { getLessons } from "@/lib/app/lessons";

export const dynamic = "force-dynamic";

export default async function ParentLessonsPage() {
  const lessons = await getLessons("parent");
  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">
        Bài học cho ba mẹ
      </h1>
      {lessons.length === 0 ? (
        <div className="app-card p-8 text-center text-on-surface-variant">
          Chưa có bài học nào.
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {lessons.map((l) => (
            <Link
              key={l.id}
              href={`/parent/lessons/${l.id}`}
              className="app-card overflow-hidden hover:-translate-y-0.5 transition-transform"
            >
              <div className="h-24 bg-primary-container/30 flex items-center justify-center text-5xl">
                {l.thumbnail_emoji}
              </div>
              <div className="p-4">
                <p className="font-bold text-on-surface">{l.title}</p>
                <p className="text-xs text-on-surface-variant mt-1 line-clamp-2">
                  {l.description}
                </p>
                <p className="text-xs text-on-surface-variant mt-2">
                  ⏱ {Math.round(l.duration_seconds / 60)} phút
                </p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
