"use client";

import { useRef, useState, useEffect } from "react";
import { useLang } from "./LangProvider";
import { track } from "@/lib/analytics";

interface Msg {
  role: "user" | "assistant";
  content: string;
}

export default function ParentAiChat() {
  const { t } = useLang();
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, loading]);

  async function send() {
    const content = input.trim();
    if (!content || loading) return;
    const next = [...messages, { role: "user" as const, content }];
    setMessages(next);
    setInput("");
    setLoading(true);
    track("ai_message_sent", { role: "parent" });
    try {
      const res = await fetch("/api/parent-ai", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ messages: next }),
      });
      const data = await res.json();
      setMessages((m) => [...m, { role: "assistant", content: data.reply ?? data.message ?? "😅" }]);
    } catch {
      setMessages((m) => [...m, { role: "assistant", content: "😅" }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="gw-card" style={{ display: "flex", flexDirection: "column", height: "70vh", padding: 0, overflow: "hidden" }}>
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.length === 0 && (
          <p className="text-on-surface-variant text-sm text-center mt-6">{t("parentAiPlaceholder")}</p>
        )}
        {messages.map((m, i) => (
          <div key={i} className={`flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
            <div
              className="max-w-[80%] rounded-2xl px-3 py-2 text-sm whitespace-pre-wrap"
              style={{
                background: m.role === "user" ? "var(--color-primary-container)" : "var(--color-surface-container)",
                color: m.role === "user" ? "var(--color-on-primary-container)" : "var(--color-on-surface)",
              }}
            >
              {m.content}
            </div>
          </div>
        ))}
        {loading && <p className="text-on-surface-variant text-sm">…</p>}
        <div ref={endRef} />
      </div>
      <div className="flex gap-2 p-3 border-t border-outline-variant">
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") send(); }}
          placeholder={t("parentAiPlaceholder")}
          className="gw-input"
          style={{ paddingLeft: 16, height: 46 }}
        />
        <button onClick={send} disabled={loading} className="gw-btn gw-btn--primary gw-btn--sm" style={{ width: "auto" }}>
          {t("parentAiSend")}
        </button>
      </div>
    </div>
  );
}
