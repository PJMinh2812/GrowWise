"use client";

import { useEffect, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { saveRoadmapTasks } from "@/lib/app/roadmap";
import Portal from "./Portal";
import type { RoadmapTask } from "@/lib/app/roadmap-bands";

type Row = RoadmapTask & { _on: boolean };

export default function SuggestTasksModal({ childId, onClose }: { childId: string; onClose: () => void }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [rows, setRows] = useState<Row[] | null>(null);
  const [saving, start] = useTransition();

  useEffect(() => {
    fetch("/api/roadmap-suggest", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ childId }),
    })
      .then((r) => r.json())
      .then((d) => setRows(((d.tasks as RoadmapTask[]) ?? []).map((tk, i) => ({ ...tk, _on: i < 2 }))))
      .catch(() => setRows([]));
  }, [childId]);

  const chosen = (rows ?? []).filter((r) => r._on);

  function add() {
    if (!chosen.length) return;
    start(async () => {
      const res = await saveRoadmapTasks(childId, chosen);
      if (res.ok) {
        toast(t("rmSaved"), "success");
        onClose();
        router.refresh();
      } else {
        toast(res.error ?? t("toastError"), "error");
      }
    });
  }

  return (
    <Portal>
    <div style={{ position: "fixed", inset: 0, zIndex: 100, background: "rgba(0,0,0,.45)", display: "flex", alignItems: "flex-end", justifyContent: "center" }} onClick={onClose}>
      <div className="gw-card" style={{ width: "100%", maxWidth: 430, borderRadius: "20px 20px 0 0", maxHeight: "85vh", overflowY: "auto", paddingBottom: 24 }} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-3">
          <b className="text-on-surface">{t("rmSuggestMore")}</b>
          <button onClick={onClose} className="text-on-surface-variant font-bold">✕</button>
        </div>

        {rows === null ? (
          <p className="text-center text-on-surface-variant py-6">…</p>
        ) : rows.length === 0 ? (
          <p className="text-center text-on-surface-variant py-6">{t("rmNoTasks")}</p>
        ) : (
          <div className="space-y-2">
            {rows.map((r, i) => (
              <label key={i} className="gw-card flex items-center gap-3" style={{ padding: "10px 12px", cursor: "pointer" }}>
                <span style={{ fontSize: 22 }}>{r.icon}</span>
                <div className="flex-1 min-w-0">
                  <p className="font-extrabold text-on-surface truncate">{r.title}</p>
                  <p className="text-xs text-on-surface-variant">{r.duration_minutes} {t("rmMinPerDay")}</p>
                </div>
                <input
                  type="checkbox"
                  checked={r._on}
                  onChange={(e) => setRows((cur) => cur?.map((x, idx) => (idx === i ? { ...x, _on: e.target.checked } : x)) ?? null)}
                  style={{ width: 20, height: 20 }}
                />
              </label>
            ))}
          </div>
        )}

        <button onClick={add} disabled={saving || chosen.length === 0} className="gw-btn gw-btn--primary mt-4">
          {saving ? t("rmSaving") : t("rmSuggestAdd").replace("{n}", String(chosen.length))}
        </button>
      </div>
    </div>
    </Portal>
  );
}
