"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { saveRoadmapTasks } from "@/lib/app/roadmap";
import type { RoadmapTask, RoadmapStageSeed } from "@/lib/app/roadmap-bands";
import type { TKey } from "@/lib/i18n";

interface ChildLite { id: string; name: string; emoji: string; age: number }

interface Preset {
  key: string;
  titleKey: TKey;
  subKey: TKey;
  emoji: string;
  note: string;
  goals: string[];
  coinLevel: "low" | "medium" | "high";
}

const PRESETS: Preset[] = [
  { key: "age57", titleKey: "presetAge57", subKey: "presetAge57Sub", emoji: "🧒", note: "Tập trung rèn thói quen cơ bản cho bé nhỏ", goals: ["Thói quen tốt"], coinLevel: "low" },
  { key: "age810", titleKey: "presetAge810", subKey: "presetAge810Sub", emoji: "👦", note: "Nhấn mạnh học tập và kỷ luật", goals: ["Học tập", "Việc nhà"], coinLevel: "medium" },
  { key: "indep", titleKey: "presetIndep", subKey: "presetIndepSub", emoji: "💪", note: "Tăng tính tự giác và trách nhiệm", goals: ["Việc nhà", "Tiết kiệm"], coinLevel: "medium" },
  { key: "study", titleKey: "presetStudy", subKey: "presetStudySub", emoji: "📖", note: "Tập trung học tập hiệu quả", goals: ["Học tập"], coinLevel: "high" },
  { key: "screen", titleKey: "presetScreen", subKey: "presetScreenSub", emoji: "📵", note: "Giảm thời gian màn hình, thay bằng hoạt động lành mạnh", goals: ["Sức khỏe", "Thói quen tốt"], coinLevel: "medium" },
  { key: "discipline", titleKey: "presetDiscipline", subKey: "presetDisciplineSub", emoji: "❤️", note: "Kỷ luật tích cực, khen thưởng hợp lý", goals: ["Thói quen tốt", "Chia sẻ"], coinLevel: "medium" },
];

export default function RoadmapPresets({ children }: { children: ChildLite[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [childId, setChildId] = useState(children[0]?.id ?? "");
  const [busy, setBusy] = useState<string | null>(null);
  const [, start] = useTransition();

  if (children.length === 0) return null;
  const child = children.find((c) => c.id === childId) ?? children[0];

  async function apply(p: Preset) {
    setBusy(p.key);
    try {
      const res = await fetch("/api/roadmap-generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          childId: child.id,
          age: child.age,
          goals: p.goals,
          tasksPerDay: 4,
          coinLevel: p.coinLevel,
          knowsSaving: false,
          penalty: true,
          schoolSession: "Sáng",
          timeBudget: "Vừa",
          note: p.note,
        }),
      });
      const data = await res.json();
      if (!res.ok) { toast(data?.message ?? t("toastError"), "error"); return; }
      start(async () => {
        const save = await saveRoadmapTasks(child.id, data.tasks as RoadmapTask[], data.stages as RoadmapStageSeed[]);
        if (save.ok) { toast(t("rmSaved"), "success"); router.refresh(); }
        else toast(save.error ?? t("toastError"), "error");
      });
    } catch {
      toast(t("toastError"), "error");
    } finally {
      setBusy(null);
    }
  }

  return (
    <div className="mb-6">
      <h2 className="font-extrabold text-on-surface mb-2">{t("rmQuickPresets")}</h2>
      {children.length > 1 && (
        <div className="flex gap-2 mb-3 flex-wrap">
          {children.map((c) => (
            <button key={c.id} onClick={() => setChildId(c.id)} className={`gw-chip${c.id === childId ? " active" : ""}`} style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
              <span>{c.emoji}</span> {c.name}
            </button>
          ))}
        </div>
      )}
      <div className="grid grid-cols-2 gap-3">
        {PRESETS.map((p) => (
          <button
            key={p.key}
            onClick={() => apply(p)}
            disabled={busy !== null}
            className="gw-card gw-card--press text-left"
            style={{ padding: "12px 14px", display: "flex", flexDirection: "column", gap: 2, opacity: busy && busy !== p.key ? 0.5 : 1 }}
          >
            <span style={{ fontSize: 22 }}>{p.emoji}</span>
            <span className="font-extrabold text-on-surface" style={{ fontSize: 14 }}>{busy === p.key ? t("rmGenerating") : t(p.titleKey)}</span>
            <span className="text-xs text-on-surface-variant">{t(p.subKey)}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
