"use client";

import { useEffect, useState } from "react";

type Mode = "verify" | "create";

export default function ParentPinDialog({
  onSuccess,
  onClose,
  forceCreate = false,
}: {
  onSuccess: () => void;
  onClose: () => void;
  forceCreate?: boolean;
}) {
  const [mode, setMode] = useState<Mode | null>(null); // null = loading
  const [pin, setPin] = useState("");
  const [confirmPin, setConfirmPin] = useState("");
  const [stage, setStage] = useState<"enter" | "confirm">("enter"); // for create
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [attemptsLeft, setAttemptsLeft] = useState(3);
  const [lockedUntil, setLockedUntil] = useState(0);

  // Decide create vs verify based on whether a PIN already exists.
  useEffect(() => {
    if (forceCreate) {
      setMode("create");
      return;
    }
    fetch("/api/parent-pin")
      .then((r) => r.json())
      .then((d) => setMode(d.hasPin ? "verify" : "create"))
      .catch(() => setMode("verify"));
  }, [forceCreate]);

  const active = mode === "create" && stage === "confirm" ? confirmPin : pin;

  function press(digit: string) {
    if (busy || Date.now() < lockedUntil) return;
    setError("");
    if (active.length >= 4) return;
    const next = active + digit;
    if (mode === "create" && stage === "confirm") setConfirmPin(next);
    else setPin(next);
    if (next.length === 4) handleComplete(next);
  }

  function backspace() {
    setError("");
    if (mode === "create" && stage === "confirm") setConfirmPin((p) => p.slice(0, -1));
    else setPin((p) => p.slice(0, -1));
  }

  async function handleComplete(value: string) {
    if (mode === "create") {
      if (stage === "enter") {
        setStage("confirm");
        return;
      }
      // confirm stage
      if (value !== pin) {
        setError("PIN xác nhận không khớp. Thử lại.");
        setPin("");
        setConfirmPin("");
        setStage("enter");
        return;
      }
      setBusy(true);
      const res = await fetch("/api/parent-pin", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ pin: value }),
      });
      setBusy(false);
      if (res.ok) {
        onSuccess();
      } else {
        setError("Không lưu được PIN. Thử lại.");
        setPin("");
        setConfirmPin("");
        setStage("enter");
      }
      return;
    }

    // verify
    setBusy(true);
    const res = await fetch("/api/parent-pin", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pin: value }),
    });
    const data = await res.json().catch(() => ({ ok: false }));
    setBusy(false);
    if (data.ok) {
      onSuccess();
    } else {
      const left = attemptsLeft - 1;
      setAttemptsLeft(left);
      setPin("");
      if (left <= 0) {
        setLockedUntil(Date.now() + 30_000);
        setError("Sai PIN nhiều lần. Khoá 30 giây.");
        setTimeout(() => {
          setAttemptsLeft(3);
          setLockedUntil(0);
          setError("");
        }, 30_000);
      } else {
        setError(`Sai PIN, còn ${left} lần thử.`);
      }
    }
  }

  const title =
    mode === "create"
      ? stage === "enter"
        ? "Tạo mã PIN 4 số"
        : "Xác nhận mã PIN"
      : "Nhập mã PIN phụ huynh";
  const subtitle =
    mode === "create" ? "Đặt mã để bảo vệ chế độ Cha mẹ" : "Để con không tự ý vào";

  const keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="theme-parent app-card w-full max-w-sm p-8 relative">
        <button
          onClick={onClose}
          aria-label="Đóng"
          className="absolute top-4 right-4 text-on-surface-variant hover:text-on-surface"
        >
          <span className="material-symbols-outlined">close</span>
        </button>

        <div className="flex flex-col items-center text-center">
          <div className="text-4xl mb-3">🦉</div>
          <h2 className="text-xl font-extrabold text-primary">{title}</h2>
          <p className="text-sm text-on-surface-variant mt-1">{subtitle}</p>
        </div>

        {/* PIN boxes */}
        <div className="flex justify-center gap-3 my-6">
          {[0, 1, 2, 3].map((i) => {
            const filled = i < active.length;
            return (
              <div
                key={i}
                className={`w-12 h-12 rounded-[14px] border-2 flex items-center justify-center ${
                  filled
                    ? "bg-primary border-primary"
                    : "bg-surface-container-low border-outline-variant"
                }`}
              >
                {filled && <span className="w-2.5 h-2.5 rounded-full bg-on-primary" />}
              </div>
            );
          })}
        </div>

        {error && <p className="text-sm text-error text-center mb-3">{error}</p>}
        {mode === null && (
          <p className="text-sm text-on-surface-variant text-center mb-3">Đang tải…</p>
        )}

        {/* Keypad */}
        <div className="grid grid-cols-3 gap-3">
          {keys.map((k) => (
            <button
              key={k}
              onClick={() => press(k)}
              disabled={busy || Date.now() < lockedUntil}
              className="h-14 rounded-[14px] bg-surface-container-low text-xl font-bold text-on-surface hover:bg-surface-container disabled:opacity-40 transition"
            >
              {k}
            </button>
          ))}
          <div />
          <button
            onClick={() => press("0")}
            disabled={busy || Date.now() < lockedUntil}
            className="h-14 rounded-[14px] bg-surface-container-low text-xl font-bold text-on-surface hover:bg-surface-container disabled:opacity-40 transition"
          >
            0
          </button>
          <button
            onClick={backspace}
            disabled={busy}
            className="h-14 rounded-[14px] flex items-center justify-center text-on-surface-variant hover:bg-surface-container transition"
            aria-label="Xoá"
          >
            <span className="material-symbols-outlined">backspace</span>
          </button>
        </div>

        {mode === "verify" && (
          <button
            onClick={onClose}
            className="block mx-auto mt-5 text-sm font-semibold text-primary hover:underline"
          >
            Quên PIN?
          </button>
        )}
      </div>
    </div>
  );
}
