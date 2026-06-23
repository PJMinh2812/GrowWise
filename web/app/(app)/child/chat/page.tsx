import { getSelectedChild } from "@/lib/app/children";
import WisyChat from "@/components/app/WisyChat";

export const dynamic = "force-dynamic";

export default async function ChatPage() {
  const child = await getSelectedChild();
  if (!child) return <div className="gw-card" style={{ padding: "24px", color: "var(--ink)" }}>Chưa có hồ sơ con.</div>;
  return <WisyChat childId={child.id} childName={child.name} />;
}
