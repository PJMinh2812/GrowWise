import { getSelectedChild } from "@/lib/app/children";
import { getDreamItems } from "@/lib/app/dreams";
import DreamsView from "@/components/app/DreamsView";

export const dynamic = "force-dynamic";

export default async function DreamsPage() {
  const child = await getSelectedChild();
  if (!child) return <div className="app-card p-6 text-on-surface">Chưa có hồ sơ con.</div>;
  const dreams = await getDreamItems(child.id);
  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">Ước mơ của mình</h1>
      <DreamsView childId={child.id} totalCoins={child.total_coins} dreams={dreams} />
    </div>
  );
}
