"use client";

import { useEffect, useRef, useState } from "react";
import { useLang } from "./LangProvider";

/**
 * In-app camera capture. On devices with a camera the child MUST take a live
 * photo (no album access). If the camera can't be opened (e.g. a desktop with no
 * webcam) we fall back to a file picker so testing/PC use still works.
 */
export default function CameraCapture({
  onCapture,
  onClose,
}: {
  onCapture: (file: File) => void;
  onClose: () => void;
}) {
  const { t } = useLang();
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const [phase, setPhase] = useState<"starting" | "live" | "preview" | "nocamera">("starting");
  const [shot, setShot] = useState<{ url: string; file: File } | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function start() {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "environment" },
          audio: false,
        });
        if (cancelled) {
          stream.getTracks().forEach((tr) => tr.stop());
          return;
        }
        streamRef.current = stream;
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          await videoRef.current.play().catch(() => {});
        }
        setPhase("live");
      } catch {
        if (!cancelled) setPhase("nocamera");
      }
    }
    start();
    return () => {
      cancelled = true;
      streamRef.current?.getTracks().forEach((tr) => tr.stop());
    };
  }, []);

  function stopStream() {
    streamRef.current?.getTracks().forEach((tr) => tr.stop());
    streamRef.current = null;
  }

  function capture() {
    const video = videoRef.current;
    if (!video) return;
    const canvas = document.createElement("canvas");
    canvas.width = video.videoWidth || 720;
    canvas.height = video.videoHeight || 960;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    canvas.toBlob(
      (blob) => {
        if (!blob) return;
        const file = new File([blob], `proof-${Date.now()}.jpg`, { type: "image/jpeg" });
        setShot({ url: URL.createObjectURL(blob), file });
        setPhase("preview");
        stopStream();
      },
      "image/jpeg",
      0.85,
    );
  }

  async function retake() {
    if (shot) URL.revokeObjectURL(shot.url);
    setShot(null);
    setPhase("starting");
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" }, audio: false });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play().catch(() => {});
      }
      setPhase("live");
    } catch {
      setPhase("nocamera");
    }
  }

  function onPickFallback(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) onCapture(file);
  }

  function close() {
    stopStream();
    if (shot) URL.revokeObjectURL(shot.url);
    onClose();
  }

  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 70, background: "rgba(0,0,0,.85)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 16 }}>
      <div style={{ width: "100%", maxWidth: 400, background: "var(--surface)", borderRadius: 20, overflow: "hidden", padding: 16 }}>
        <div className="flex items-center justify-between mb-3">
          <b className="text-on-surface">{t("camTake")}</b>
          <button onClick={close} className="text-on-surface-variant font-bold" aria-label="close">✕</button>
        </div>

        <div style={{ position: "relative", borderRadius: 14, overflow: "hidden", background: "#000", aspectRatio: "3/4" }}>
          {phase === "preview" && shot ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={shot.url} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
          ) : (
            <video ref={videoRef} playsInline muted style={{ width: "100%", height: "100%", objectFit: "cover" }} />
          )}
          {phase === "starting" && (
            <div style={{ position: "absolute", inset: 0, display: "grid", placeItems: "center", color: "#fff" }}>{t("camStarting")}</div>
          )}
        </div>

        {phase === "nocamera" ? (
          <div className="mt-3 text-center">
            <p className="text-sm text-on-surface-variant mb-3">{t("camDenied")}</p>
            <input ref={fileRef} type="file" accept="image/*" onChange={onPickFallback} className="hidden" />
            <button onClick={() => fileRef.current?.click()} className="gw-btn gw-btn--primary">{t("camUpload")}</button>
          </div>
        ) : phase === "preview" ? (
          <div className="mt-3 flex gap-2">
            <button onClick={retake} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>{t("camRetake")}</button>
            <button onClick={() => shot && onCapture(shot.file)} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>{t("camUse")}</button>
          </div>
        ) : (
          <button onClick={capture} disabled={phase !== "live"} className="gw-btn gw-btn--primary mt-3">
            📸 {t("camCapture")}
          </button>
        )}
      </div>
    </div>
  );
}
