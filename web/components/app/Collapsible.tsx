"use client";

import { useState } from "react";
import Icon from "@/components/Icon";

/** A section that stays collapsed until tapped — keeps the roadmap page tidy. */
export default function Collapsible({
  title,
  icon = "add",
  defaultOpen = false,
  children,
}: {
  title: string;
  icon?: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="mb-4">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="gw-card gw-card--press"
        style={{ width: "100%", display: "flex", alignItems: "center", gap: 10, padding: "14px 16px" }}
      >
        <Icon name={icon} className="text-primary text-xl" />
        <span className="font-extrabold text-on-surface flex-1 text-left">{title}</span>
        <Icon
          name="chevron_right"
          className="text-on-surface-variant"
          style={{ transform: open ? "rotate(90deg)" : "none", transition: "transform .15s" }}
        />
      </button>
      {open && <div className="mt-3 gw-page">{children}</div>}
    </div>
  );
}
