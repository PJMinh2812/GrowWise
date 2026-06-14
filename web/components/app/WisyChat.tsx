"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";

interface Msg {
  role: "user" | "assistant";
  content: string;
}

const SUGGESTIONS = ["Tiết kiệm là gì?", "Làm sao có nhiều xu?", "3 hũ tiền để làm gì?"];

export default function WisyChat({ childId, childName }: { childId: string; childName: string }) {
  const [messages, setMessages] = useState<Msg[]>([
    { role: "assistant", content: `Chào ${childName}! Tớ là Wisy 🦉. Hỏi tớ bất cứ điều gì nhé!` },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [limited, setLimited] = useState(false);
  const [speakOn, setSpeakOn] = useState(true);
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  // Load saved TTS preference (default on); stop any speech on unmount
  useEffect(() => {
    if (localStorage.getItem("wisy_tts") === "off") setSpeakOn(false);
    return () => {
      try {
        window.speechSynthesis.cancel();
      } catch {
        /* noop */
      }
    };
  }, []);

  function toggleSpeak() {
    setSpeakOn((on) => {
      const next = !on;
      localStorage.setItem("wisy_tts", next ? "on" : "off");
      if (!next) {
        try {
          window.speechSynthesis.cancel();
        } catch {
          /* noop */
        }
      }
      return next;
    });
  }

  function speak(text: string) {
    try {
      const u = new SpeechSynthesisUtterance(text.replace(/[^\p{L}\p{N}\s.,!?]/gu, ""));
      u.lang = "vi-VN";
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(u);
    } catch {
      /* TTS not supported */
    }
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
        setMessages((m) => [
          ...m,
          { role: "assistant", content: data.message ?? "Hết lượt chat hôm nay 😅" },
        ]);
        return;
      }
      const reply = data.reply ?? data.error ?? "Wisy đang bận chút xíu 😅";
      setMessages((m) => [...m, { role: "assistant", content: reply }]);
      if (speakOn) speak(reply);
    } catch {
      setMessages((m) => [...m, { role: "assistant", content: "Lỗi kết nối, thử lại nhé 😅" }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-col h-[calc(100vh-10rem)] max-w-2xl mx-auto">
      <div className="flex items-center gap-2 mb-3">
        <span className="text-3xl">🦉</span>
        <div className="flex-1">
          <p className="font-extrabold text-on-surface">Wisy</p>
          <p className="text-xs text-on-surface-variant">Trợ lý tài chính của bạn</p>
        </div>
        <button
          onClick={toggleSpeak}
          aria-label={speakOn ? "Tắt giọng nói" : "Bật giọng nói"}
          title={speakOn ? "Tắt giọng nói" : "Bật giọng nói"}
          className={`w-10 h-10 rounded-full flex items-center justify-center transition ${
            speakOn ? "bg-primary/10 text-primary" : "bg-surface-container text-on-surface-variant"
          }`}
        >
          <span className="material-symbols-outlined">{speakOn ? "volume_up" : "volume_off"}</span>
        </button>
      </div>

      <div className="flex-1 overflow-y-auto space-y-3 pr-1">
        {messages.map((m, i) => (
          <div
            key={i}
            className={`flex ${m.role === "user" ? "justify-end" : "justify-start"}`}
          >
            <div
              className={`max-w-[80%] px-4 py-2.5 rounded-2xl text-sm ${
                m.role === "user"
                  ? "bg-primary text-on-primary rounded-br-sm"
                  : "app-card text-on-surface rounded-bl-sm"
              }`}
            >
              {m.content}
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="app-card px-4 py-3 rounded-2xl text-on-surface-variant text-sm">
              Wisy đang nghĩ…
            </div>
          </div>
        )}
        <div ref={endRef} />
      </div>

      <div className="flex flex-wrap gap-2 my-2">
        {SUGGESTIONS.map((s) => (
          <button
            key={s}
            onClick={() => send(s)}
            disabled={loading}
            className="text-xs px-3 py-1.5 rounded-full bg-surface-container text-on-surface-variant"
          >
            {s}
          </button>
        ))}
      </div>

      {limited && (
        <div className="mb-2 p-3 rounded-[14px] bg-amber-50 border border-amber-200 text-sm text-amber-800 flex items-center justify-between gap-2">
          <span>Hết lượt hôm nay. Nâng cấp để chat không giới hạn!</span>
          <Link
            href="/parent/settings"
            className="px-3 py-1.5 rounded-full bg-primary text-on-primary font-semibold whitespace-nowrap"
          >
            Nâng cấp
          </Link>
        </div>
      )}

      <form
        onSubmit={(e) => {
          e.preventDefault();
          send(input);
        }}
        className="flex items-center gap-2"
      >
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Hỏi Wisy…"
          className="flex-1 border border-outline-variant rounded-[14px] px-4 py-2.5 text-on-surface"
        />
        <button
          type="submit"
          disabled={loading}
          className="w-11 h-11 rounded-full bg-primary text-on-primary flex items-center justify-center disabled:opacity-50"
          aria-label="Gửi"
        >
          <span className="material-symbols-outlined">send</span>
        </button>
      </form>
    </div>
  );
}
