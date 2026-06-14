"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import LanguageToggle from "@/components/app/LanguageToggle";

export default function RegisterPage() {
  const router = useRouter();
  const { t } = useLang();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [agree, setAgree] = useState(false);
  const [error, setError] = useState("");
  const [info, setInfo] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleRegister(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (password.length < 6) return setError("Mật khẩu tối thiểu 6 ký tự.");
    if (password !== confirm) return setError("Mật khẩu xác nhận không khớp.");
    if (!agree) return setError("Vui lòng đồng ý với Điều khoản & Chính sách.");

    setLoading(true);
    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    if (error) {
      setError(error.message);
      setLoading(false);
      return;
    }
    if (data.session) {
      router.push("/role");
      router.refresh();
    } else {
      setInfo("Đã gửi email xác nhận. Vui lòng kiểm tra hộp thư rồi đăng nhập.");
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-white font-[Plus_Jakarta_Sans] relative">
      <div className="absolute top-4 right-4 z-10">
        <LanguageToggle />
      </div>
      <div className="hidden lg:flex flex-col items-center justify-center bg-gradient-to-br from-[#EBF9F1] to-[#FFFDE7] p-12">
        <div className="text-[120px]">🐷</div>
        <h2 className="text-2xl font-extrabold text-[#1A1A2E] mt-4">{t("tagline")}</h2>
      </div>

      <div className="flex items-center justify-center p-6">
        <div className="w-full max-w-sm">
          <div className="text-center mb-8">
            <div className="text-4xl mb-2">🌱</div>
            <h1 className="text-2xl font-extrabold text-[#1A1A2E]">{t("registerTitle")}</h1>
          </div>

          {info ? (
            <div className="text-center">
              <p className="text-sm text-[#1A1A2E]">{info}</p>
              <Link
                href="/login"
                className="inline-block mt-4 bg-[#3DBE6E] text-white rounded-[14px] px-6 py-2.5 text-sm font-bold"
              >
                Đến trang đăng nhập
              </Link>
            </div>
          ) : (
            <form onSubmit={handleRegister} className="space-y-3">
              <Field label={t("fullName")} value={fullName} onChange={setFullName} placeholder="Nguyễn Văn A" />
              <Field label={t("email")} type="email" value={email} onChange={setEmail} placeholder="email@vidu.com" />
              <Field label={t("password")} type="password" value={password} onChange={setPassword} placeholder="••••••••" />
              <Field label={t("confirmPassword")} type="password" value={confirm} onChange={setConfirm} placeholder="••••••••" />

              <label className="flex items-start gap-2 text-sm text-[#64748B]">
                <input
                  type="checkbox"
                  checked={agree}
                  onChange={(e) => setAgree(e.target.checked)}
                  className="mt-1 accent-[#3DBE6E]"
                />
                <span>{t("agreeTerms")}</span>
              </label>

              {error && <p className="text-sm text-red-600">{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-[#3DBE6E] text-white rounded-[14px] py-2.5 text-sm font-bold hover:brightness-95 disabled:opacity-50 transition"
              >
                {loading ? "..." : t("register")}
              </button>
            </form>
          )}

          <p className="text-center text-sm text-[#64748B] mt-6">
            {t("haveAccount")}{" "}
            <Link href="/login" className="font-semibold text-[#3DBE6E] hover:underline">
              {t("login")}
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  type = "text",
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
  placeholder?: string;
}) {
  const [showPw, setShowPw] = useState(false);
  const isPassword = type === "password";
  const inputType = isPassword && showPw ? "text" : type;
  return (
    <div>
      <label className="block text-sm font-semibold text-[#1A1A2E] mb-1">{label}</label>
      <div className="relative">
        <input
          type={inputType}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          required
          placeholder={placeholder}
          className={`w-full border border-gray-300 rounded-[14px] px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#3DBE6E] text-black ${
            isPassword ? "pr-11" : ""
          }`}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPw((s) => !s)}
            aria-label={showPw ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <span className="material-symbols-outlined text-xl">
              {showPw ? "visibility_off" : "visibility"}
            </span>
          </button>
        )}
      </div>
    </div>
  );
}
