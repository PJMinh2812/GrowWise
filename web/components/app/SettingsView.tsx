"use client";

import { useRef, useState, useTransition } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import ParentPinDialog from "./ParentPinDialog";
import AddChildDialog from "./AddChildDialog";
import EditChildDialog from "./EditChildDialog";
import SwitchRoleButton from "./SwitchRoleButton";
import LogoutButton from "./LogoutButton";
import AvatarUpload from "./AvatarUpload";
import { useLang } from "./LangProvider";
import { cancelScheduledChange, } from "@/lib/app/subscription-actions";
import { updateParentProfileAction } from "@/lib/app/parent-actions";

interface ChildInfo {
  id: string;
  name: string;
  emoji: string;
  age: number;
  dateOfBirth?: string;
  level: number;
  hasPin: boolean;
}

export default function SettingsView({
  planLabel,
  planName,
  maxChildren,
  periodEnd,
  scheduledPlanLabel,
  parentFullName,
  parentAvatarUrl,
  children,
}: {
  planLabel: string;
  planName: string;
  maxChildren: number;
  periodEnd?: string | null;
  scheduledPlanLabel?: string | null;
  parentFullName: string;
  parentAvatarUrl: string;
  children: ChildInfo[];
}) {
  const { t } = useLang();
  const router = useRouter();
  const [cancelPending, startCancel] = useTransition();
  const [pinOpen, setPinOpen] = useState(false);
  const [pinDone, setPinDone] = useState(false);
  const [addOpen, setAddOpen] = useState(false);
  const [editChild, setEditChild] = useState<ChildInfo | null>(null);
  const [pinMenuChild, setPinMenuChild] = useState<ChildInfo | null>(null);
  const [pinMenuMode, setPinMenuMode] = useState<"set" | "change" | "delete">("set");
  const [profileEditing, setProfileEditing] = useState(false);
  const [profileName, setProfileName] = useState(parentFullName);
  const [profileAvatar, setProfileAvatar] = useState(parentAvatarUrl);
  const [profileSaving, setProfileSaving] = useState(false);
  const [profileError, setProfileError] = useState("");

  const isFree = planName === "free";
  const atMax = children.length >= maxChildren;

  function openPinMenu(child: ChildInfo) {
    setPinMenuChild(child);
    setPinMenuMode(child.hasPin ? "change" : "set");
  }

  async function saveProfile() {
    setProfileSaving(true);
    setProfileError("");
    const res = await updateParentProfileAction({ fullName: profileName, avatarUrl: profileAvatar });
    setProfileSaving(false);
    if (res.ok) {
      setProfileEditing(false);
      router.refresh();
    } else {
      setProfileError(res.error ?? t("saveProfileError"));
    }
  }

  return (
    <div className="space-y-5">
      {/* Parent Profile */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-bold text-on-surface">{t("parentProfile")}</h2>
          {!profileEditing && (
            <button onClick={() => setProfileEditing(true)} className="gw-btn gw-btn--ghost gw-btn--sm">
              <span className="material-symbols-outlined" style={{ fontSize: "16px" }}>edit</span>
              {t("edit")}
            </button>
          )}
        </div>

        {profileEditing ? (
          <div style={{ display: "flex", flexDirection: "column", gap: "16px", alignItems: "center" }}>
            <AvatarUpload
              pathPrefix="parents"
              currentUrl={profileAvatar}
              fallbackEmoji="👨‍👩‍👧"
              onUploaded={setProfileAvatar}
              onRemoved={() => setProfileAvatar("")}
            />
            <div className="gw-field" style={{ width: "100%" }}>
              <label style={{ fontSize: "13px", fontWeight: 700, color: "var(--ink-soft)", marginBottom: "4px", display: "block" }}>{t("displayName")}</label>
              <input className="gw-input" value={profileName} onChange={e => setProfileName(e.target.value)} placeholder={t("displayName")} />
            </div>
            {profileError && <p className="text-sm text-error">{profileError}</p>}
            <div style={{ display: "flex", gap: "8px", width: "100%" }}>
              <button onClick={() => setProfileEditing(false)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>{t("cancel")}</button>
              <button onClick={saveProfile} disabled={profileSaving} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
                {profileSaving ? t("saving") : t("save")}
              </button>
            </div>
          </div>
        ) : (
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            {parentAvatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={parentAvatarUrl} alt="avatar" style={{ width: "48px", height: "48px", borderRadius: "50%", objectFit: "cover" }} />
            ) : (
              <span style={{ width: "48px", height: "48px", borderRadius: "50%", background: "var(--primary-fixed)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "24px" }}>👨‍👩‍👧</span>
            )}
            <div>
              <p className="font-bold text-on-surface">{parentFullName || t("notSet")}</p>
              <p className="text-sm text-on-surface-variant">{t("parentLabel")}</p>
            </div>
          </div>
        )}
      </section>

      {/* Children */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-bold text-on-surface">{t("manageChildren")}</h2>
          <span className="text-sm text-on-surface-variant">
            {children.length}/{maxChildren} {t("childProfiles")}
          </span>
        </div>
        {children.length === 0 ? (
          <p className="text-sm text-on-surface-variant mb-3">{t("noChildrenYet")}</p>
        ) : (
          <ul className="space-y-2 mb-3">
            {children.map((c) => (
              <li key={c.id} className="flex items-center gap-3">
                <span className="text-2xl">{c.emoji}</span>
                <span className="flex-1 font-semibold text-on-surface">
                  {c.name} <span className="text-sm font-normal text-on-surface-variant">· {c.age} {t("yearsOld")}</span>
                </span>
                <span className="text-sm text-on-surface-variant">Lv.{c.level}</span>
                <button
                  onClick={() => setEditChild(c)}
                  className="p-1.5 rounded-full hover:bg-surface-container transition-colors"
                  title={t("edit")}
                >
                  <span className="material-symbols-outlined text-lg text-on-surface-variant">edit</span>
                </button>
                <button
                  onClick={() => openPinMenu(c)}
                  className="p-1.5 rounded-full hover:bg-surface-container transition-colors"
                  title={c.hasPin ? t("changeChildPin") : t("setPin")}
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
            className="gw-btn gw-btn--primary gw-btn--sm"
          >
            <span className="material-symbols-outlined" style={{ fontSize: "18px" }}>person_add</span>
            {t("addChild")}
          </button>
        )}
      </section>

      {/* Security */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{t("security")}</h2>
        <button
          onClick={() => setPinOpen(true)}
          className="flex items-center gap-2 text-primary font-semibold"
        >
          <span className="material-symbols-outlined">lock_reset</span>
          {t("changePin")}
        </button>
        {pinDone && <p className="text-sm text-green-600 mt-2">{t("pinUpdated")}</p>}
      </section>

      {/* Subscription */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{t("subscription")}</h2>
        <p className="text-on-surface">
          {t("currentPlan")}: <b>{planLabel}</b>
          {!isFree && <span className="text-green-600 font-semibold"> · ✨</span>}
        </p>
        {!isFree && periodEnd && (
          <p className="text-sm text-on-surface-variant mt-1">
            {t("periodEnds")} {new Date(periodEnd).toLocaleDateString("vi-VN")}
          </p>
        )}

        {scheduledPlanLabel && (
          <div className="mt-3 p-3 rounded-[14px] bg-amber-50 border border-amber-200 text-sm text-amber-800 flex items-center justify-between gap-2">
            <span>{t("willSwitchTo")} <b>{scheduledPlanLabel}</b> {t("atPeriodEnd")}</span>
            <button
              onClick={() =>
                startCancel(async () => {
                  await cancelScheduledChange();
                  router.refresh();
                })
              }
              disabled={cancelPending}
              className="gw-btn gw-btn--ghost gw-btn--sm"
              style={{ whiteSpace: "nowrap" }}
            >
              {cancelPending ? "…" : t("cancelSchedule")}
            </button>
          </div>
        )}

        <Link
          href="/parent/pricing"
          className="gw-btn gw-btn--primary gw-btn--sm"
          style={{ marginTop: "16px", display: "inline-flex" }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: "18px" }}>workspace_premium</span>
          {isFree ? t("viewPlans") : t("changePlan")}
        </Link>
      </section>

      {/* Account */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{t("account")}</h2>
        <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
          <SwitchRoleButton />
          <LogoutButton />
        </div>
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

      {editChild && (
        <EditChildDialog
          child={{ id: editChild.id, name: editChild.name, dateOfBirth: editChild.dateOfBirth ?? "", emoji: editChild.emoji }}
          onClose={() => setEditChild(null)}
        />
      )}

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
  const { t } = useLang();
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
  const [showPin, setShowPin] = useState(false);

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
          setError(t("deletePinError"));
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
      setError(t("pinMismatch"));
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
        setError(t("savePinError"));
      }
    } finally {
      setLoading(false);
    }
  }

  const pinBoxCls = "w-12 h-14 text-center text-2xl font-extrabold border-2 border-outline-variant rounded-[14px] bg-surface focus:border-primary outline-none disabled:opacity-50";

  const modeLabel =
    mode === "delete" ? t("deletePinTitle") : mode === "set" ? t("setPin") : t("changeChildPin");

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="gw-card" style={{ width: "100%", maxWidth: "384px", padding: "24px" }}>
        <div className="text-center text-3xl mb-2">{child.emoji}</div>
        <h3 className="text-lg font-bold text-on-surface text-center mb-1">
          {modeLabel} — {child.name}
        </h3>

        {step === "delete" && (
          <p className="text-sm text-on-surface-variant text-center my-4">
            {t("deletePinConfirm")}
          </p>
        )}

        {step === "pin" && (
          <>
            <p className="text-sm text-on-surface-variant text-center mb-4">{t("enterPin4")}</p>
            <div className="flex gap-3 justify-center mb-4">
              {([ref0, ref1, ref2, ref3] as const).map((ref, i) => (
                <input key={i} ref={ref} type={showPin ? "text" : "password"} inputMode="numeric" maxLength={1}
                  value={pin[i]} onChange={(e) => onPinInput(i, e.target.value)}
                  onKeyDown={(e) => onKeyDown(i, e)} autoFocus={i === 0} disabled={loading}
                  className={pinBoxCls} />
              ))}
            </div>
            <PinReveal show={showPin} onToggle={() => setShowPin((s) => !s)} />
          </>
        )}

        {step === "confirm" && (
          <>
            <p className="text-sm text-on-surface-variant text-center mb-4">{t("reenterPin")}</p>
            <div className="flex gap-3 justify-center mb-4">
              {([ref0c, ref1c, ref2c, ref3c] as const).map((ref, i) => (
                <input key={i} ref={ref} type={showPin ? "text" : "password"} inputMode="numeric" maxLength={1}
                  value={confirm[i]} onChange={(e) => onPinInput(i, e.target.value, true)}
                  onKeyDown={(e) => onKeyDown(i, e, true)} autoFocus={i === 0} disabled={loading}
                  className={pinBoxCls} />
              ))}
            </div>
            <PinReveal show={showPin} onToggle={() => setShowPin((s) => !s)} />
          </>
        )}

        {error && <p className="text-sm text-error text-center mb-3">{error}</p>}

        <div className="flex gap-2 mt-2">
          <button onClick={onClose}
            className="gw-btn gw-btn--ghost"
            style={{ flex: 1 }}>
            {t("cancel")}
          </button>
          {step === "delete" ? (
            <button onClick={submit} disabled={loading}
              className="gw-btn gw-btn--sm"
              style={{ flex: 1, background: "var(--color-error)", color: "var(--color-on-error)" }}>
              {loading ? "…" : t("deletePinBtn")}
            </button>
          ) : (
            <button onClick={submit} disabled={loading || (step === "pin" ? pin.join("").length !== 4 : confirm.join("").length !== 4)}
              className="gw-btn gw-btn--primary"
              style={{ flex: 1 }}>
              {loading ? "…" : step === "pin" ? t("next") : t("save")}
            </button>
          )}
        </div>

        {child.hasPin && step !== "delete" && (
          <button onClick={() => { setStep("delete"); setPin(["","","",""]); setConfirm(["","","",""]); setError(""); }}
            className="w-full mt-3 text-sm text-error font-semibold text-center">
            {t("deleteCurrentPin")}
          </button>
        )}
      </div>
    </div>
  );
}

function PinReveal({ show, onToggle }: { show: boolean; onToggle: () => void }) {
  const { t } = useLang();
  return (
    <button
      type="button"
      onClick={onToggle}
      className="mx-auto -mt-2 mb-2 flex items-center gap-1 text-xs font-semibold text-on-surface-variant hover:text-on-surface"
    >
      <span className="material-symbols-outlined text-base">
        {show ? "visibility_off" : "visibility"}
      </span>
      {show ? t("hidePin") : t("showPinBtn")}
    </button>
  );
}
