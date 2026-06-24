"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import LanguageToggle from "@/components/app/LanguageToggle";
import Icon from "@/components/Icon";
import Emoji from "@/components/Emoji";

function LoginForm() {
  const router = useRouter();
  const { t } = useLang();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [error, setError] = useState(() =>
    searchParams.get("error") === "oauth"
      ? "Đăng nhập Google thất bại. Thử lại."
      : "",
  );
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);

  useEffect(() => {
    if (searchParams.get("error")) createClient().auth.signOut();
  }, [searchParams]);

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      setError("Email hoặc mật khẩu không đúng");
      setLoading(false);
      return;
    }
    router.push("/role");
    router.refresh();
  }

  async function handleGoogle() {
    setGoogleLoading(true);
    setError("");
    const supabase = createClient();
    // Prefer a configured public site URL so the OAuth redirect is stable and
    // doesn't depend on which (possibly protected) deployment URL is open.
    const siteUrl = process.env.NEXT_PUBLIC_SITE_URL ?? window.location.origin;
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: `${siteUrl}/auth/callback?next=/role` },
    });
    if (error) {
      setError("Không thể kết nối Google. Thử lại.");
      setGoogleLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-6 relative" style={{ background: "var(--surface)" }}>
      <div className="absolute top-4 right-4 z-10">
        <LanguageToggle />
      </div>

      <div className="w-full max-w-sm">
        <div className="text-center mb-7">
          <div className="text-5xl mb-2" style={{ animation: "float 3s ease-in-out infinite" }}>🦉</div>
          <h1 className="text-2xl font-black text-primary">{t("login")}</h1>
          <p className="text-sm font-bold text-on-surface-variant mt-1">{t("loginWelcome")}</p>
        </div>

        <button
          type="button"
          onClick={handleGoogle}
          disabled={googleLoading || loading}
          className="gw-btn gw-btn--ghost mb-4"
        >
          {googleLoading ? (
            <span className="w-4 h-4 border-2 border-on-surface-variant border-t-transparent rounded-full animate-spin" />
          ) : (
            <svg width="18" height="18" viewBox="0 0 18 18">
              <path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.874 2.684-6.615z" fill="#4285F4" />
              <path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18z" fill="#34A853" />
              <path d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332z" fill="#FBBC05" />
              <path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z" fill="#EA4335" />
            </svg>
          )}
          {googleLoading ? "..." : t("loginGoogle")}
        </button>

        <div className="flex items-center gap-3 mb-4">
          <div className="flex-1 h-px bg-outline-variant" />
          <span className="text-xs font-bold text-on-surface-variant">{t("or")}</span>
          <div className="flex-1 h-px bg-outline-variant" />
        </div>

        <form onSubmit={handleLogin} className="space-y-3">
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
          <div className="gw-field">
            <Icon name="lock" />
            <input
              type={showPw ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="gw-input"
              placeholder="••••••••"
            />
            <button
              type="button"
              onClick={() => setShowPw((s) => !s)}
              className="gw-eye"
              aria-label="Hiện mật khẩu"
            >
              <Icon name={showPw ? "visibility_off" : "visibility"} className="text-xl" />
            </button>
          </div>

          <div className="text-right">
            <Link href="/forgot-password" className="text-sm font-bold text-primary hover:underline">
              {t("forgotPassword")}
            </Link>
          </div>

          {error && <p className="text-sm text-error font-semibold">{error}</p>}

          <button type="submit" disabled={loading || googleLoading} className="gw-btn gw-btn--primary">
            {loading ? "..." : t("login")}
          </button>
        </form>

        <p className="text-center text-sm font-bold text-on-surface-variant mt-6">
          {t("noAccount")}{" "}
          <Link href="/register" className="font-extrabold text-primary hover:underline">
            {t("register")}
          </Link>
        </p>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center"><Emoji name="seedling" size={32} /></div>}>
      <LoginForm />
    </Suspense>
  );
}
