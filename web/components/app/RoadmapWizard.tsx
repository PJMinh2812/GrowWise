"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { saveRoadmapTasks } from "@/lib/app/roadmap";
import { track } from "@/lib/analytics";
import type { RoadmapTask, RoadmapStageSeed } from "@/lib/app/roadmap-bands";
import Emoji from "@/components/Emoji";

interface ChildLite {
  id: string;
  name: string;
  emoji: string;
  age: number;
}

type Goal = "habit" | "study" | "chores" | "saving" | "sharing";
type PreviewTask = RoadmapTask & { _include: boolean };

export default function RoadmapWizard({ children }: { children: ChildLite[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [childId, setChildId] = useState(children[0]?.id ?? "");
  const [goals, setGoals] = useState<Goal[]>(["habit", "saving"]);
  const [tasksPerDay, setTasksPerDay] = useState(4);
  const [coinLevel, setCoinLevel] = useState<"low" | "medium" | "high">("medium");
  const [schoolSession, setSchoolSession] = useState<"morning" | "afternoon" | "fullday">("morning");
  const [timeBudget, setTimeBudget] = useState<"low" | "medium" | "high">("medium");
  const [knowsSaving, setKnowsSaving] = useState(false);
  const [penalty, setPenalty] = useState(true);
  const [note, setNote] = useState("");
  const [loading, setLoading] = useState(false);
  const [preview, setPreview] = useState<PreviewTask[] | null>(null);
  const [stages, setStages] = useState<RoadmapStageSeed[]>([]);
  const [saving, startSave] = useTransition();

  if (children.length === 0) return null;
  const child = children.find((c) => c.id === childId) ?? children[0];

  const goalLabels: Record<Goal, string> = {
    habit: t("rmGoalHabit"),
    study: t("rmGoalStudy"),
    chores: t("rmGoalChores"),
    saving: t("rmGoalSaving"),
    sharing: t("rmGoalSharing"),
  };

  function toggleGoal(g: Goal) {
    setGoals((cur) => (cur.includes(g) ? cur.filter((x) => x !== g) : [...cur, g]));
  }

  async function generate() {
    setLoading(true);
    setPreview(null);
    try {
      const res = await fetch("/api/roadmap-generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          childId: child.id,
          age: child.age,
          goals: goals.map((g) => goalLabels[g]),
          tasksPerDay,
          coinLevel,
          knowsSaving,
          penalty,
          schoolSession: t(`rm${schoolSession === "morning" ? "Morning" : schoolSession === "afternoon" ? "Afternoon" : "Fullday"}`),
          timeBudget: t(`rm${timeBudget === "low" ? "TimeLow" : timeBudget === "high" ? "TimeHigh" : "TimeMed"}`),
          note,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        toast(data?.message ?? t("toastError"), "error");
        return;
      }
      setStages((data.stages as RoadmapStageSeed[]) ?? []);
      setPreview((data.tasks as RoadmapTask[]).map((tk) => ({ ...tk, _include: true })));
      track("roadmap_generated", { source: "wizard", goals: goals.length, age: child.age });
    } catch {
      toast(t("toastError"), "error");
    } finally {
      setLoading(false);
    }
  }

  function patch(i: number, p: Partial<PreviewTask>) {
    setPreview((cur) => cur?.map((tk, idx) => (idx === i ? { ...tk, ...p } : tk)) ?? null);
  }

  function save() {
    const chosen = (preview ?? []).filter((tk) => tk._include);
    if (!chosen.length) return;
    startSave(async () => {
      const res = await saveRoadmapTasks(child.id, chosen, stages);
      if (res.ok) {
        toast(t("rmSaved"), "success");
        setOpen(false);
        setPreview(null);
        router.refresh();
      } else {
        toast(res.error ?? t("toastError"), "error");
      }
    });
  }

  if (!open) {
    return (
      <button onClick={() => setOpen(true)} className="gw-btn gw-btn--primary mb-4">
        <Emoji name="rocket" size={18} /> {t("rmWizardTitle")}
      </button>
    );
  }

  return (
    <div className="gw-card mb-4" style={{ padding: 16 }}>
      <div className="flex items-center justify-between mb-1">
        <h3 className="font-extrabold text-on-surface" style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
          <Emoji name="rocket" size={20} /> {t("rmWizardTitle")}
        </h3>
        <button onClick={() => { setOpen(false); setPreview(null); }} className="text-on-surface-variant text-sm font-bold">✕</button>
      </div>
      <p className="text-xs text-on-surface-variant mb-4">{t("rmWizardDesc")}</p>

      {!preview ? (
        <div className="space-y-4">
          {/* child */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmSelectChild")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {children.map((c) => (
                <button
                  key={c.id}
                  onClick={() => setChildId(c.id)}
                  className={`gw-chip${c.id === childId ? " active" : ""}`}
                  style={{ display: "inline-flex", alignItems: "center", gap: 6 }}
                >
                  <span>{c.emoji}</span> {c.name} · {c.age}t
                </button>
              ))}
            </div>
          </div>
          {/* goals */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmGoals")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {(Object.keys(goalLabels) as Goal[]).map((g) => (
                <button key={g} onClick={() => toggleGoal(g)} className={`gw-chip${goals.includes(g) ? " active" : ""}`}>
                  {goalLabels[g]}
                </button>
              ))}
            </div>
          </div>
          {/* tasks per day */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmTasksPerDay")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {[3, 4, 5, 6].map((n) => (
                <button key={n} onClick={() => setTasksPerDay(n)} className={`gw-chip${tasksPerDay === n ? " active" : ""}`}>{n}</button>
              ))}
            </div>
          </div>
          {/* coin level */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmCoinLevel")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {(["low", "medium", "high"] as const).map((lv) => (
                <button key={lv} onClick={() => setCoinLevel(lv)} className={`gw-chip${coinLevel === lv ? " active" : ""}`}>
                  {lv === "low" ? t("rmCoinLow") : lv === "high" ? t("rmCoinHigh") : t("rmCoinMedium")}
                </button>
              ))}
            </div>
          </div>
          {/* school session */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmSchoolSession")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {(["morning", "afternoon", "fullday"] as const).map((s) => (
                <button key={s} onClick={() => setSchoolSession(s)} className={`gw-chip${schoolSession === s ? " active" : ""}`}>
                  {s === "morning" ? t("rmMorning") : s === "afternoon" ? t("rmAfternoon") : t("rmFullday")}
                </button>
              ))}
            </div>
          </div>
          {/* time budget */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmTimeBudget")}</label>
            <div className="flex gap-2 mt-1 flex-wrap">
              {(["low", "medium", "high"] as const).map((s) => (
                <button key={s} onClick={() => setTimeBudget(s)} className={`gw-chip${timeBudget === s ? " active" : ""}`}>
                  {s === "low" ? t("rmTimeLow") : s === "high" ? t("rmTimeHigh") : t("rmTimeMed")}
                </button>
              ))}
            </div>
          </div>
          {/* toggles */}
          <Toggle label={t("rmKnowsSaving")} value={knowsSaving} onChange={setKnowsSaving} yes={t("rmYes")} no={t("rmNo")} />
          <Toggle label={t("rmPenalty")} value={penalty} onChange={setPenalty} yes={t("rmYes")} no={t("rmNo")} />
          {/* note */}
          <div>
            <label className="text-sm font-bold text-on-surface">{t("rmNote")}</label>
            <input value={note} onChange={(e) => setNote(e.target.value)} placeholder={t("rmNotePh")} className="gw-input mt-1" style={{ paddingLeft: 14 }} />
          </div>

          <button onClick={generate} disabled={loading || !goals.length} className="gw-btn gw-btn--primary">
            {loading ? t("rmGenerating") : t("rmGenerate")}
          </button>
        </div>
      ) : (
        <div className="space-y-3">
          <p className="text-sm font-bold text-on-surface">{t("rmPreviewTitle")}</p>
          {preview.map((tk, i) => (
            <div key={i} className="gw-card" style={{ padding: 12, opacity: tk._include ? 1 : 0.5 }}>
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={tk._include}
                  onChange={(e) => patch(i, { _include: e.target.checked })}
                  style={{ width: 18, height: 18 }}
                />
                <span style={{ fontSize: 20 }}>{tk.icon}</span>
                {tk.scheduled_time && (
                  <span className="text-xs font-extrabold text-primary shrink-0" style={{ width: 44 }}>{tk.scheduled_time}</span>
                )}
                <input
                  value={tk.title}
                  onChange={(e) => patch(i, { title: e.target.value })}
                  className="gw-input"
                  style={{ paddingLeft: 12, height: 40, flex: 1, minWidth: 0 }}
                />
                <span className="inline-flex items-center gap-1 shrink-0">
                  <Emoji name="coin" size={16} />
                  <input
                    type="number"
                    min={0}
                    value={tk.coin_reward}
                    onChange={(e) => patch(i, { coin_reward: Math.max(0, parseInt(e.target.value) || 0) })}
                    className="gw-input"
                    style={{ paddingLeft: 8, height: 40, width: 64 }}
                  />
                </span>
              </div>
            </div>
          ))}
          <div className="flex gap-2">
            <button onClick={() => setPreview(null)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>
              {t("rmRegenerate")}
            </button>
            <button onClick={save} disabled={saving} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
              {saving ? t("rmSaving") : t("rmSave")}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function Toggle({ label, value, onChange, yes, no }: {
  label: string; value: boolean; onChange: (v: boolean) => void; yes: string; no: string;
}) {
  return (
    <div className="flex items-center justify-between">
      <label className="text-sm font-bold text-on-surface">{label}</label>
      <div className="flex gap-2">
        <button onClick={() => onChange(true)} className={`gw-chip${value ? " active" : ""}`}>{yes}</button>
        <button onClick={() => onChange(false)} className={`gw-chip${!value ? " active" : ""}`}>{no}</button>
      </div>
    </div>
  );
}
