"use client";

import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { useLang } from "./LangProvider";
import { useToast } from "./ToastProvider";
import { seedRoadmapForChild } from "@/lib/app/roadmap";

interface ChildLite {
  id: string;
  name: string;
  emoji: string;
}

export default function RoadmapManager({ children }: { children: ChildLite[] }) {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [pending, start] = useTransition();

  if (children.length === 0) return null;

  function seed(childId: string) {
    start(async () => {
      const res = await seedRoadmapForChild(childId);
      if (res.ok) toast(res.seeded ? `${t("createRoadmap")} ✓ (${res.seeded})` : t("roadmapRunning"), "success");
      else toast(res.error ?? t("toastError"), "error");
      router.refresh();
    });
  }

  return (
    <div className="space-y-3 mb-6">
      {children.map((c) => (
        <div key={c.id} className="gw-card" style={{ display: "flex", alignItems: "center", gap: 12, padding: "14px 16px" }}>
          <span style={{ fontSize: 26 }}>{c.emoji}</span>
          <span className="font-extrabold text-on-surface flex-1">{c.name}</span>
          <button
            disabled={pending}
            onClick={() => seed(c.id)}
            className="gw-btn gw-btn--secondary gw-btn--sm"
            style={{ width: "auto" }}
          >
            🧭 {t("createRoadmap")}
          </button>
        </div>
      ))}
    </div>
  );
}
