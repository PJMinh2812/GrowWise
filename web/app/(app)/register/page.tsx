"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import { useLang } from "@/components/app/LangProvider";
import LanguageToggle from "@/components/app/LanguageToggle";
import Icon from "@/components/Icon";
import Emoji from "@/components/Emoji";

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
    <div className="lg:grid-cols-2" style={{ minHeight: "100vh", display: "grid", background: "var(--cream)", position: "relative" }}>
      <div style={{ position: "absolute", top: "16px", right: "16px", zIndex: 10 }}>
        <LanguageToggle />
      </div>
      <div className="hidden lg:flex" style={{ flexDirection: "column", alignItems: "center", justifyContent: "center", background: "linear-gradient(135deg, var(--primary-fixed) 0%, var(--cream) 100%)", padding: "48px" }}>
        <div><Emoji name="piggy" size={120} /></div>
        <h2 style={{ fontSize: "24px", fontWeight: 900, color: "var(--ink)", marginTop: "16px" }}>{t("tagline")}</h2>
      </div>

      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", padding: "24px" }}>
        <div style={{ width: "100%", maxWidth: "360px" }}>
          <div style={{ textAlign: "center", marginBottom: "32px" }}>
            <div style={{ marginBottom: "8px" }}><Emoji name="seedling" size={40} /></div>
            <h1 style={{ fontSize: "24px", fontWeight: 900, color: "var(--ink)" }}>{t("registerTitle")}</h1>
          </div>

          {info ? (
            <div style={{ textAlign: "center" }}>
              <p style={{ fontSize: "14px", color: "var(--ink)" }}>{info}</p>
              <Link
                href="/login"
                className="gw-btn gw-btn--primary"
                style={{ marginTop: "16px", display: "inline-flex" }}
              >
                Đến trang đăng nhập
              </Link>
            </div>
          ) : (
            <form onSubmit={handleRegister} style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
              <Field label={t("fullName")} value={fullName} onChange={setFullName} placeholder="Nguyễn Văn A" />
              <Field label={t("email")} type="email" value={email} onChange={setEmail} placeholder="email@vidu.com" />
              <Field label={t("password")} type="password" value={password} onChange={setPassword} placeholder="••••••••" />
              <Field label={t("confirmPassword")} type="password" value={confirm} onChange={setConfirm} placeholder="••••••••" />

              <label style={{ display: "flex", alignItems: "flex-start", gap: "8px", fontSize: "14px", color: "var(--ink-soft)" }}>
                <input
                  type="checkbox"
                  checked={agree}
                  onChange={(e) => setAgree(e.target.checked)}
                  className="accent-primary"
                  style={{ marginTop: "2px" }}
                />
                <span>{t("agreeTerms")}</span>
              </label>

              {error && <p style={{ fontSize: "14px", color: "var(--color-error)" }}>{error}</p>}

              <button
                type="submit"
                disabled={loading}
                className="gw-btn gw-btn--primary"
                style={{ width: "100%", marginTop: "4px" }}
              >
                {loading ? "..." : t("register")}
              </button>
            </form>
          )}

          <p style={{ textAlign: "center", fontSize: "14px", color: "var(--ink-soft)", marginTop: "24px" }}>
            {t("haveAccount")}{" "}
            <Link href="/login" style={{ fontWeight: 700, color: "var(--primary-c)" }}>
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
      <label style={{ display: "block", fontSize: "14px", fontWeight: 600, color: "var(--ink)", marginBottom: "4px" }}>{label}</label>
      <div className="gw-field">
        <input
          type={inputType}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          required
          placeholder={placeholder}
          className="gw-input"
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPw((s) => !s)}
            aria-label={showPw ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
            className="gw-eye"
          >
            <Icon name={showPw ? "visibility_off" : "visibility"} style={{ fontSize: "20px" }} />
          </button>
        )}
      </div>
    </div>
  );
}
