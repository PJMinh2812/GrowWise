"use client";

import { sendGAEvent } from "@next/third-parties/google";

export function track(event: string, params?: Record<string, unknown>) {
  if (typeof window === "undefined") return;
  sendGAEvent("event", event, params ?? {});
}
