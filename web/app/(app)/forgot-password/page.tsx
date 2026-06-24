"use client";

import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import LanguageToggle from "@/components/app/LanguageToggle";
import Icon from "@/components/Icon";

export default function ForgotPasswordPage() {
  const { t } = useLang();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    const supabase = createClient();
    // Recovery link lands on /auth/callback, which exchanges the code for a
    // (recovery) session and forwards to /reset-password to set a new password.
    const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? window.location.origin;
    const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), {
      redirectTo: `${siteUrl}/auth/callback?next=/reset-password`,
    });
    if (error) {
      // eslint-disable-next-line no-console
      console.error("[resetPasswordForEmail]", error);
      setError(`${t("forgotError")} (${error.message})`);
      setLoading(false);
      return;
    }
    setSent(true);
    setLoading(false);
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-6 relative" style={{ background: "var(--surface)" }}>
      <div className="absolute top-4 right-4 z-10">
        <LanguageToggle />
      </div>

      <div className="w-full max-w-sm">
        <div className="text-center mb-7">
          <div className="text-5xl mb-2" style={{ animation: "float 3s ease-in-out infinite" }}>🔑</div>
          <h1 className="text-2xl font-black text-primary">{t("forgotTitle")}</h1>
          <p className="text-sm font-bold text-on-surface-variant mt-1">{t("forgotDesc")}</p>
        </div>

        {sent ? (
          <div className="gw-card text-center" style={{ padding: "24px" }}>
            <Icon name="mail" className="text-primary" style={{ fontSize: 40 }} />
            <p className="font-bold text-on-surface mt-2">{t("forgotSent")}</p>
            <Link href="/login" className="gw-btn gw-btn--primary mt-5">
              {t("backToLogin")}
            </Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-3">
            <div className="gw-field">
              <Icon name="mail" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="gw-input"
                placeholder="email@vidu.com"
              />
            </div>

            {error && <p className="text-sm text-error font-semibold">{error}</p>}

            <button type="submit" disabled={loading} className="gw-btn gw-btn--primary">
              {loading ? "..." : t("forgotSend")}
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
