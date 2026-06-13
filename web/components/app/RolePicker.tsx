"use client";

import { useRouter } from "next/navigation";
import { useRef, useState } from "react";
import type { Child } from "@/lib/types";
import ParentPinDialog from "./ParentPinDialog";
import LanguageToggle from "./LanguageToggle";
import { useLang } from "./LangProvider";

export default function RolePicker({ children }: { children: Child[] }) {
  const router = useRouter();
  const { t } = useLang();
  const [showPin, setShowPin] = useState(false);
  const [pickChild, setPickChild] = useState(false);
  const [pinChild, setPinChild] = useState<Child | null>(null);

  function setChildCookie(childId: string) {
    document.cookie = `gw_child_id=${childId}; path=/; max-age=${60 * 60 * 24 * 30}; samesite=lax`;
    router.push("/child");
  }

  function selectChild(child: Child) {
    setPickChild(false);
    if (child.child_pin_hash) {
      setPinChild(child);
    } else {
      setChildCookie(child.id);
    }
  }

  function onChildCard() {
    if (children.length === 0) {
      router.push("/child");
    } else if (children.length === 1) {
      selectChild(children[0]);
    } else {
      setPickChild(true);
    }
  }

  return (
    <div className="theme-parent min-h-screen w-full flex flex-col items-center justify-center px-4 bg-gradient-to-b from-primary-container/20 to-surface relative">
      <div className="absolute top-4 right-4">
        <LanguageToggle />
      </div>
      <div className="text-4xl mb-6">🦉</div>
      <h1 className="text-3xl font-extrabold text-on-surface">{t("whoAreYou")}</h1>
      <p className="text-on-surface-variant mt-2 mb-10">{t("chooseRole")}</p>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 w-full max-w-2xl">
        {/* Parent */}
        <button
          onClick={() => setShowPin(true)}
          className="app-card p-8 flex flex-col items-center text-center hover:-translate-y-1 transition-transform relative"
        >
          <span className="absolute top-4 right-4 flex items-center gap-1 text-xs font-semibold bg-surface-container px-2 py-1 rounded-full text-on-surface-variant">
            <span className="material-symbols-outlined text-sm">lock</span> {t("security")}
          </span>
          <div className="w-16 h-16 rounded-full bg-primary-container/30 flex items-center justify-center text-3xl mb-4">
            👨‍👩‍👧
          </div>
          <span className="text-2xl font-extrabold text-primary">{t("parent")}</span>
          <span className="text-sm text-on-surface-variant mt-1">{t("parentSub")}</span>
        </button>

        {/* Child */}
        <button
          onClick={onChildCard}
          className="app-card p-8 flex flex-col items-center text-center hover:-translate-y-1 transition-transform"
        >
          <div className="w-16 h-16 rounded-full bg-tertiary-container/40 flex items-center justify-center text-3xl mb-4">
            {children.length > 1 ? "👨‍👧‍👦" : "🧒"}
          </div>
          <span className="text-2xl font-extrabold text-tertiary">{t("child")}</span>
          <span className="text-sm text-on-surface-variant mt-1">
            {children.length > 1 ? `${children.length} hồ sơ` : t("childSub")}
          </span>
        </button>
      </div>

      {/* Multi-child picker */}
      {pickChild && children.length > 1 && (
        <div className="mt-8 flex flex-wrap gap-3 justify-center">
          {children.map((c) => (
            <button
              key={c.id}
              onClick={() => selectChild(c)}
              className="app-card px-5 py-3 flex items-center gap-2 hover:-translate-y-0.5 transition-transform"
            >
              <span className="text-2xl">{c.avatar_emoji}</span>
              <span className="font-bold text-on-surface">{c.name}</span>
              {c.child_pin_hash && (
                <span className="material-symbols-outlined text-sm text-on-surface-variant">lock</span>
              )}
            </button>
          ))}
        </div>
      )}

      {showPin && (
        <ParentPinDialog
          onSuccess={() => router.push("/parent")}
          onClose={() => setShowPin(false)}
        />
      )}

      {pinChild && (
        <ChildPinModal
          child={pinChild}
          onSuccess={() => setChildCookie(pinChild.id)}
          onCancel={() => setPinChild(null)}
        />
      )}
    </div>
  );
}

function ChildPinModal({
  child,
  onSuccess,
  onCancel,
}: {
  child: Child;
  onSuccess: () => void;
  onCancel: () => void;
}) {
  const ref0 = useRef<HTMLInputElement>(null);
  const ref1 = useRef<HTMLInputElement>(null);
  const ref2 = useRef<HTMLInputElement>(null);
  const ref3 = useRef<HTMLInputElement>(null);
  const refs = [ref0, ref1, ref2, ref3];

  const [values, setValues] = useState(["", "", "", ""]);
  const [error, setError] = useState("");
  const [locked, setLocked] = useState(false);
  const [attempts, setAttempts] = useState(0);
  const [loading, setLoading] = useState(false);

  async function verify() {
    if (locked || loading) return;
    const pin = values.join("");
    if (pin.length !== 4) return;
    setLoading(true);
    try {
      const res = await fetch("/api/child-pin", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ childId: child.id, pin }),
      });
      const data = await res.json();
      if (data.ok) {
        onSuccess();
      } else {
        const next = attempts + 1;
        setAttempts(next);
        setValues(["", "", "", ""]);
        setTimeout(() => ref0.current?.focus(), 50);
        if (next >= 3) {
          setLocked(true);
          setError("Sai nhiều lần. Thử lại sau 10 giây.");
          setTimeout(() => { setLocked(false); setError(""); setAttempts(0); }, 10000);
        } else {
          setError(`Mã PIN không đúng. Còn ${3 - next} lần.`);
        }
      }
    } finally {
      setLoading(false);
    }
  }

  function onInput(i: number, value: string) {
    if (!/^\d?$/.test(value)) return;
    const next = [...values];
    next[i] = value;
    setValues(next);
    if (value && i < 3) refs[i + 1].current?.focus();
    if (i === 3 && value) setTimeout(verify, 50);
  }

  function onKeyDown(i: number, e: React.KeyboardEvent) {
    if (e.key === "Backspace" && !values[i] && i > 0) {
      refs[i - 1].current?.focus();
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="app-card w-full max-w-xs p-6">
        <div className="text-center text-4xl mb-2">{child.avatar_emoji}</div>
        <h3 className="text-lg font-bold text-on-surface text-center mb-1">
          Mã PIN của {child.name}
        </h3>
        <p className="text-sm text-on-surface-variant text-center mb-5">
          Nhập 4 chữ số để tiếp tục
        </p>

        <div className="flex gap-3 justify-center mb-4">
          {([ref0, ref1, ref2, ref3] as const).map((ref, i) => (
            <input
              key={i}
              ref={ref}
              type="password"
              inputMode="numeric"
              maxLength={1}
              value={values[i]}
              onChange={(e) => onInput(i, e.target.value)}
              onKeyDown={(e) => onKeyDown(i, e)}
              disabled={locked || loading}
              autoFocus={i === 0}
              className="w-12 h-14 text-center text-2xl font-extrabold border-2 border-outline-variant rounded-[14px] bg-surface focus:border-primary outline-none disabled:opacity-50"
            />
          ))}
        </div>

        {error && <p className="text-sm text-error text-center mb-3">{error}</p>}

        <div className="flex gap-2">
          <button
            onClick={onCancel}
            className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
          >
            Hủy
          </button>
          <button
            onClick={verify}
            disabled={locked || loading || values.join("").length !== 4}
            className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
          >
            {loading ? "…" : "Xác nhận"}
          </button>
        </div>
      </div>
    </div>
  );
}
