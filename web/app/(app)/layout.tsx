// Route group wrapper for the GrowWise user app (parent + child).
// Auth is enforced in proxy.ts. Theme is applied in /parent and /child sub-layouts.
import { getLang } from "@/lib/i18n-server";
import { LangProvider } from "@/components/app/LangProvider";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const lang = await getLang();
  return (
    <LangProvider initialLang={lang}>
      <div className="min-h-screen w-full">{children}</div>
    </LangProvider>
  );
}
