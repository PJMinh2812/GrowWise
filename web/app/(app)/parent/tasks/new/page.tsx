import Link from "next/link";
import { getMyChildren } from "@/lib/app/children";
import CreateTaskForm from "@/components/app/CreateTaskForm";
import { getLang } from "@/lib/i18n-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

export default async function NewTaskPage() {
  const [lang, children] = await Promise.all([getLang(), getMyChildren()]);

  if (children.length === 0) {
    return (
      <div className="gw-card" style={{ padding: "24px" }}>
        <p className="text-on-surface">
          {t(lang, "needChildProfileMsg")}{" "}
          <Link href="/parent/settings" className="text-primary underline font-semibold">
            {t(lang, "navSettings")}
          </Link>
          .
        </p>
      </div>
    );
  }

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">
        {t(lang, "newTaskTitle")}
      </h1>
      <CreateTaskForm children={children} />
    </div>
  );
}
