"use client";

import { useState } from "react";
import type { Memory } from "@/lib/types";
import { useLang } from "./LangProvider";
import {
  drawPostcard,
  drawAlbum,
  downloadCanvas,
  safeFilename,
  type ChildMap,
} from "@/lib/memory-export";

export default function MemoryGallery({
  memories,
  childMap,
}: {
  memories: Memory[];
  childMap: ChildMap;
}) {
  const { t } = useLang();
  const [busyId, setBusyId] = useState<string | null>(null);
  const [allBusy, setAllBusy] = useState(false);
  const [error, setError] = useState("");

  async function exportOne(m: Memory) {
    setError("");
    setBusyId(m.id);
    try {
      const childName = childMap[m.child_id]?.name;
      const canvas = await drawPostcard(m, childName);
      const date = new Date(m.created_at).toLocaleDateString("vi-VN").replace(/\//g, "-");
      await downloadCanvas(canvas, `ky-niem-${safeFilename(m.task_title)}-${date}.png`);
    } catch {
      setError(t("exportError"));
    } finally {
      setBusyId(null);
    }
  }

  async function exportAll() {
    setError("");
    setAllBusy(true);
    try {
      const canvas = await drawAlbum(memories, childMap);
      const date = new Date().toLocaleDateString("vi-VN").replace(/\//g, "-");
      await downloadCanvas(canvas, `album-ky-niem-${date}.png`);
    } catch {
      setError(t("exportError"));
    } finally {
      setAllBusy(false);
    }
  }

  return (
    <div>
      <div className="flex items-center justify-end mb-4">
        <button
          onClick={exportAll}
          disabled={allBusy}
          className="gw-btn gw-btn--primary gw-btn--sm"
        >
          <span className="material-symbols-outlined text-xl">download</span>
          {allBusy ? t("creatingImage") : t("downloadAll")}
        </button>
      </div>

      {error && <p className="text-sm text-error mb-3">{error}</p>}

      <div className="gw-grid">
        {memories.map((m) => (
          <div key={m.id} className="gw-card" style={{ overflow: "hidden", display: "flex", flexDirection: "column" }}>
            {m.proof_image_url && (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={m.proof_image_url} alt={m.task_title} className="w-full h-40 object-cover" />
            )}
            <div className="p-4 flex-1 flex flex-col">
              <p className="font-bold text-on-surface">
                {m.emoji} {m.task_title}
              </p>
              <p className="text-sm text-on-surface-variant mt-1">{m.note}</p>
              <p className="text-xs text-on-surface-variant mt-2">
                {childMap[m.child_id] ? childMap[m.child_id].name + " · " : ""}
                {new Date(m.created_at).toLocaleString("vi-VN", {
                  day: "2-digit",
                  month: "2-digit",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
              <button
                onClick={() => exportOne(m)}
                disabled={busyId === m.id}
                className="gw-btn gw-btn--secondary gw-btn--sm"
              style={{ marginTop: "12px", width: "100%" }}
              >
                <span className="material-symbols-outlined text-lg">image</span>
                {busyId === m.id ? t("creatingImage") : t("downloadImage")}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
