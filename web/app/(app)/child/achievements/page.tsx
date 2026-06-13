import { getSelectedChild } from "@/lib/app/children";
import { getBadges } from "@/lib/app/dreams";

export const dynamic = "force-dynamic";

export default async function AchievementsPage() {
  const child = await getSelectedChild();
  if (!child) return <div className="app-card p-6 text-on-surface">Chưa có hồ sơ con.</div>;
  const badges = await getBadges(child.id);

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-2">Thành tích</h1>

      <div className="app-card p-5 mb-6 flex items-center gap-4">
        <span className="text-4xl">{child.avatar_emoji}</span>
        <div>
          <p className="font-bold text-on-surface">Cấp độ {child.level}</p>
          <p className="text-sm text-on-surface-variant">{badges.length} huy hiệu đã đạt</p>
        </div>
      </div>

      {badges.length === 0 ? (
        <div className="app-card p-8 text-center text-on-surface-variant">
          Chưa có huy hiệu nào. Hoàn thành nhiệm vụ để mở khoá nhé! 🏅
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {badges.map((b) => (
            <div key={b.id} className="app-card p-5 text-center">
              <div className="text-4xl mb-2">{b.emoji}</div>
              <p className="font-bold text-on-surface text-sm">{b.title}</p>
              <p className="text-xs text-on-surface-variant mt-1">
                {new Date(b.earned_at).toLocaleDateString("vi-VN")}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
