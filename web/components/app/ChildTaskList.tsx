"use client";

import { useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { submitTask } from "@/lib/app/child-actions";
import type { Task, TaskStatus } from "@/lib/types";
import { useLang } from "./LangProvider";

export interface ChildTaskItem {
  task: Task;
  status: TaskStatus | "todo";
  parentNote?: string | null;
}

export default function ChildTaskList({
  childId,
  items,
}: {
  childId: string;
  items: ChildTaskItem[];
}) {
  const rejected = items.filter((i) => i.status === "rejected");
  const todo = items.filter((i) => i.status === "todo");
  const submitted = items.filter((i) => i.status === "submitted");
  const done = items.filter((i) => i.status === "approved");

  return (
    <div className="space-y-3">
      {rejected.map((i) => (
        <TaskCard key={i.task.id} item={i} childId={childId} variant="rejected" />
      ))}
      {todo.map((i) => (
        <TaskCard key={i.task.id} item={i} childId={childId} variant="todo" />
      ))}
      {submitted.map((i) => (
        <TaskCard key={i.task.id} item={i} childId={childId} variant="submitted" />
      ))}
      {done.map((i) => (
        <TaskCard key={i.task.id} item={i} childId={childId} variant="done" />
      ))}
      {items.length === 0 && (
        <div className="gw-card text-center text-on-surface-variant font-semibold py-8">
          Chưa có nhiệm vụ nào. Ghé <b>Chợ nhiệm vụ</b> để nhận thêm nhé!
        </div>
      )}
    </div>
  );
}

function TaskCard({
  item,
  childId,
  variant,
}: {
  item: ChildTaskItem;
  childId: string;
  variant: "rejected" | "todo" | "submitted" | "done";
}) {
  const router = useRouter();
  const { t } = useLang();
  const fileRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState("");
  const [pending, start] = useTransition();
  const { task } = item;
  const cameraOnly =
    task.auto_approve_after != null && task.approval_count >= task.auto_approve_after;

  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setError("");
    setUploading(true);
    try {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error("Phiên đăng nhập hết hạn");
      const path = `${user.id}/${task.id}-${Date.now()}.jpg`;
      const { error: upErr } = await supabase.storage
        .from("task-proofs")
        .upload(path, file, { contentType: file.type || "image/jpeg", upsert: true });
      if (upErr) throw upErr;
      const url = supabase.storage.from("task-proofs").getPublicUrl(path).data.publicUrl;
      start(async () => {
        const res = await submitTask({ taskId: task.id, childId, proofUrl: url });
        if (!res.ok) setError(res.error ?? "Không gửi được");
        else router.refresh();
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Tải ảnh thất bại");
    } finally {
      setUploading(false);
    }
  }

  const border =
    variant === "rejected"
      ? "border-2 border-error/50"
      : variant === "done"
        ? "opacity-70"
        : "";
  const actionable = variant === "todo" || variant === "rejected";

  return (
    <div className={`gw-card ${variant !== "done" ? "gw-card--press" : ""} mb-3 ${border}`}>
      <div className="flex items-center gap-3">
        <span className="grid place-items-center w-12 h-12 rounded-2xl bg-surface-container-high text-2xl shrink-0">
          {task.icon}
        </span>
        <div className="flex-1 min-w-0">
          <p className="font-extrabold text-on-surface truncate">{task.title}</p>
          <span className="inline-flex items-center gap-1 text-sm font-extrabold text-primary mt-0.5">
            <span className="material-symbols-outlined text-base">toll</span>+{task.coin_reward} xu
          </span>
        </div>
        {actionable ? (
          <button
            disabled={uploading || pending}
            onClick={() => fileRef.current?.click()}
            className="gw-btn gw-btn--primary gw-btn--sm"
          >
            {uploading || pending ? "…" : variant === "rejected" ? t("resubmit") : t("submit")}
          </button>
        ) : (
          <StatusChip variant={variant} />
        )}
      </div>

      {variant === "rejected" && item.parentNote && (
        <p className="mt-2 text-sm text-error font-semibold">Ba/mẹ nhắn: {item.parentNote}</p>
      )}

      {actionable && (
        <div className="mt-2">
          {cameraOnly && (
            <p className="text-xs text-amber-600 mb-2">
              ⚠️ Nhiệm vụ tự động duyệt — chỉ chụp ảnh trực tiếp.
            </p>
          )}
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            capture={cameraOnly ? "environment" : undefined}
            onChange={onPickFile}
            className="hidden"
          />
          {error && <p className="text-sm text-error mt-1">{error}</p>}
        </div>
      )}
    </div>
  );
}

function StatusChip({ variant }: { variant: string }) {
  const map: Record<string, { label: string; cls: string }> = {
    rejected: { label: "Bị từ chối", cls: "bg-error/10 text-error" },
    todo: { label: "Chờ làm", cls: "bg-surface-container text-on-surface-variant" },
    submitted: { label: "Đang chờ duyệt", cls: "bg-amber-100 text-amber-700" },
    done: { label: "Hoàn thành", cls: "bg-tertiary-container/40 text-tertiary" },
  };
  const c = map[variant];
  return (
    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${c.cls}`}>{c.label}</span>
  );
}
