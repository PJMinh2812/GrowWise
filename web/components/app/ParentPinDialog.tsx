"use client";

import { useEffect, useState } from "react";
import { useLang } from "./LangProvider";
import Icon from "@/components/Icon";

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
  const { t } = useLang();
  const [mode, setMode] = useState<Mode | null>(null);
  const [pin, setPin] = useState("");
  const [confirmPin, setConfirmPin] = useState("");
  const [stage, setStage] = useState<"enter" | "confirm">("enter");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [attemptsLeft, setAttemptsLeft] = useState(3);
  const [lockedUntil, setLockedUntil] = useState(0);

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
      if (value !== pin) {
        setError(t("pinConfirmMismatch"));
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
        setError(t("savePinFailed"));
        setPin("");
        setConfirmPin("");
        setStage("enter");
      }
      return;
    }

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
        setError(t("wrongPinLocked"));
        setTimeout(() => {
          setAttemptsLeft(3);
          setLockedUntil(0);
          setError("");
        }, 30_000);
      } else {
        setError(t("wrongPinLeft").replace("{n}", String(left)));
      }
    }
  }

  const title =
    mode === "create"
      ? stage === "enter"
        ? t("createPin4")
        : t("confirmPinTitle")
      : t("enterParentPin");
  const subtitle =
    mode === "create" ? t("setPinSub") : t("enterPinSub");

  const keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="theme-parent gw-card" style={{ width: "100%", maxWidth: "384px", padding: "32px", position: "relative" }}>
        <button
          onClick={onClose}
          aria-label={t("close")}
          className="absolute top-4 right-4 text-on-surface-variant hover:text-on-surface"
        >
          <Icon name="close" />
        </button>

        <div className="flex flex-col items-center text-center">
          <div className="text-4xl mb-3">🦉</div>
          <h2 className="text-xl font-extrabold text-primary">{title}</h2>
          <p className="text-sm text-on-surface-variant mt-1">{subtitle}</p>
        </div>

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
          <p className="text-sm text-on-surface-variant text-center mb-3">{t("loading")}</p>
        )}

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
            aria-label={t("back")}
          >
            <Icon name="backspace" />
          </button>
        </div>

        {mode === "verify" && (
          <button
            onClick={onClose}
            className="block mx-auto mt-5 text-sm font-semibold text-primary hover:underline"
          >
            {t("forgotPin")}
          </button>
        )}
      </div>
    </div>
  );
}
