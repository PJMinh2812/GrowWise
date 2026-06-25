"use client";

import { useEffect, useState } from "react";
import { createPortal } from "react-dom";

/**
 * Render children into document.body so overlays escape the .gw-scroll stacking
 * context (which otherwise lets the fixed bottom-nav paint over modal buttons).
 */
export default function Portal({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  if (!mounted) return null;
  return createPortal(children, document.body);
}
