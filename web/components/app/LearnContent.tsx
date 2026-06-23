"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import type { Lesson } from "@/lib/types";
import { useLang } from "./LangProvider";

interface Props {
  lessons: Lesson[];
  premium: boolean;
  freeLimit: number;
  completedIds?: string[];
}

type NodeType = "completed" | "current" | "open" | "lock";

// Catmull-Rom -> cubic Bézier smoothing through every point (from the mockups).
function smoothPath(pts: { x: number; y: number }[]): string {
  if (pts.length === 0) return "";
  let d = `M ${pts[0].x} ${pts[0].y}`;
  for (let i = 0; i < pts.length - 1; i++) {
    const p0 = pts[i - 1] || pts[i];
    const p1 = pts[i];
    const p2 = pts[i + 1];
    const p3 = pts[i + 2] || p2;
    const c1x = p1.x + (p2.x - p0.x) / 6;
    const c1y = p1.y + (p2.y - p0.y) / 6;
    const c2x = p2.x - (p3.x - p1.x) / 6;
    const c2y = p2.y - (p3.y - p1.y) / 6;
    d += ` C ${c1x} ${c1y}, ${c2x} ${c2y}, ${p2.x} ${p2.y}`;
  }
  return d;
}

const STEP_Y = 130;
const TOP_Y = 92;
const CENTER_X = 195;
const AMP = 92;

export default function LearnContent({ lessons, premium, freeLimit, completedIds = [] }: Props) {
  const { t } = useLang();
  const router = useRouter();
  const [tab, setTab] = useState<"video" | "story">("video");
  const [selected, setSelected] = useState<number | null>(null);

  const completed = new Set(completedIds);
  const videoCount = lessons.filter((l) => (l.lesson_type ?? "video") === "video").length;
  const storyCount = lessons.filter((l) => l.lesson_type === "story").length;

  // Lessons already come ordered by order_index from getLessons().
  const filtered = lessons.filter((l) => (l.lesson_type ?? "video") === tab);

  const isCompleted = (i: number) => completed.has(filtered[i].id ?? "");
  // Locked = beyond the free limit, OR the previous lesson isn't completed yet
  // (sequential unlock: finish a lesson to open the next one).
  const isLocked = (i: number) => {
    if (!premium && i >= freeLimit) return true;
    if (i === 0) return false;
    return !isCompleted(i - 1);
  };
  const currentIdx = filtered.findIndex((_, i) => !isCompleted(i) && !isLocked(i));
  const nodeType = (i: number): NodeType =>
    isCompleted(i) ? "completed" : isLocked(i) ? "lock" : i === currentIdx ? "current" : "open";

  const doneCount = filtered.filter((_, i) => isCompleted(i)).length;
  const overallPct = filtered.length ? doneCount / filtered.length : 0;

  // Node geometry: gentle zig-zag down a single column, plus a trophy at the end.
  const points = filtered.map((_, i) => ({
    x: Math.round(CENTER_X + AMP * Math.sin(i * 0.9)),
    y: TOP_Y + i * STEP_Y,
  }));
  const trophy = { x: CENTER_X, y: TOP_Y + filtered.length * STEP_Y };
  const height = trophy.y + 80;
  const roadD = smoothPath([...points, trophy]);

  function onNode(i: number) {
    if (isLocked(i)) {
      router.push("/parent/settings");
      return;
    }
    setSelected((cur) => (cur === i ? null : i));
  }

  const sel = selected != null ? filtered[selected] : null;
  const selPoint = selected != null ? points[selected] : null;

  return (
    <div>
      <div className="gw-h" style={{ marginBottom: "12px" }}>
        <h2 style={{ fontSize: "22px", fontWeight: 900, color: "var(--ink)" }}>
          {t("learnTitle")} <span style={{ fontSize: "20px" }}>🦉</span>
        </h2>
      </div>

      {/* Tab switcher */}
      <div
        style={{
          background: "var(--surface-high)",
          borderRadius: "var(--r-pill)",
          padding: "4px",
          display: "flex",
          gap: "4px",
          marginBottom: "14px",
          border: "1.5px solid var(--outline-v)",
        }}
      >
        {([
          { key: "video" as const, label: t("learnVideoTab"), count: videoCount, emoji: "📘" },
          { key: "story" as const, label: t("learnStoryTab"), count: storyCount, emoji: "📖" },
        ]).map((tb) => (
          <button
            key={tb.key}
            onClick={() => {
              setTab(tb.key);
              setSelected(null);
            }}
            style={{
              flex: 1,
              padding: "10px 0",
              borderRadius: "var(--r-pill)",
              border: "none",
              fontSize: "14px",
              fontWeight: 800,
              fontFamily: "inherit",
              cursor: "pointer",
              background:
                tab === tb.key ? (tb.key === "story" ? "var(--tertiary)" : "var(--primary-c)") : "transparent",
              color: tab === tb.key ? (tb.key === "story" ? "#fff" : "var(--on-primary-c)") : "var(--ink-soft)",
            }}
          >
            {tb.emoji} {tb.label} {tb.count > 0 && `(${tb.count})`}
          </button>
        ))}
      </div>

      {/* Section banner */}
      <div
        style={{
          borderRadius: "22px",
          padding: "18px 20px",
          marginBottom: "8px",
          color: "#fff",
          position: "relative",
          overflow: "hidden",
          background:
            tab === "story"
              ? "linear-gradient(135deg,#7E5BD9,#5B3FC0)"
              : "linear-gradient(135deg,#FBA53A,#E07C12)",
        }}
      >
        <span style={{ position: "absolute", right: "-6px", top: "2px", fontSize: "104px", opacity: 0.14, lineHeight: 1 }}>
          🦉
        </span>
        <h3 style={{ fontSize: "20px", fontWeight: 900, marginBottom: "4px" }}>{t("learnBannerTitle")}</h3>
        <p style={{ fontSize: "13px", opacity: 0.92, fontWeight: 600, maxWidth: "78%" }}>{t("learnBannerSub")}</p>
        {filtered.length > 0 && (
          <p style={{ fontSize: "12px", opacity: 0.95, fontWeight: 800, marginTop: "6px" }}>
            {doneCount}/{filtered.length} · {Math.round(overallPct * 100)}%
          </p>
        )}
      </div>

      {/* Path map */}
      {filtered.length === 0 ? (
        <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
          {tab === "story" ? t("learnEmptyStory") : t("learnEmptyVideo")}
        </div>
      ) : (
        <div style={{ position: "relative" }}>
          <svg viewBox={`0 0 390 ${height}`} width="100%" style={{ display: "block", overflow: "visible" }}>
            {/* road */}
            <path d={roadD} fill="none" stroke="#E3DACB" strokeWidth={26} strokeLinecap="round" />
            <path d={roadD} fill="none" stroke="#CDC3B1" strokeWidth={4} strokeLinecap="round" strokeDasharray="1 20" />

            {/* START bubble above the first node */}
            <g transform={`translate(${points[0].x},${points[0].y - 56})`}>
              <rect x={-52} y={-18} width={104} height={36} rx={18} fill="#fff" stroke="#ECE5D9" strokeWidth={2} />
              <path d="M-7,17 0,28 7,17 Z" fill="#fff" />
              <text x={0} y={5} textAnchor="middle" fontSize={14} fontWeight={900} fill="#D9731A">
                {t("lessonStart")}
              </text>
            </g>

            {/* lesson nodes */}
            {points.map((p, i) => {
              const type = nodeType(i);
              const r = 40;
              const topColor = type === "lock" ? "#E4E4E4" : type === "completed" ? "#F7941D" : "#FCE0C2";
              const botColor = type === "lock" ? "#CFCFCF" : type === "completed" ? "#D9731A" : "#E9B988";
              return (
                <g
                  key={filtered[i].id}
                  transform={`translate(${p.x},${p.y})`}
                  style={{ cursor: "pointer" }}
                  onClick={() => onNode(i)}
                >
                  {/* progress ring on the current node = overall progress */}
                  {type === "current" && (() => {
                    const R = r + 7;
                    const C = 2 * Math.PI * R;
                    return (
                      <>
                        <circle r={R} fill="none" stroke="#F1DCC2" strokeWidth={7} />
                        <circle
                          r={R}
                          fill="none"
                          stroke="#F7941D"
                          strokeWidth={7}
                          strokeLinecap="round"
                          strokeDasharray={C}
                          strokeDashoffset={C * (1 - overallPct)}
                          transform="rotate(-90)"
                        />
                      </>
                    );
                  })()}
                  <circle cy={8} r={r} fill={botColor} />
                  <circle r={r} fill={topColor} />
                  {type === "lock" ? (
                    <>
                      <rect x={-12} y={-2} width={24} height={19} rx={4} fill="#9A9A9A" />
                      <path d="M-7.5,-2 v-5 a7.5,7.5 0 0 1 15,0 v5" fill="none" stroke="#9A9A9A" strokeWidth={4} />
                    </>
                  ) : type === "completed" ? (
                    <path d="M-13,1 -4,10 13,-9" fill="none" stroke="#fff" strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" />
                  ) : type === "current" ? (
                    <path d="M-8,-12 13,0 -8,12 Z" fill="#fff" />
                  ) : (
                    <path
                      d="M0,-16 4.7,-5 16.5,-5 6.9,2.6 10.6,14.5 0,7.2 -10.6,14.5 -6.9,2.6 -16.5,-5 -4.7,-5 Z"
                      fill="none"
                      stroke="#D9731A"
                      strokeWidth={3}
                      strokeLinejoin="round"
                    />
                  )}
                </g>
              );
            })}

            {/* trophy goal at the end */}
            <g transform={`translate(${trophy.x},${trophy.y})`}>
              <circle cy={8} r={34} fill="#CBA14B" />
              <circle r={34} fill="#F2C94C" />
              <path d="M-13,-13 h26 v6 a13,8 0 0 1 -26,0 z" fill="#fff" />
              <path d="M-13,-11 h-6 a6,7 0 0 0 7,9" fill="none" stroke="#fff" strokeWidth={3.5} />
              <path d="M13,-11 h6 a6,7 0 0 1 -7,9" fill="none" stroke="#fff" strokeWidth={3.5} />
              <rect x={-4} y={0} width={8} height={7} fill="#fff" />
              <rect x={-11} y={13} width={22} height={5} rx={2} fill="#fff" />
            </g>

            {/* owl mascot beside the current node */}
            {currentIdx >= 0 && points[currentIdx] && (
              <g transform={`translate(${points[currentIdx].x < CENTER_X ? points[currentIdx].x + 70 : points[currentIdx].x - 70},${points[currentIdx].y})`}>
                <circle r={26} fill="#fff" stroke="#ECE5D9" strokeWidth={2} />
                <g transform="translate(0,1) scale(.82)">
                  <ellipse cy={3} rx={16} ry={17} fill="#8A5A24" />
                  <path d="M-14,-10 q-4,-9 4,-7 M14,-10 q4,-9 -4,-7" fill="#8A5A24" />
                  <circle cx={-6} cy={-2} r={7} fill="#fff" />
                  <circle cx={6} cy={-2} r={7} fill="#fff" />
                  <circle cx={-6} cy={-2} r={3} fill="#3A2A16" />
                  <circle cx={6} cy={-2} r={3} fill="#3A2A16" />
                  <path d="M0,3 l-3,4 6,0 Z" fill="#F39314" />
                </g>
              </g>
            )}
          </svg>

          {/* Lesson card popup for the selected node (page2 style) */}
          {sel && selPoint && (
            <div
              style={{
                position: "absolute",
                left: "8%",
                right: "8%",
                top: `${((selPoint.y + 56) / height) * 100}%`,
                background: "#fff",
                border: "2px solid #EFE6DA",
                borderRadius: "18px",
                padding: "14px 16px",
                boxShadow: "0 10px 24px rgba(0,0,0,.12)",
                zIndex: 3,
              }}
            >
              <h3 style={{ fontSize: "17px", fontWeight: 900, color: "var(--ink)" }}>{sel.title}</h3>
              <p style={{ fontSize: "12px", color: "var(--ink-soft)", margin: "6px 0 12px" }}>
                {sel.lesson_type === "story"
                  ? `📖 ${sel.story_pages?.length ?? 0} ${t("pagesUnit")}`
                  : `⏱ ${Math.round((sel.duration_seconds || 0) / 60)} ${t("minutesShort")}`}
              </p>
              <button
                onClick={() => router.push(`/child/learn/${sel.id}`)}
                className="gw-btn gw-btn--primary"
                style={{ width: "100%" }}
              >
                ▶ {t("lessonStart")}
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
