import Link from "next/link";
import { getSelectedChild, getFamilyForUser } from "@/lib/app/children";
import { getTaskTemplates } from "@/lib/app/tasks";
import type { Task } from "@/lib/types";

export const dynamic = "force-dynamic";

export default async function MarketPage() {
  const child = await getSelectedChild();
  const family = await getFamilyForUser();
  const templates = child && family ? await getTaskTemplates(family.id, child.id) : [];

  const byCategory = templates.reduce<Record<string, Task[]>>((acc, t) => {
    (acc[t.category] ??= []).push(t);
    return acc;
  }, {});

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">Chợ nhiệm vụ</h1>

      {templates.length === 0 ? (
        <div className="app-card p-8 text-center text-on-surface-variant">
          Chưa có nhiệm vụ nào. Nhờ ba mẹ tạo nhé!
        </div>
      ) : (
        <div className="space-y-8">
          {Object.entries(byCategory).map(([cat, tasks]) => (
            <section key={cat}>
              <h2 className="text-lg font-bold text-on-surface mb-3">{cat}</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {tasks.map((t) => (
                  <div key={t.id} className="app-card p-5">
                    <div className="text-3xl mb-2">{t.icon}</div>
                    <p className="font-bold text-on-surface">{t.title}</p>
                    <p className="text-sm text-tertiary font-semibold mb-3">🪙 +{t.coin_reward}</p>
                    <Link
                      href="/child"
                      className="inline-block px-4 py-2 rounded-[14px] bg-primary text-on-primary text-sm font-bold"
                    >
                      Làm ngay
                    </Link>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}
