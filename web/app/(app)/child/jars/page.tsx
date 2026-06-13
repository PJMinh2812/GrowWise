import { getSelectedChild } from "@/lib/app/children";
import JarsView from "@/components/app/JarsView";

export const dynamic = "force-dynamic";

export default async function JarsPage() {
  const child = await getSelectedChild();
  if (!child) {
    return <div className="app-card p-6 text-on-surface">Chưa có hồ sơ con.</div>;
  }
  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">
        3 Hũ tiền của mình
      </h1>
      <JarsView
        childId={child.id}
        spend={child.spend_jar}
        save={child.save_jar}
        share={child.share_jar}
      />
    </div>
  );
}
