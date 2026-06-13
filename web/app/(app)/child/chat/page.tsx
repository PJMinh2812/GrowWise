import { getSelectedChild } from "@/lib/app/children";
import WisyChat from "@/components/app/WisyChat";

export const dynamic = "force-dynamic";

export default async function ChatPage() {
  const child = await getSelectedChild();
  if (!child) return <div className="app-card p-6 text-on-surface">Chưa có hồ sơ con.</div>;
  return <WisyChat childId={child.id} childName={child.name} />;
}
