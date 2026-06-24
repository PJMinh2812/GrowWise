"use client";

import { createContext, useCallback, useContext, useRef, useState } from "react";
import Emoji, { type EmojiName } from "@/components/Emoji";

type ToastType = "success" | "error" | "info";
interface ToastItem {
  id: number;
  msg: string;
  type: ToastType;
}

interface ToastCtx {
  toast: (msg: string, type?: ToastType) => void;
}

const Ctx = createContext<ToastCtx>({ toast: () => {} });

export function useToast() {
  return useContext(Ctx);
}

const ICON: Record<ToastType, EmojiName> = { success: "check", error: "warning", info: "bulb" };

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);
  const nextId = useRef(1);

  const toast = useCallback((msg: string, type: ToastType = "success") => {
    const id = nextId.current++;
    setItems((cur) => [...cur, { id, msg, type }]);
    setTimeout(() => {
      setItems((cur) => cur.filter((t) => t.id !== id));
    }, 3200);
  }, []);

  return (
    <Ctx.Provider value={{ toast }}>
      {children}
      <div className="gw-toast-wrap" aria-live="polite">
        {items.map((t) => (
          <div key={t.id} className={`gw-toast gw-toast--${t.type}`} role="status">
            <span className="gw-toast__ico" aria-hidden><Emoji name={ICON[t.type]} size={20} /></span>
            <span>{t.msg}</span>
          </div>
        ))}
      </div>
    </Ctx.Provider>
  );
}
