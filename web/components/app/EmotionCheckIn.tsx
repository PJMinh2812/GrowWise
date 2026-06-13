"use client";

import { useRef, useState } from "react";
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
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);

  async function start() {
    setOpen(true);
    setStage("camera");
    setResult(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
    } catch {
      setErrMsg("Không truy cập được camera. Hãy cho phép quyền camera.");
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
      if (!res.ok) {
        setErrMsg(data.error ?? "Phân tích thất bại");
        setStage("error");
        return;
      }
      setResult(data);
      setStage("result");
    } catch {
      setErrMsg("Lỗi kết nối");
      setStage("error");
    }
  }

  return (
    <>
      <button
        onClick={start}
        className="flex items-center gap-1 text-sm font-semibold text-primary"
      >
        <span className="material-symbols-outlined text-xl">photo_camera</span>
        <span className="hidden sm:inline">{t("checkMood")}</span>
      </button>

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="app-card w-full max-w-sm p-6 text-center">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-lg font-bold text-on-surface">Tâm trạng hôm nay 🎭</h3>
              <button onClick={close} aria-label="Đóng" className="text-on-surface-variant">
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
                  Ảnh không được lưu, chỉ dùng để phân tích cảm xúc.
                </p>
                <button
                  onClick={capture}
                  className="mt-3 w-full py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
                >
                  📸 Chụp
                </button>
              </>
            )}

            {stage === "loading" && (
              <div className="py-10">
                <span className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin inline-block" />
                <p className="text-on-surface-variant mt-3">AI đang phân tích…</p>
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
                  className="mt-4 w-full py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
                >
                  Đóng
                </button>
              </div>
            )}

            {stage === "error" && (
              <div className="py-6">
                <p className="text-error">{errMsg}</p>
                <button
                  onClick={start}
                  className="mt-4 px-5 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
                >
                  Thử lại
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
