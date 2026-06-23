"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useLang } from "./LangProvider";

interface Msg {
  role: "user" | "assistant";
  content: string;
}

const SUGGESTIONS = ["Tiết kiệm là gì?", "Làm sao có nhiều xu?", "3 hũ tiền để làm gì?"];

export default function WisyChat({ childId, childName }: { childId: string; childName: string }) {
  const { t } = useLang();
  const [messages, setMessages] = useState<Msg[]>([
    { role: "assistant", content: `Chào ${childName}! Tớ là Wisy 🦉. Hỏi tớ bất cứ điều gì nhé!` },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [limited, setLimited] = useState(false);
  const [speakOn, setSpeakOn] = useState(true);
  const endRef = useRef<HTMLDivElement>(null);
  const voicesRef = useRef<SpeechSynthesisVoice[]>([]);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  useEffect(() => {
    if (localStorage.getItem("wisy_tts") === "off") setSpeakOn(false);
    const loadVoices = () => {
      try { voicesRef.current = window.speechSynthesis.getVoices(); } catch { /* noop */ }
    };
    loadVoices();
    window.speechSynthesis.addEventListener?.("voiceschanged", loadVoices);
    return () => {
      window.speechSynthesis.removeEventListener?.("voiceschanged", loadVoices);
      stopSpeak();
    };
  }, []);

  function stopSpeak() {
    try {
      if (audioRef.current) { audioRef.current.pause(); audioRef.current.src = ""; audioRef.current = null; }
      window.speechSynthesis.cancel();
    } catch { /* noop */ }
  }

  function toggleSpeak() {
    setSpeakOn((on) => {
      const next = !on;
      localStorage.setItem("wisy_tts", next ? "on" : "off");
      if (!next) stopSpeak();
      return next;
    });
  }

  async function speak(text: string) {
    const clean = text.replace(/[^\p{L}\p{N}\s.,!?]/gu, "");
    if (!clean) return;
    try {
      const res = await fetch("/api/tts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text: clean }),
      });
      if (res.ok && res.headers.get("content-type")?.includes("audio")) {
        const url = URL.createObjectURL(await res.blob());
        stopSpeak();
        const audio = new Audio(url);
        audioRef.current = audio;
        audio.onended = () => URL.revokeObjectURL(url);
        await audio.play();
        return;
      }
    } catch { /* fall through */ }
    speakBrowser(clean);
  }

  function speakBrowser(clean: string) {
    try {
      const hasVi = /[ăâđêôơưàáạảãằắặẳẵầấậẩẫèéẹẻẽềếệểễìíịỉĩòóọỏõồốộổỗờớợởỡùúụủũừứựửữỳýỵỷỹ]/i.test(clean);
      const u = new SpeechSynthesisUtterance(clean);
      u.lang = hasVi ? "vi-VN" : "en-US";
      const voices = voicesRef.current.length ? voicesRef.current : window.speechSynthesis.getVoices();
      const match = voices.find((v) => v.lang?.toLowerCase().startsWith(hasVi ? "vi" : "en"));
      if (match) u.voice = match;
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
    } catch { /* not supported */ }
  }

  async function send(text: string) {
    const content = text.trim();
    if (!content || loading) return;
    const next = [...messages, { role: "user" as const, content }];
    setMessages(next);
    setInput("");
    setLoading(true);
    try {
      const res = await fetch("/api/ai-chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ childId, messages: next }),
      });
      const data = await res.json();
      if (res.status === 429) {
        setLimited(true);
        setMessages((m) => [...m, { role: "assistant", content: data.message ?? "Hết lượt chat hôm nay 😅" }]);
        return;
      }
      const reply = data.reply ?? data.error ?? t("wisyThinking");
      setMessages((m) => [...m, { role: "assistant", content: reply }]);
      if (speakOn) speak(reply);
    } catch {
      setMessages((m) => [...m, { role: "assistant", content: t("genericError") }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "calc(100vh - 10rem)", maxWidth: "430px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "12px" }}>
        <span style={{ fontSize: "32px" }}>🦉</span>
        <div style={{ flex: 1 }}>
          <p style={{ fontWeight: 900, color: "var(--ink)" }}>Wisy</p>
          <p style={{ fontSize: "12px", color: "var(--ink-soft)" }}>{t("wisyRole")}</p>
        </div>
        <button
          onClick={toggleSpeak}
          aria-label={speakOn ? t("muteVoice") : t("unmuteVoice")}
          className={`gw-btn gw-btn--sm ${speakOn ? "gw-btn--secondary" : "gw-btn--ghost"}`}
          style={{ width: "42px", padding: 0, borderRadius: "50%" }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: "20px" }}>{speakOn ? "volume_up" : "volume_off"}</span>
        </button>
      </div>

      {/* Messages */}
      <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column", gap: "10px", paddingRight: "4px" }}>
        {messages.map((m, i) => (
          <div key={i} style={{ display: "flex", justifyContent: m.role === "user" ? "flex-end" : "flex-start" }}>
            <div
              style={{
                maxWidth: "80%",
                padding: "10px 16px",
                borderRadius: m.role === "user" ? "18px 18px 4px 18px" : "18px 18px 18px 4px",
                fontSize: "14px",
                fontWeight: 600,
                background: m.role === "user" ? "var(--primary-c)" : "var(--white)",
                color: m.role === "user" ? "var(--on-primary-c)" : "var(--ink)",
                border: m.role === "user" ? "none" : "1.5px solid #F0E6D8",
                boxShadow: m.role === "user" ? "none" : "var(--soft)",
              }}
            >
              {m.content}
            </div>
          </div>
        ))}
        {loading && (
          <div style={{ display: "flex", justifyContent: "flex-start" }}>
            <div style={{ padding: "10px 16px", borderRadius: "18px 18px 18px 4px", fontSize: "14px", color: "var(--ink-soft)", background: "var(--white)", border: "1.5px solid #F0E6D8", boxShadow: "var(--soft)" }}>
              {t("wisyThinking")}
            </div>
          </div>
        )}
        <div ref={endRef} />
      </div>

      {/* Suggestion chips */}
      <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", margin: "10px 0" }}>
        {SUGGESTIONS.map((s) => (
          <button
            key={s}
            onClick={() => send(s)}
            disabled={loading}
            className="gw-chip chip-game"
            style={{ cursor: "pointer", border: "none" }}
          >
            {s}
          </button>
        ))}
      </div>

      {/* Limit banner */}
      {limited && (
        <div className="gw-card" style={{ marginBottom: "10px", padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "8px", background: "var(--primary-fixed)" }}>
          <span style={{ fontSize: "13px", color: "var(--on-primary-c)", fontWeight: 700 }}>{t("chatLimit")}</span>
          <Link href="/parent/settings">
            <button className="gw-btn gw-btn--primary gw-btn--sm" style={{ whiteSpace: "nowrap" }}>{t("upgrade")}</button>
          </Link>
        </div>
      )}

      {/* Input */}
      <form
        onSubmit={(e) => { e.preventDefault(); send(input); }}
        style={{ display: "flex", alignItems: "center", gap: "8px" }}
      >
        <div className="gw-field" style={{ flex: 1 }}>
          <span className="material-symbols-outlined">chat</span>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Hỏi Wisy…"
            className="gw-input"
          />
        </div>
        <button
          type="submit"
          disabled={loading}
          className="gw-btn gw-btn--primary gw-btn--sm"
          style={{ width: "48px", padding: 0, borderRadius: "50%", flexShrink: 0 }}
          aria-label="Gửi"
        >
          <span className="material-symbols-outlined">send</span>
        </button>
      </form>
    </div>
  );
}
