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
          className="inline-flex items-center gap-2 px-4 py-2 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
        >
          <span className="material-symbols-outlined text-xl">download</span>
          {allBusy ? t("creatingImage") : t("downloadAll")}
        </button>
      </div>

      {error && <p className="text-sm text-error mb-3">{error}</p>}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {memories.map((m) => (
          <div key={m.id} className="app-card overflow-hidden flex flex-col">
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
                {new Date(m.created_at).toLocaleDateString("vi-VN")}
              </p>
              <button
                onClick={() => exportOne(m)}
                disabled={busyId === m.id}
                className="mt-3 inline-flex items-center justify-center gap-2 px-4 py-2 rounded-[14px] bg-primary-container/40 text-primary font-bold text-sm disabled:opacity-50"
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
