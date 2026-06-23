"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { addDream, redeemDream, deleteDream, updateDream } from "@/lib/app/child-actions";
import type { DreamItem } from "@/lib/types";
import { useLang } from "./LangProvider";

const ICONS = ["🎁", "🎮", "🚲", "📱", "🧸", "👟", "🎨", "📚", "⚽", "🎧"];

export default function DreamsView({
  childId,
  totalCoins,
  dreams,
}: {
  childId: string;
  totalCoins: number;
  dreams: DreamItem[];
}) {
  const router = useRouter();
  const { t } = useLang();
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [price, setPrice] = useState(100);
  const [icon, setIcon] = useState(ICONS[0]);
  const [pending, start] = useTransition();

  function add() {
    if (!name.trim()) return;
    start(async () => {
      await addDream({ childId, name: name.trim(), price, icon });
      setOpen(false);
      setName("");
      setPrice(100);
      router.refresh();
    });
  }

  return (
    <div>
      <button onClick={() => setOpen(true)} className="gw-btn gw-btn--primary gw-btn--sm" style={{ marginBottom: "20px" }}>
        <span className="material-symbols-outlined">add</span> {t("addDream")}
      </button>

      {dreams.length === 0 ? (
        <div className="gw-card" style={{ padding: "32px", textAlign: "center", color: "var(--ink-soft)" }}>
          {t("noDreams")}
        </div>
      ) : (
        <div className="gw-grid">
          {dreams.map((d) => (
            <DreamCard key={d.id} dream={d} childId={childId} totalCoins={totalCoins} />
          ))}
        </div>
      )}

      {open && (
        <div style={{ position: "fixed", inset: 0, zIndex: 50, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(0,0,0,.45)", padding: "16px" }}>
          <div className="gw-card" style={{ width: "100%", maxWidth: "360px" }}>
            <h3 style={{ fontSize: "17px", fontWeight: 900, color: "var(--ink)", marginBottom: "16px" }}>{t("addDream")}</h3>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginBottom: "12px" }}>
              {ICONS.map((ic) => (
                <button
                  key={ic}
                  onClick={() => setIcon(ic)}
                  style={{
                    width: "40px", height: "40px", borderRadius: "12px", fontSize: "20px",
                    border: ic === icon ? "2px solid var(--primary-c)" : "1.5px solid var(--outline-v)",
                    background: ic === icon ? "var(--primary-fixed)" : "var(--white)",
                    cursor: "pointer",
                  }}
                >
                  {ic}
                </button>
              ))}
            </div>
            <div className="gw-field" style={{ marginBottom: "12px" }}>
              <span className="material-symbols-outlined">star</span>
              <input value={name} onChange={(e) => setName(e.target.value)} placeholder={t("dreamItemName")} className="gw-input" />
            </div>
            <div className="gw-field" style={{ marginBottom: "16px" }}>
              <span className="material-symbols-outlined">toll</span>
              <input type="number" min={1} value={price} onChange={(e) => setPrice(Number(e.target.value))} className="gw-input" placeholder={t("dreamPrice")} />
            </div>
            <div style={{ display: "flex", gap: "8px" }}>
              <button onClick={() => setOpen(false)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>{t("cancel")}</button>
              <button onClick={add} disabled={pending} className="gw-btn gw-btn--primary gw-btn--sm" style={{ flex: 1 }}>
                {pending ? t("adding") : t("addBtn")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function DreamCard({ dream, childId, totalCoins }: { dream: DreamItem; childId: string; totalCoins: number }) {
  const router = useRouter();
  const { t } = useLang();
  const [pending, start] = useTransition();
  const [editing, setEditing] = useState(false);
  const [editName, setEditName] = useState(dream.name);
  const [editPrice, setEditPrice] = useState(dream.price);
  const [editIcon, setEditIcon] = useState(dream.icon);
  const pct = Math.min(100, Math.round((totalCoins / Math.max(1, dream.price)) * 100));
  const funded = totalCoins >= dream.price;

  function openEdit() {
    setEditName(dream.name);
    setEditPrice(dream.price);
    setEditIcon(dream.icon);
    setEditing(true);
  }

  return (
    <div className="gw-card" style={{ position: "relative", padding: "16px" }}>
      <div style={{ position: "absolute", top: "10px", right: "10px", display: "flex", gap: "4px" }}>
        {!dream.is_purchased && (
          <button
            onClick={openEdit}
            style={{ padding: "4px", borderRadius: "50%", border: "none", background: "none", cursor: "pointer", color: "var(--ink-soft)" }}
            title={t("edit")}
          >
            <span className="material-symbols-outlined" style={{ fontSize: "18px" }}>edit</span>
          </button>
        )}
        <button
          onClick={() => start(async () => { await deleteDream({ dreamId: dream.id }); router.refresh(); })}
          disabled={pending}
          style={{ padding: "4px", borderRadius: "50%", border: "none", background: "none", cursor: "pointer", color: "var(--ink-soft)" }}
          title={t("deletePinTitle")}
        >
          <span className="material-symbols-outlined" style={{ fontSize: "18px" }}>delete</span>
        </button>
      </div>

      <div style={{ fontSize: "36px", marginBottom: "8px" }}>{dream.icon}</div>
      <p style={{ fontWeight: 800, color: "var(--ink)", paddingRight: "48px" }}>{dream.name}</p>

      {dream.is_purchased ? (
        <p style={{ fontSize: "13px", color: "var(--secondary)", fontWeight: 700, marginTop: "4px" }}>{t("redeemed")}</p>
      ) : (
        <>
          <p style={{ fontSize: "12px", color: "var(--ink-soft)", marginTop: "4px" }}>
            🪙 {totalCoins.toLocaleString("vi-VN")} / {dream.price.toLocaleString("vi-VN")}
          </p>
          <div className="gw-progress orange" style={{ marginTop: "8px" }}>
            <i style={{ width: `${pct}%` }} />
          </div>
          <button
            disabled={!funded || pending}
            onClick={() => start(async () => { await redeemDream({ childId, dreamId: dream.id, price: dream.price }); router.refresh(); })}
            className="gw-btn gw-btn--primary gw-btn--sm"
            style={{ marginTop: "10px", width: "100%" }}
          >
            {pending ? t("redeeming") : funded ? t("redeemNow") : `${pct}%`}
          </button>
        </>
      )}

      {editing && (
        <div style={{ position: "fixed", inset: 0, zIndex: 50, display: "flex", alignItems: "center", justifyContent: "center", background: "rgba(0,0,0,.45)", padding: "16px" }}>
          <div className="gw-card" style={{ width: "100%", maxWidth: "360px" }}>
            <h3 style={{ fontSize: "17px", fontWeight: 900, color: "var(--ink)", marginBottom: "16px" }}>{t("editDream")}</h3>
            <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginBottom: "12px" }}>
              {ICONS.map((ic) => (
                <button
                  key={ic}
                  onClick={() => setEditIcon(ic)}
                  style={{
                    width: "40px", height: "40px", borderRadius: "12px", fontSize: "20px",
                    border: ic === editIcon ? "2px solid var(--primary-c)" : "1.5px solid var(--outline-v)",
                    background: ic === editIcon ? "var(--primary-fixed)" : "var(--white)",
                    cursor: "pointer",
                  }}
                >
                  {ic}
                </button>
              ))}
            </div>
            <div className="gw-field" style={{ marginBottom: "12px" }}>
              <span className="material-symbols-outlined">star</span>
              <input value={editName} onChange={(e) => setEditName(e.target.value)} placeholder={t("dreamItemName")} className="gw-input" />
            </div>
            <div className="gw-field" style={{ marginBottom: "16px" }}>
              <span className="material-symbols-outlined">toll</span>
              <input type="number" min={1} value={editPrice} onChange={(e) => setEditPrice(Number(e.target.value))} className="gw-input" placeholder={t("dreamPrice")} />
            </div>
            <div style={{ display: "flex", gap: "8px" }}>
              <button onClick={() => setEditing(false)} className="gw-btn gw-btn--ghost gw-btn--sm" style={{ flex: 1 }}>{t("cancel")}</button>
              <button
                disabled={pending || !editName.trim()}
                onClick={() => start(async () => {
                  await updateDream({ dreamId: dream.id, name: editName.trim(), price: editPrice, icon: editIcon });
                  setEditing(false);
                  router.refresh();
                })}
                className="gw-btn gw-btn--primary gw-btn--sm"
                style={{ flex: 1 }}
              >
                {pending ? t("saving") : t("save")}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
