import { getSelectedChild } from "@/lib/app/children";
import ChildSettingsView from "@/components/app/ChildSettingsView";
import LanguageToggle from "@/components/app/LanguageToggle";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function ChildSettingsPage() {
  const [lang, child] = await Promise.all([getLang(), getSelectedChild()]);

  if (!child) {
    return (
      <div className="gw-card" style={{ padding: "24px", color: "var(--ink)" }}>
        Chưa có hồ sơ con.
      </div>
    );
  }

  return (
    <div className="max-w-md">
      <h1 className="text-2xl font-extrabold text-on-surface mb-6">{t(lang, "navSettings")}</h1>
      <div className="gw-card mb-4" style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "14px 16px" }}>
        <span className="font-extrabold text-on-surface">🌐 {t(lang, "language")}</span>
        <LanguageToggle />
      </div>
      <ChildSettingsView
        childId={child.id}
        initialName={child.name}
        initialEmoji={child.avatar_emoji}
        initialAvatarUrl={child.avatar_url ?? ""}
        hasPin={Boolean(child.child_pin_hash)}
      />
    </div>
  );
}
