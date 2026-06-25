"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import { useToast } from "@/components/app/ToastProvider";
import LanguageToggle from "@/components/app/LanguageToggle";
import Icon from "@/components/Icon";

export default function ResetPasswordPage() {
  const { t } = useLang();
  const { toast } = useToast();
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  // null = checking, true/false = whether a (recovery) session is present.
  const [hasSession, setHasSession] = useState<boolean | null>(null);

  useEffect(() => {
    // The /auth/callback handler already exchanged the recovery code for a
    // session before redirecting here. If there's no session, the link is
    // missing/expired and we can't update the password.
    const supabase = createClient();
    supabase.auth.getSession().then(({ data }) => {
      setHasSession(Boolean(data.session));
    });
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (password.length < 6) {
      setError(t("passwordTooShort"));
      return;
    }
    if (password !== confirm) {
      setError(t("resetMismatch"));
      return;
    }
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.updateUser({ password });
    if (error) {
      setError(t("resetError"));
      setLoading(false);
      return;
    }
    toast(t("resetSuccess"), "success");
    router.push("/role");
    router.refresh();
  }

  return (
    <div className="theme-neutral min-h-screen flex items-center justify-center p-6 relative" style={{ background: "var(--surface)" }}>
      <div className="absolute top-4 right-4 z-10">
        <LanguageToggle />
      </div>

      <div className="w-full max-w-sm">
        <div className="text-center mb-7">
          <div className="text-5xl mb-2" style={{ animation: "float 3s ease-in-out infinite" }}>🔐</div>
          <h1 className="text-2xl font-black text-primary">{t("resetTitle")}</h1>
          <p className="text-sm font-bold text-on-surface-variant mt-1">{t("resetDesc")}</p>
        </div>

        {hasSession === false ? (
          <div className="gw-card text-center" style={{ padding: "24px" }}>
            <p className="font-bold text-error">{t("resetInvalidLink")}</p>
            <Link href="/forgot-password" className="gw-btn gw-btn--primary mt-5">
              {t("forgotTitle")}
            </Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-3">
            <div className="gw-field">
              <Icon name="lock" />
              <input
                type={showPw ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="gw-input"
                placeholder={t("newPassword")}
              />
              <button
                type="button"
                onClick={() => setShowPw((s) => !s)}
                className="gw-eye"
                aria-label={t("newPassword")}
              >
                <Icon name={showPw ? "visibility_off" : "visibility"} className="text-xl" />
              </button>
            </div>
            <div className="gw-field">
              <Icon name="lock" />
              <input
                type={showPw ? "text" : "password"}
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
                required
                className="gw-input"
                placeholder={t("confirmPassword")}
              />
            </div>

            {error && <p className="text-sm text-error font-semibold">{error}</p>}

            <button type="submit" disabled={loading || hasSession === null} className="gw-btn gw-btn--primary">
              {loading ? "..." : t("resetSubmit")}
            </button>
          </form>
        )}

        <p className="text-center text-sm font-bold text-on-surface-variant mt-6">
          <Link href="/login" className="font-extrabold text-primary hover:underline">
            {t("backToLogin")}
          </Link>
        </p>
      </div>
    </div>
  );
}
