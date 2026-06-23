import Link from "next/link";
import { getLessons } from "@/lib/app/lessons";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ParentLessonsPage() {
  const [lang, lessons] = await Promise.all([getLang(), getLessons("parent")]);
  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">
        {t(lang, "lessonsParentTitle")}
      </h1>
      {lessons.length === 0 ? (
        <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
          {t(lang, "lessonsEmpty")}
        </div>
      ) : (
        <div className="gw-grid">
          {lessons.map((l) => (
            <Link
              key={l.id}
              href={`/parent/lessons/${l.id}`}
              className="gw-tile gw-card--press"
            >
              <div className="h-24 bg-primary-container/30 flex items-center justify-center text-5xl overflow-hidden relative">
                {l.thumbnail_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={l.thumbnail_url} alt={l.title} className="absolute inset-0 w-full h-full object-cover" />
                ) : (
                  l.thumbnail_emoji
                )}
              </div>
              <div className="p-4">
                <p className="font-bold text-on-surface">{l.title}</p>
                <p className="text-xs text-on-surface-variant mt-1 line-clamp-2">
                  {l.description}
                </p>
                <p className="text-xs text-on-surface-variant mt-2">
                  ⏱ {Math.round(l.duration_seconds / 60)} {t(lang, "minutesShort")}
                </p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
