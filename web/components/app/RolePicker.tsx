"use client";

import { useRouter } from "next/navigation";
import { useRef, useState } from "react";
import type { Child } from "@/lib/types";
import ParentPinDialog from "./ParentPinDialog";
import { track } from "@/lib/analytics";
import LanguageToggle from "./LanguageToggle";
import { useLang } from "./LangProvider";
import Icon from "@/components/Icon";

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
    <div className="theme-neutral min-h-screen w-full flex flex-col items-center justify-center px-4 relative" style={{ background: "var(--surface)" }}>
      <div className="absolute top-4 right-4">
        <LanguageToggle />
      </div>
      <div className="text-5xl mb-5" style={{ animation: "float 3s ease-in-out infinite" }}>🦉</div>
      <h1 className="text-2xl font-black text-primary">{t("whoAreYou")}</h1>
      <p className="font-bold text-on-surface-variant mt-2 mb-8">{t("chooseRole")}</p>

      <div className="grid grid-cols-1 gap-4 w-full max-w-sm">
        {/* Parent */}
        <button
          onClick={() => { track("select_role", { role: "parent" }); setShowPin(true); }}
          className="gw-card gw-card--press flex items-center gap-4 text-left relative"
        >
          <span className="absolute top-3 right-3 flex items-center gap-1 text-xs font-extrabold bg-surface-container-high px-2 py-1 rounded-full text-on-surface-variant">
            <Icon name="lock" className="text-sm" /> {t("security")}
          </span>
          <div className="w-16 h-16 rounded-full bg-tertiary-fixed flex items-center justify-center text-3xl shrink-0">
            👨‍👩‍👧
          </div>
          <div>
            <span className="block text-xl font-black text-tertiary">{t("parent")}</span>
            <span className="text-sm font-semibold text-on-surface-variant">{t("parentSub")}</span>
          </div>
        </button>

        {/* Child */}
        <button
          onClick={() => { track("select_role", { role: "child" }); onChildCard(); }}
          className="gw-card gw-card--press flex items-center gap-4 text-left"
        >
          <div className="w-16 h-16 rounded-full bg-primary-fixed flex items-center justify-center text-3xl shrink-0">
            {children.length > 1 ? "👨‍👧‍👦" : "🧒"}
          </div>
          <div>
            <span className="block text-xl font-black text-primary">{t("child")}</span>
            <span className="text-sm font-semibold text-on-surface-variant">
              {children.length > 1 ? `${children.length} ${t("multiChildProfiles")}` : t("childSub")}
            </span>
          </div>
        </button>
      </div>

      {/* Multi-child picker */}
      {pickChild && children.length > 1 && (
        <div className="mt-6 flex flex-wrap gap-3 justify-center">
          {children.map((c) => (
            <button
              key={c.id}
              onClick={() => selectChild(c)}
              className="gw-card gw-card--press flex items-center gap-2 py-3 px-5"
            >
              <span className="text-2xl">{c.avatar_emoji}</span>
              <span className="font-extrabold text-on-surface">{c.name}</span>
              {c.child_pin_hash && (
                <Icon name="lock" className="text-sm text-on-surface-variant" />
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

  const { t } = useLang();
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
          setError(t("wrongPinLockShort"));
          setTimeout(() => { setLocked(false); setError(""); setAttempts(0); }, 10000);
        } else {
          setError(t("wrongPinLeft").replace("{n}", String(3 - next)));
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
      <div className="gw-card" style={{ width: "100%", maxWidth: "320px", padding: "24px" }}>
        <div className="text-center text-4xl mb-2">{child.avatar_emoji}</div>
        <h3 className="text-lg font-bold text-on-surface text-center mb-1">
          {t("childPinOf")} {child.name}
        </h3>
        <p className="text-sm text-on-surface-variant text-center mb-5">
          {t("enterToContinue")}
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
          <button onClick={onCancel} className="gw-btn gw-btn--ghost gw-btn--sm flex-1">
            {t("cancel")}
          </button>
          <button
            onClick={verify}
            disabled={locked || loading || values.join("").length !== 4}
            className="gw-btn gw-btn--primary gw-btn--sm flex-1"
          >
            {loading ? "…" : t("confirm")}
          </button>
        </div>
      </div>
    </div>
  );
}
