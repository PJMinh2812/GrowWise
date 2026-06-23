"use client";

import { useRef, useState } from "react";
import { useRouter } from "next/navigation";
import SwitchRoleButton from "./SwitchRoleButton";
import LogoutButton from "./LogoutButton";
import LanguageToggle from "./LanguageToggle";
import AvatarUpload from "./AvatarUpload";
import { useLang } from "./LangProvider";
import { updateChildSelfAction } from "@/lib/app/parent-actions";

const EMOJIS = ["👦", "👧", "🧒", "👶", "🐱", "🐶", "🦊", "🐼", "🦄", "🐯"];

export default function ChildSettingsView({
  childId,
  initialName,
  initialEmoji,
  initialAvatarUrl = "",
  hasPin,
}: {
  childId: string;
  initialName: string;
  initialEmoji: string;
  initialAvatarUrl?: string;
  hasPin: boolean;
}) {
  const router = useRouter();
  const { t } = useLang();
  const [profileEditing, setProfileEditing] = useState(false);
  const [name, setName] = useState(initialName);
  const [emoji, setEmoji] = useState(initialEmoji);
  const [avatarUrl, setAvatarUrl] = useState(initialAvatarUrl);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState("");

  async function saveProfile() {
    setSaving(true);
    setSaveError("");
    const res = await updateChildSelfAction({ name, avatarEmoji: emoji, avatarUrl });
    setSaving(false);
    if (res.ok) {
      setProfileEditing(false);
      router.refresh();
    } else {
      setSaveError(res.error ?? t("saveProfileError"));
    }
  }

  return (
    <div className="space-y-5">
      {/* Profile */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-bold text-on-surface">{t("childProfile")}</h2>
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
              pathPrefix="children"
              currentUrl={avatarUrl}
              fallbackEmoji={emoji}
              onUploaded={setAvatarUrl}
              onRemoved={() => setAvatarUrl("")}
            />

            <div className="gw-field" style={{ width: "100%" }}>
              <label style={{ fontSize: "13px", fontWeight: 700, color: "var(--ink-soft)", marginBottom: "4px", display: "block" }}>{t("name")}</label>
              <input className="gw-input" value={name} onChange={e => setName(e.target.value)} placeholder={t("name")} />
            </div>

            <div style={{ width: "100%" }}>
              <p style={{ fontSize: "13px", fontWeight: 700, color: "var(--ink-soft)", marginBottom: "8px" }}>{t("chooseAvatar")}</p>
              <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
                {EMOJIS.map((e) => (
                  <button
                    key={e}
                    onClick={() => setEmoji(e)}
                    style={{
                      width: "48px", height: "48px", borderRadius: "50%", fontSize: "24px",
                      border: `2px solid ${emoji === e ? "var(--primary-c)" : "var(--surface-variant)"}`,
                      background: emoji === e ? "var(--primary-fixed)" : "var(--surface-container)",
                      cursor: "pointer", transition: "all 0.15s",
                    }}
                  >
                    {e}
                  </button>
                ))}
              </div>
            </div>

            {saveError && <p className="text-sm text-error">{saveError}</p>}
            <div style={{ display: "flex", gap: "8px", width: "100%" }}>
              <button onClick={() => setProfileEditing(false)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>{t("cancel")}</button>
              <button onClick={saveProfile} disabled={saving || !name.trim()} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
                {saving ? t("saving") : t("save")}
              </button>
            </div>
          </div>
        ) : (
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <div style={{ width: "52px", height: "52px", borderRadius: "50%", overflow: "hidden", background: "var(--primary-fixed)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "28px", flexShrink: 0 }}>
              {avatarUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={avatarUrl} alt="avatar" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
              ) : (
                emoji
              )}
            </div>
            <div>
              <p className="font-bold text-on-surface">{name}</p>
              <p className="text-sm text-on-surface-variant">{t("childProfileSub")}</p>
            </div>
          </div>
        )}
      </section>

      {/* Change PIN */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{hasPin ? t("changeChildPin") : t("setPin")}</h2>
        <ChildPinChanger childId={childId} hasPin={hasPin} />
      </section>

      {/* Language */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{t("language")}</h2>
        <LanguageToggle />
      </section>

      {/* Account */}
      <section className="gw-card" style={{ padding: "20px" }}>
        <h2 className="font-bold text-on-surface mb-3">{t("account")}</h2>
        <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
          <SwitchRoleButton />
          <LogoutButton />
        </div>
      </section>
    </div>
  );
}

function ChildPinChanger({ childId, hasPin }: { childId: string; hasPin: boolean }) {
  const { t } = useLang();
  const ref0 = useRef<HTMLInputElement>(null);
  const ref1 = useRef<HTMLInputElement>(null);
  const ref2 = useRef<HTMLInputElement>(null);
  const ref3 = useRef<HTMLInputElement>(null);
  const nref0 = useRef<HTMLInputElement>(null);
  const nref1 = useRef<HTMLInputElement>(null);
  const nref2 = useRef<HTMLInputElement>(null);
  const nref3 = useRef<HTMLInputElement>(null);
  const cref0 = useRef<HTMLInputElement>(null);
  const cref1 = useRef<HTMLInputElement>(null);
  const cref2 = useRef<HTMLInputElement>(null);
  const cref3 = useRef<HTMLInputElement>(null);

  const [step, setStep] = useState<"current" | "new" | "confirm" | "done">(hasPin ? "current" : "new");
  const [currentPin, setCurrentPin] = useState(["", "", "", ""]);
  const [newPin, setNewPin] = useState(["", "", "", ""]);
  const [confirmPin, setConfirmPin] = useState(["", "", "", ""]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const currentRefs = [ref0, ref1, ref2, ref3];
  const newRefs = [nref0, nref1, nref2, nref3];
  const confirmRefs = [cref0, cref1, cref2, cref3];

  function makeHandler(
    arr: string[],
    setArr: React.Dispatch<React.SetStateAction<string[]>>,
    refs: typeof currentRefs,
    onComplete?: () => void
  ) {
    return (i: number, value: string) => {
      if (!/^\d?$/.test(value)) return;
      const next = [...arr];
      next[i] = value;
      setArr(next);
      if (value && i < 3) refs[i + 1].current?.focus();
      if (i === 3 && value) onComplete?.();
    };
  }

  function makeKeyDown(arr: string[], refs: typeof currentRefs) {
    return (i: number, e: React.KeyboardEvent) => {
      if (e.key === "Backspace" && !arr[i] && i > 0) refs[i - 1].current?.focus();
    };
  }

  async function submit() {
    const cur = currentPin.join("");
    const nw = newPin.join("");
    const conf = confirmPin.join("");

    if (nw !== conf) {
      setError(t("pinMismatch"));
      setNewPin(["", "", "", ""]);
      setConfirmPin(["", "", "", ""]);
      setStep("new");
      setTimeout(() => nref0.current?.focus(), 50);
      return;
    }

    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/child-pin", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ childId, currentPin: cur, newPin: nw }),
      });
      const data = await res.json();
      if (data.ok) {
        setStep("done");
      } else {
        setError(data.error ?? t("genericError"));
        setCurrentPin(["", "", "", ""]);
        setNewPin(["", "", "", ""]);
        setConfirmPin(["", "", "", ""]);
        setStep(hasPin ? "current" : "new");
        setTimeout(() => (hasPin ? ref0 : nref0).current?.focus(), 50);
      }
    } finally {
      setLoading(false);
    }
  }

  const boxCls = "w-11 h-13 text-center text-xl font-extrabold border-2 border-outline-variant rounded-[12px] bg-surface focus:border-primary outline-none";

  if (step === "done") {
    return <p className="text-sm font-semibold" style={{ color: "var(--secondary)" }}>{t("pinUpdated")}</p>;
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
      {step === "current" && (
        <>
          <p className="text-sm text-on-surface-variant">{t("enterCurrentPin")}</p>
          <div className="flex gap-2">
            {currentRefs.map((ref, i) => (
              <input key={i} ref={ref} type="password" inputMode="numeric" maxLength={1}
                value={currentPin[i]} autoFocus={i === 0}
                onChange={(e) => makeHandler(currentPin, setCurrentPin, currentRefs, () => setStep("new"))(i, e.target.value)}
                onKeyDown={(e) => makeKeyDown(currentPin, currentRefs)(i, e)}
                className={boxCls} />
            ))}
          </div>
        </>
      )}

      {step === "new" && (
        <>
          <p className="text-sm text-on-surface-variant">{t("enterNewPin")}</p>
          <div className="flex gap-2">
            {newRefs.map((ref, i) => (
              <input key={i} ref={ref} type="password" inputMode="numeric" maxLength={1}
                value={newPin[i]} autoFocus={i === 0}
                onChange={(e) => makeHandler(newPin, setNewPin, newRefs, () => setStep("confirm"))(i, e.target.value)}
                onKeyDown={(e) => makeKeyDown(newPin, newRefs)(i, e)}
                className={boxCls} />
            ))}
          </div>
        </>
      )}

      {step === "confirm" && (
        <>
          <p className="text-sm text-on-surface-variant">{t("confirmNewPin")}</p>
          <div className="flex gap-2">
            {confirmRefs.map((ref, i) => (
              <input key={i} ref={ref} type="password" inputMode="numeric" maxLength={1}
                value={confirmPin[i]} autoFocus={i === 0}
                onChange={(e) => makeHandler(confirmPin, setConfirmPin, confirmRefs, submit)(i, e.target.value)}
                onKeyDown={(e) => makeKeyDown(confirmPin, confirmRefs)(i, e)}
                className={boxCls} />
            ))}
          </div>
        </>
      )}

      {error && <p className="text-sm text-error">{error}</p>}

      {step === "confirm" && (
        <button
          onClick={submit}
          disabled={loading || confirmPin.join("").length !== 4}
          className="gw-btn gw-btn--primary gw-btn--sm"
        >
          {loading ? "…" : t("confirm")}
        </button>
      )}
    </div>
  );
}
