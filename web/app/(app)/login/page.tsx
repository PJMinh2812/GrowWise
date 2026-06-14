"use client";

import { Suspense, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import LanguageToggle from "@/components/app/LanguageToggle";

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
    <div className="min-h-screen grid lg:grid-cols-2 bg-white font-[Plus_Jakarta_Sans] relative">
      <div className="absolute top-4 right-4 z-10">
        <LanguageToggle />
      </div>
      {/* Illustration */}
      <div className="hidden lg:flex flex-col items-center justify-center bg-gradient-to-br from-[#EBF9F1] to-[#FFFDE7] p-12">
        <div className="text-[120px]">🐷</div>
        <h2 className="text-2xl font-extrabold text-[#1A1A2E] mt-4">{t("tagline")}</h2>
      </div>

      {/* Form */}
      <div className="flex items-center justify-center p-6">
        <div className="w-full max-w-sm">
          <div className="text-center mb-8">
            <div className="text-4xl mb-2">🌱</div>
            <h1 className="text-2xl font-extrabold text-[#1A1A2E]">{t("login")}</h1>
            <p className="text-sm text-[#64748B] mt-1">{t("loginWelcome")}</p>
          </div>

          <button
            type="button"
            onClick={handleGoogle}
            disabled={googleLoading || loading}
            className="w-full flex items-center justify-center gap-3 border border-gray-300 rounded-[14px] px-4 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 transition mb-4"
          >
            {googleLoading ? (
              <span className="w-4 h-4 border-2 border-gray-400 border-t-transparent rounded-full animate-spin" />
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
            <div className="flex-1 h-px bg-gray-200" />
            <span className="text-xs text-gray-400">{t("or")}</span>
            <div className="flex-1 h-px bg-gray-200" />
          </div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-[#1A1A2E] mb-1">{t("email")}</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full border border-gray-300 rounded-[14px] px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#3DBE6E] text-black"
                placeholder="email@vidu.com"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[#1A1A2E] mb-1">{t("password")}</label>
              <div className="relative">
                <input
                  type={showPw ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="w-full border border-gray-300 rounded-[14px] px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#3DBE6E] text-black"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPw((s) => !s)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400"
                  aria-label="Hiện mật khẩu"
                >
                  <span className="material-symbols-outlined text-xl">
                    {showPw ? "visibility_off" : "visibility"}
                  </span>
                </button>
              </div>
            </div>

            {error && <p className="text-sm text-red-600">{error}</p>}

            <button
              type="submit"
              disabled={loading || googleLoading}
              className="w-full bg-[#3DBE6E] text-white rounded-[14px] py-2.5 text-sm font-bold hover:brightness-95 disabled:opacity-50 transition"
            >
              {loading ? "..." : t("login")}
            </button>
          </form>

          <p className="text-center text-sm text-[#64748B] mt-6">
            {t("noAccount")}{" "}
            <Link href="/register" className="font-semibold text-[#3DBE6E] hover:underline">
              {t("register")}
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="min-h-screen flex items-center justify-center">🌱</div>}>
      <LoginForm />
    </Suspense>
  );
}
