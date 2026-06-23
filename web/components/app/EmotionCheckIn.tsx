"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import { useLang } from "./LangProvider";

interface Result {
  emoji: string;
  label: string;
  advice: string;
}

export default function EmotionCheckIn() {
  const { t } = useLang();
  const [open, setOpen] = useState(false);
  const [stage, setStage] = useState<"camera" | "loading" | "result" | "error">("camera");
  const [result, setResult] = useState<Result | null>(null);
  const [errMsg, setErrMsg] = useState("");
  const [limitReached, setLimitReached] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);

  async function start() {
    setOpen(true);
    setStage("camera");
    setResult(null);
    setLimitReached(false);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
    } catch {
      setErrMsg(t("moodCameraDenied"));
      setStage("error");
    }
  }

  function stopCamera() {
    streamRef.current?.getTracks().forEach((t) => t.stop());
    streamRef.current = null;
  }

  function close() {
    stopCamera();
    setOpen(false);
  }

  async function capture() {
    const video = videoRef.current;
    if (!video) return;
    const canvas = document.createElement("canvas");
    canvas.width = video.videoWidth || 480;
    canvas.height = video.videoHeight || 360;
    canvas.getContext("2d")?.drawImage(video, 0, 0, canvas.width, canvas.height);
    const base64 = canvas.toDataURL("image/jpeg", 0.85);
    stopCamera();
    setStage("loading");
    try {
      const res = await fetch("/api/emotion", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ imageBase64: base64 }),
      });
      const data = await res.json();
      if (res.status === 429) {
        setLimitReached(true);
        setErrMsg(data.message ?? t("moodLimitReached"));
        setStage("error");
        return;
      }
      if (!res.ok) {
        setErrMsg(data.error ?? t("moodAnalyzeFailed"));
        setStage("error");
        return;
      }
      setResult(data);
      setStage("result");
    } catch {
      setErrMsg(t("moodConnError"));
      setStage("error");
    }
  }

  return (
    <>
      <div className="gw-card" style={{ padding: "16px", display: "flex", alignItems: "center", gap: "16px", justifyContent: "space-between" }}>
        <div className="text-left min-w-0">
          <p className="font-bold text-on-surface mb-1">{t("moodToday")}</p>
          <p className="text-sm font-semibold text-on-surface mb-1">{t("moodWhyTitle")}</p>
          <ul className="space-y-0.5 text-xs text-on-surface-variant">
            <li>{t("moodWhy1")}</li>
            <li>{t("moodWhy2")}</li>
            <li>{t("moodWhy3")}</li>
          </ul>
        </div>
        <button
          onClick={start}
          className="gw-btn gw-btn--primary gw-btn--sm"
          style={{ flexShrink: 0 }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: "20px" }}>photo_camera</span>
          <span className="hidden sm:inline">{t("checkMood")}</span>
        </button>
      </div>

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="gw-card" style={{ width: "100%", maxWidth: "384px", padding: "24px", textAlign: "center" }}>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-lg font-bold text-on-surface">{t("moodToday")}</h3>
              <button onClick={close} aria-label={t("close")} className="text-on-surface-variant">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            {stage === "camera" && (
              <>
                <video
                  ref={videoRef}
                  className="w-full rounded-2xl bg-black aspect-[4/3] object-cover"
                  muted
                  playsInline
                />
                <p className="text-xs text-on-surface-variant mt-2">
                  {t("moodPhotoNotice")}
                </p>
                <button
                  onClick={capture}
                  className="gw-btn gw-btn--primary"
                  style={{ marginTop: "12px", width: "100%" }}
                >
                  {t("moodCapture")}
                </button>
              </>
            )}

            {stage === "loading" && (
              <div className="py-10">
                <span className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
                <p className="text-on-surface-variant mt-3">{t("moodAnalyzing")}</p>
              </div>
            )}

            {stage === "result" && result && (
              <div className="py-4">
                <div className="text-6xl mb-2">{result.emoji}</div>
                <p className="text-xl font-extrabold text-on-surface">{result.label}</p>
                <p className="text-sm text-on-surface-variant mt-3 bg-surface-container rounded-2xl p-4">
                  {result.advice}
                </p>
                <button
                  onClick={close}
                  className="gw-btn gw-btn--primary"
                  style={{ marginTop: "16px", width: "100%" }}
                >
                  {t("close")}
                </button>
              </div>
            )}

            {stage === "error" && (
              <div className="py-6">
                <p className={limitReached ? "text-on-surface" : "text-error"}>{errMsg}</p>
                {limitReached ? (
                  <Link
                    href="/parent/pricing"
                    onClick={close}
                    className="gw-btn gw-btn--primary"
                    style={{ marginTop: "16px", display: "inline-flex" }}
                  >
                    <span className="material-symbols-outlined" style={{ fontSize: "18px" }}>workspace_premium</span>
                    {t("upgrade")}
                  </Link>
                ) : (
                  <button
                    onClick={start}
                    className="gw-btn gw-btn--primary"
                    style={{ marginTop: "16px" }}
                  >
                    {t("retry")}
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
