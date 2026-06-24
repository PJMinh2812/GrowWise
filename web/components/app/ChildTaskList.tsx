"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { submitTask, collectReward } from "@/lib/app/child-actions";
import type { Task, TaskStatus } from "@/lib/types";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { celebrate } from "@/lib/app/feedback";
import Confetti from "./Confetti";
import CameraCapture from "./CameraCapture";
import Icon from "@/components/Icon";
import Emoji, { type EmojiName } from "@/components/Emoji";

export interface ChildTaskItem {
  task: Task;
  status: TaskStatus | "todo";
  parentNote?: string | null;
  submissionId?: string;
  coinEarned?: number;
  collected?: boolean;
}

export default function ChildTaskList({
  childId,
  items,
}: {
  childId: string;
  items: ChildTaskItem[];
}) {
  const { t } = useLang();
  const rejected = items.filter((i) => i.status === "rejected");
  const todo = items.filter((i) => i.status === "todo");
  const submitted = items.filter((i) => i.status === "submitted");
  const done = items.filter((i) => i.status === "approved");
  const missed = items.filter((i) => i.status === "missed");

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
      {missed.map((i) => (
        <TaskCard key={i.task.id} item={i} childId={childId} variant="missed" />
      ))}
      {items.length === 0 && (
        <div className="gw-card text-center text-on-surface-variant font-semibold py-8">
          {t("taskEmpty")}
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
  variant: "rejected" | "todo" | "submitted" | "done" | "missed";
}) {
  const router = useRouter();
  const { t } = useLang();
  const { toast } = useToast();
  const [uploading, setUploading] = useState(false);
  const [showCamera, setShowCamera] = useState(false);
  const [error, setError] = useState("");
  const [celebrateCoins, setCelebrateCoins] = useState<number | null>(null);
  const [showJar, setShowJar] = useState(false);
  const [pending, start] = useTransition();
  const { task } = item;
  const canCollect = variant === "done" && !item.collected && Boolean(item.submissionId);

  function doCollect(jar: "spend" | "save" | "share") {
    if (!item.submissionId) return;
    start(async () => {
      const res = await collectReward(item.submissionId!, jar);
      setShowJar(false);
      if (!res.ok) {
        toast(res.error ?? t("toastError"), "error");
        return;
      }
      celebrate();
      setCelebrateCoins(res.amount ?? item.coinEarned ?? 0);
      toast(t("collectedToast"), "success");
      setTimeout(() => setCelebrateCoins(null), 1600);
      router.refresh();
    });
  }
  async function handleFile(file: File) {
    setShowCamera(false);
    setError("");
    setUploading(true);
    try {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error(t("sessionExpired"));
      const path = `${user.id}/${task.id}-${Date.now()}.jpg`;
      const { error: upErr } = await supabase.storage
        .from("task-proofs")
        .upload(path, file, { contentType: file.type || "image/jpeg", upsert: true });
      if (upErr) throw upErr;
      const url = supabase.storage.from("task-proofs").getPublicUrl(path).data.publicUrl;
      start(async () => {
        const res = await submitTask({ taskId: task.id, childId, proofUrl: url });
        if (!res.ok) {
          setError(res.error ?? t("toastError"));
          toast(res.error ?? t("toastError"), "error");
          return;
        }
        // Coins are no longer granted instantly — they're credited at day-end
        // (auto tasks) or after a parent approves.
        celebrate();
        toast(t("submitWaitDayEnd"), "success");
        router.refresh();
      });
    } catch (err) {
      const msg = err instanceof Error ? err.message : t("toastError");
      setError(msg);
      toast(msg, "error");
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
    <div className={`gw-card ${variant !== "done" ? "gw-card--press" : ""} mb-3 ${border}`} style={{ position: "relative" }}>
      {celebrateCoins != null && (
        <>
          <Confetti count={28} />
          <span
            className="gw-coinpop"
            style={{ left: "50%", top: "10%", transform: "translateX(-50%)" }}
          >
            +{celebrateCoins} <Emoji name="coin" size={16} />
          </span>
        </>
      )}
      <div className="flex items-center gap-3">
        <span className="grid place-items-center w-12 h-12 rounded-2xl bg-surface-container-high text-2xl shrink-0">
          {task.icon}
        </span>
        <div className="flex-1 min-w-0">
          <p className="font-extrabold text-on-surface truncate">{task.title}</p>
          <span className="inline-flex items-center gap-1 text-sm font-extrabold text-primary mt-0.5">
            <Emoji name="coin" size={16} />+{task.coin_reward} {t("coinUnit")}
          </span>
        </div>
        {actionable ? (
          <button
            disabled={uploading || pending}
            onClick={() => setShowCamera(true)}
            className="gw-btn gw-btn--primary gw-btn--sm"
          >
            {uploading || pending ? "…" : variant === "rejected" ? t("resubmit") : t("submit")}
          </button>
        ) : canCollect ? (
          <button
            disabled={pending}
            onClick={() => setShowJar(true)}
            className="gw-btn gw-btn--secondary gw-btn--sm"
          >
            <Emoji name="coin" size={16} /> {t("collectBtn")}
          </button>
        ) : (
          <StatusChip variant={variant} label={statusLabel(variant, t)} />
        )}
      </div>

      {/* Collect → choose a jar */}
      {showJar && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4" onClick={() => setShowJar(false)}>
          <div className="gw-card" style={{ width: "100%", maxWidth: 360, textAlign: "center" }} onClick={(e) => e.stopPropagation()}>
            <h3 className="font-extrabold text-on-surface" style={{ fontSize: 17 }}>
              {t("collectChooseJar")}
            </h3>
            <p className="text-sm text-on-surface-variant mt-1" style={{ display: "inline-flex", alignItems: "center", gap: 4 }}><Emoji name="coin" size={16} /> +{item.coinEarned ?? 0}</p>
            <div className="grid grid-cols-3 gap-2 mt-4">
              {([
                { jar: "spend" as const, icon: "cart" as EmojiName, label: t("jarSpend") },
                { jar: "save" as const, icon: "bank" as EmojiName, label: t("jarSave") },
                { jar: "share" as const, icon: "gift" as EmojiName, label: t("jarShare") },
              ]).map((j) => (
                <button
                  key={j.jar}
                  disabled={pending}
                  onClick={() => doCollect(j.jar)}
                  className="gw-card gw-card--press"
                  style={{ padding: "14px 6px", display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}
                >
                  <Emoji name={j.icon} size={26} />
                  <span className="text-xs font-extrabold text-on-surface">{j.label}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {variant === "rejected" && item.parentNote && (
        <p className="mt-2 text-sm text-error font-semibold">{t("parentSaid")} {item.parentNote}</p>
      )}

      {actionable && error && <p className="text-sm text-error mt-1">{error}</p>}

      {showCamera && (
        <CameraCapture onCapture={handleFile} onClose={() => setShowCamera(false)} />
      )}
    </div>
  );
}

type TFn = ReturnType<typeof useLang>["t"];

function statusLabel(variant: string, t: TFn): string {
  switch (variant) {
    case "rejected": return t("statusRejected");
    case "todo": return t("statusTodo");
    case "submitted": return t("submitWaitDayEnd");
    case "missed": return t("statusMissed");
    default: return t("statusDone");
  }
}

function StatusChip({ variant, label }: { variant: string; label: string }) {
  const cls: Record<string, string> = {
    rejected: "bg-error/10 text-error",
    todo: "bg-surface-container text-on-surface-variant",
    submitted: "bg-amber-100 text-amber-700",
    done: "bg-tertiary-container/40 text-tertiary",
    missed: "bg-error/10 text-error",
  };
  return (
    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${cls[variant] ?? cls.done}`}>{label}</span>
  );
}
