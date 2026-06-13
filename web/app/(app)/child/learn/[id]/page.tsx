import Link from "next/link";
import { getLesson } from "@/lib/app/lessons";
import LessonPlayer from "@/components/app/LessonPlayer";

export const dynamic = "force-dynamic";

export default async function ChildLessonPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const lesson = await getLesson(id);
  if (!lesson) {
    return <div className="app-card p-6 text-on-surface">Không tìm thấy bài học.</div>;
  }
  return (
    <div className="max-w-3xl mx-auto">
      <Link href="/child/learn" className="text-sm text-primary font-semibold">
        ← Tất cả bài học
      </Link>
      <div className="mt-3">
        <LessonPlayer lesson={lesson} />
      </div>
    </div>
  );
}
