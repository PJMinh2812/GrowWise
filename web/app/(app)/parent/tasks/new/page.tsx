import Link from "next/link";
import { getMyChildren } from "@/lib/app/children";
import CreateTaskForm from "@/components/app/CreateTaskForm";

export const dynamic = "force-dynamic";

export default async function NewTaskPage() {
  const children = await getMyChildren();

  if (children.length === 0) {
    return (
      <div className="app-card p-6">
        <p className="text-on-surface">
          Bạn cần có hồ sơ con trước khi tạo nhiệm vụ. Tạo trong{" "}
          <Link href="/parent/settings" className="text-primary underline font-semibold">
            Cài đặt
          </Link>
          .
        </p>
      </div>
    );
  }

  return (
    <div>
      <h1 className="text-2xl md:text-3xl font-extrabold text-on-surface mb-6">
        Tạo nhiệm vụ mới
      </h1>
      <CreateTaskForm children={children} />
    </div>
  );
}
