"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { advanceStage } from "@/lib/app/roadmap";
import Portal from "./Portal";
import Icon from "@/components/Icon";
import type { RoadmapStage } from "@/lib/types";

export default function RoadmapMilestones({
  childId,
  currentStage,
  stages,
}: {
  childId: string;
  currentStage: number;
  stages: RoadmapStage[];
}) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [pending, start] = useTransition();

  if (!stages?.length) return null;

  function next() {
    start(async () => {
      const res = await advanceStage(childId);
      if (res.ok) toast(t("rmStageAdvanced"), "success");
      else toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  return (
    <>
      <button onClick={() => setOpen(true)} className="inline-flex items-center gap-1 text-sm font-extrabold text-primary">
        <Icon name="route" className="text-base" /> {t("rmViewCalendar")}
      </button>

      {open && (
        <Portal>
        <div style={{ position: "fixed", inset: 0, zIndex: 100, background: "rgba(0,0,0,.45)", display: "flex", alignItems: "flex-end", justifyContent: "center" }} onClick={() => setOpen(false)}>
          <div className="gw-card" style={{ width: "100%", maxWidth: 430, borderRadius: "20px 20px 0 0", maxHeight: "85vh", overflowY: "auto", paddingBottom: 24 }} onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-3">
              <b className="text-on-surface">{t("rmMilestonesTitle")}</b>
              <button onClick={() => setOpen(false)} className="text-on-surface-variant font-bold">✕</button>
            </div>

            <div className="space-y-2">
              {stages.map((s) => {
                const done = s.month < currentStage;
                const active = s.month === currentStage;
                return (
                  <div
                    key={s.month}
                    className="gw-card flex items-start gap-3"
                    style={{ padding: "10px 12px", borderColor: active ? "var(--color-primary)" : undefined, opacity: done ? 0.6 : 1 }}
                  >
                    <span
                      className="grid place-items-center shrink-0 font-black"
                      style={{ width: 30, height: 30, borderRadius: "50%", fontSize: 13, background: active ? "var(--color-primary)" : done ? "var(--color-primary-fixed)" : "var(--color-surface-container-high)", color: active ? "#fff" : "var(--color-on-surface)" }}
                    >
                      {s.month}
                    </span>
                    <div className="flex-1 min-w-0">
                      <p className="font-extrabold text-on-surface">{s.theme}</p>
                      <p className="text-xs text-on-surface-variant">{s.goal}</p>
                      {s.milestone && <p className="text-[11px] text-primary font-bold mt-0.5">🏁 {s.milestone}</p>}
                      {s.lesson_category && (
                        <span className="inline-block text-[10px] font-bold mt-1" style={{ background: "var(--color-secondary-container)", color: "var(--color-secondary)", borderRadius: 999, padding: "1px 8px" }}>
                          📘 {t("rmStageLesson")}: {s.lesson_category}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>

            <button onClick={next} disabled={pending || currentStage >= stages.length} className="gw-btn gw-btn--primary mt-4">
              {pending ? "…" : t("rmAdvanceStage")}
            </button>
          </div>
        </div>
        </Portal>
      )}
    </>
  );
}
