"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import ParentPinDialog from "./ParentPinDialog";
import AddChildDialog from "./AddChildDialog";
import { useLang } from "./LangProvider";

interface ChildInfo {
  id: string;
  name: string;
  emoji: string;
  level: number;
  hasPin: boolean;
}

export default function SettingsView({
  planLabel,
  planName,
  maxChildren,
  children,
}: {
  planLabel: string;
  planName: string;
  maxChildren: number;
  children: ChildInfo[];
}) {
  const { t } = useLang();
  const [pinOpen, setPinOpen] = useState(false);
  const [pinDone, setPinDone] = useState(false);
  const [addOpen, setAddOpen] = useState(false);
  const [pinMenuChild, setPinMenuChild] = useState<ChildInfo | null>(null);
  // "set" | "change" | "delete"
  const [pinMenuMode, setPinMenuMode] = useState<"set" | "change" | "delete">("set");

  const isFree = planName === "free";
  const atMax = children.length >= maxChildren;

  function openPinMenu(child: ChildInfo) {
    setPinMenuChild(child);
    setPinMenuMode(child.hasPin ? "change" : "set");
  }

  return (
    <div className="space-y-5">
      {/* Children */}
      <section className="app-card p-5">
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-bold text-on-surface">{t("manageChildren")}</h2>
          <span className="text-sm text-on-surface-variant">
            {children.length}/{maxChildren} {t("childProfiles")}
          </span>
        </div>
        {children.length === 0 ? (
          <p className="text-sm text-on-surface-variant mb-3">Chưa có hồ sơ con.</p>
        ) : (
          <ul className="space-y-2 mb-3">
            {children.map((c) => (
              <li key={c.id} className="flex items-center gap-3">
                <span className="text-2xl">{c.emoji}</span>
                <span className="flex-1 font-semibold text-on-surface">{c.name}</span>
                <span className="text-sm text-on-surface-variant">Lv.{c.level}</span>
                <button
                  onClick={() => openPinMenu(c)}
                  className="p-1.5 rounded-full hover:bg-surface-container transition-colors"
                  title="Quản lý mã PIN con"
                >
                  <span className={`material-symbols-outlined text-lg ${c.hasPin ? "text-primary" : "text-on-surface-variant"}`}>
                    {c.hasPin ? "lock" : "lock_open"}
                  </span>
                </button>
              </li>
            ))}
          </ul>
        )}

        {atMax ? (
          <div className="text-sm">
            <p className="text-on-surface-variant">{t("maxReached")}.</p>
            {isFree && (
              <Link href="/parent/pricing" className="text-primary font-semibold underline">
                {t("upgradeFamily")} →
              </Link>
            )}
          </div>
        ) : (
          <button
            onClick={() => setAddOpen(true)}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-[14px] bg-primary text-on-primary font-bold text-sm"
          >
            <span className="material-symbols-outlined text-lg">person_add</span>
            {t("addChild")}
          </button>
        )}
      </section>

      {/* Security */}
      <section className="app-card p-5">
        <h2 className="font-bold text-on-surface mb-3">{t("security")}</h2>
        <button
          onClick={() => setPinOpen(true)}
          className="flex items-center gap-2 text-primary font-semibold"
        >
          <span className="material-symbols-outlined">lock_reset</span>
          {t("changePin")}
        </button>
        {pinDone && <p className="text-sm text-green-600 mt-2">Đã cập nhật mã PIN ✓</p>}
      </section>

      {/* Subscription (management only) */}
      <section className="app-card p-5">
        <h2 className="font-bold text-on-surface mb-3">{t("subscription")}</h2>
        <p className="text-on-surface">
          {t("currentPlan")}: <b>{planLabel}</b>
          {!isFree && <span className="text-green-600 font-semibold"> · ✨</span>}
        </p>
        {isFree && (
          <Link
            href="/parent/pricing"
            className="inline-flex items-center gap-2 mt-4 px-5 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
          >
            <span className="material-symbols-outlined text-lg">workspace_premium</span>
            {t("viewPlans")}
          </Link>
        )}
      </section>

      {/* Account */}
      <section className="app-card p-5">
        <h2 className="font-bold text-on-surface mb-3">{t("account")}</h2>
        <Link
          href="/role"
          className="inline-flex items-center gap-2 px-4 py-2 rounded-[14px] bg-primary text-on-primary font-bold text-sm"
        >
          <span className="material-symbols-outlined text-lg">swap_horiz</span>
          {t("switchRole")}
        </Link>
      </section>

      {pinOpen && (
        <ParentPinDialog
          forceCreate
          onSuccess={() => {
            setPinOpen(false);
            setPinDone(true);
          }}
          onClose={() => setPinOpen(false)}
        />
      )}

      {addOpen && <AddChildDialog onClose={() => setAddOpen(false)} />}

      {pinMenuChild && (
        <ChildPinMenu
          child={pinMenuChild}
          mode={pinMenuMode}
          onClose={() => setPinMenuChild(null)}
        />
      )}
    </div>
  );
}

function ChildPinMenu({
  child,
  mode,
  onClose,
}: {
  child: ChildInfo;
  mode: "set" | "change" | "delete";
  onClose: () => void;
}) {
  const ref0 = useRef<HTMLInputElement>(null);
  const ref1 = useRef<HTMLInputElement>(null);
  const ref2 = useRef<HTMLInputElement>(null);
  const ref3 = useRef<HTMLInputElement>(null);
  const refs = [ref0, ref1, ref2, ref3];

  const ref0c = useRef<HTMLInputElement>(null);
  const ref1c = useRef<HTMLInputElement>(null);
  const ref2c = useRef<HTMLInputElement>(null);
  const ref3c = useRef<HTMLInputElement>(null);
  const confirmRefs = [ref0c, ref1c, ref2c, ref3c];

  const [pin, setPin] = useState(["", "", "", ""]);
  const [confirm, setConfirm] = useState(["", "", "", ""]);
  const [step, setStep] = useState<"pin" | "confirm" | "delete">(
    mode === "delete" ? "delete" : "pin"
  );
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function onPinInput(i: number, value: string, isConfirm = false) {
    if (!/^\d?$/.test(value)) return;
    if (isConfirm) {
      const next = [...confirm];
      next[i] = value;
      setConfirm(next);
      if (value && i < 3) confirmRefs[i + 1].current?.focus();
      if (i === 3 && value) setTimeout(submit, 50);
    } else {
      const next = [...pin];
      next[i] = value;
      setPin(next);
      if (value && i < 3) refs[i + 1].current?.focus();
      if (i === 3 && value && mode === "delete") setTimeout(submit, 50);
      if (i === 3 && value && mode !== "delete") {
        setStep("confirm");
        setTimeout(() => ref0c.current?.focus(), 50);
      }
    }
  }

  function onKeyDown(i: number, e: React.KeyboardEvent, isConfirm = false) {
    if (e.key === "Backspace") {
      if (isConfirm && !confirm[i] && i > 0) confirmRefs[i - 1].current?.focus();
      if (!isConfirm && !pin[i] && i > 0) refs[i - 1].current?.focus();
    }
  }

  async function submit() {
    if (loading) return;
    setError("");

    if (mode === "delete") {
      setLoading(true);
      try {
        const res = await fetch("/api/child-pin", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ childId: child.id }),
        });
        if ((await res.json()).ok) {
          window.location.reload();
        } else {
          setError("Không xóa được mã PIN.");
        }
      } finally {
        setLoading(false);
      }
      return;
    }

    const pinStr = pin.join("");
    const confirmStr = confirm.join("");
    if (pinStr.length !== 4) { setStep("pin"); return; }
    if (confirmStr.length !== 4) { setStep("confirm"); return; }
    if (pinStr !== confirmStr) {
      setError("Mã PIN không khớp. Thử lại.");
      setPin(["", "", "", ""]);
      setConfirm(["", "", "", ""]);
      setStep("pin");
      setTimeout(() => ref0.current?.focus(), 50);
      return;
    }

    setLoading(true);
    try {
      const res = await fetch("/api/child-pin", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ childId: child.id, pin: pinStr }),
      });
      if ((await res.json()).ok) {
        window.location.reload();
      } else {
        setError("Không lưu được mã PIN.");
      }
    } finally {
      setLoading(false);
    }
  }

  const pinBoxCls = "w-12 h-14 text-center text-2xl font-extrabold border-2 border-outline-variant rounded-[14px] bg-surface focus:border-primary outline-none disabled:opacity-50";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="app-card w-full max-w-sm p-6">
        <div className="text-center text-3xl mb-2">{child.emoji}</div>
        <h3 className="text-lg font-bold text-on-surface text-center mb-1">
          {mode === "delete" ? "Xóa mã PIN" : mode === "set" ? "Đặt mã PIN" : "Đổi mã PIN"} — {child.name}
        </h3>

        {step === "delete" && (
          <p className="text-sm text-on-surface-variant text-center my-4">
            Bạn có chắc muốn xóa mã PIN? Con sẽ vào thẳng mà không cần PIN.
          </p>
        )}

        {step === "pin" && (
          <>
            <p className="text-sm text-on-surface-variant text-center mb-4">Nhập mã PIN 4 chữ số</p>
            <div className="flex gap-3 justify-center mb-4">
              {([ref0, ref1, ref2, ref3] as const).map((ref, i) => (
                <input key={i} ref={ref} type="password" inputMode="numeric" maxLength={1}
                  value={pin[i]} onChange={(e) => onPinInput(i, e.target.value)}
                  onKeyDown={(e) => onKeyDown(i, e)} autoFocus={i === 0} disabled={loading}
                  className={pinBoxCls} />
              ))}
            </div>
          </>
        )}

        {step === "confirm" && (
          <>
            <p className="text-sm text-on-surface-variant text-center mb-4">Nhập lại để xác nhận</p>
            <div className="flex gap-3 justify-center mb-4">
              {([ref0c, ref1c, ref2c, ref3c] as const).map((ref, i) => (
                <input key={i} ref={ref} type="password" inputMode="numeric" maxLength={1}
                  value={confirm[i]} onChange={(e) => onPinInput(i, e.target.value, true)}
                  onKeyDown={(e) => onKeyDown(i, e, true)} autoFocus={i === 0} disabled={loading}
                  className={pinBoxCls} />
              ))}
            </div>
          </>
        )}

        {error && <p className="text-sm text-error text-center mb-3">{error}</p>}

        <div className="flex gap-2 mt-2">
          <button onClick={onClose}
            className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold">
            Hủy
          </button>
          {step === "delete" ? (
            <button onClick={submit} disabled={loading}
              className="flex-1 py-2.5 rounded-[14px] bg-error text-on-error font-bold disabled:opacity-50">
              {loading ? "…" : "Xóa PIN"}
            </button>
          ) : (
            <button onClick={submit} disabled={loading || (step === "pin" ? pin.join("").length !== 4 : confirm.join("").length !== 4)}
              className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50">
              {loading ? "…" : step === "pin" ? "Tiếp" : "Lưu"}
            </button>
          )}
        </div>

        {child.hasPin && step !== "delete" && (
          <button onClick={() => { setStep("delete"); setPin(["","","",""]); setConfirm(["","","",""]); setError(""); }}
            className="w-full mt-3 text-sm text-error font-semibold text-center">
            Xóa mã PIN hiện tại
          </button>
        )}
      </div>
    </div>
  );
}
