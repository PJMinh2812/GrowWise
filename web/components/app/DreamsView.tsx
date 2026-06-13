"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { addDream, redeemDream, deleteDream, updateDream } from "@/lib/app/child-actions";
import type { DreamItem } from "@/lib/types";

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
      <button
        onClick={() => setOpen(true)}
        className="mb-5 inline-flex items-center gap-2 px-5 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold"
      >
        <span className="material-symbols-outlined">add</span> Thêm ước mơ
      </button>

      {dreams.length === 0 ? (
        <div className="app-card p-8 text-center text-on-surface-variant">
          Chưa có ước mơ nào. Hãy thêm điều con muốn tiết kiệm để mua nhé!
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {dreams.map((d) => (
            <DreamCard key={d.id} dream={d} childId={childId} totalCoins={totalCoins} />
          ))}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="app-card w-full max-w-sm p-6">
            <h3 className="text-lg font-bold text-on-surface mb-4">Thêm ước mơ</h3>
            <div className="flex flex-wrap gap-2 mb-3">
              {ICONS.map((ic) => (
                <button
                  key={ic}
                  onClick={() => setIcon(ic)}
                  className={`w-9 h-9 rounded-[12px] text-lg border ${
                    icon === ic ? "border-primary bg-primary-container/20" : "border-outline-variant"
                  }`}
                >
                  {ic}
                </button>
              ))}
            </div>
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Tên món đồ"
              className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-3"
            />
            <label className="block text-sm font-semibold text-on-surface mb-1">Giá (xu)</label>
            <input
              type="number"
              min={1}
              value={price}
              onChange={(e) => setPrice(Number(e.target.value))}
              className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-4"
            />
            <div className="flex gap-2">
              <button
                onClick={() => setOpen(false)}
                className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
              >
                Huỷ
              </button>
              <button
                onClick={add}
                disabled={pending}
                className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
              >
                {pending ? "Đang thêm…" : "Thêm"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function DreamCard({
  dream,
  childId,
  totalCoins,
}: {
  dream: DreamItem;
  childId: string;
  totalCoins: number;
}) {
  const router = useRouter();
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
    <div className="app-card p-5 relative">
      {/* Edit/Delete buttons */}
      <div className="absolute top-3 right-3 flex gap-1">
        {!dream.is_purchased && (
          <button
            onClick={openEdit}
            className="p-1 rounded-full hover:bg-surface-container transition-colors text-on-surface-variant"
            title="Sửa ước mơ"
          >
            <span className="material-symbols-outlined text-base">edit</span>
          </button>
        )}
        <button
          onClick={() =>
            start(async () => {
              await deleteDream({ dreamId: dream.id });
              router.refresh();
            })
          }
          disabled={pending}
          className="p-1 rounded-full hover:bg-error/10 transition-colors text-on-surface-variant hover:text-error disabled:opacity-40"
          title="Xóa ước mơ"
        >
          <span className="material-symbols-outlined text-base">delete</span>
        </button>
      </div>

      <div className="text-4xl mb-2">{dream.icon}</div>
      <p className="font-bold text-on-surface pr-12">{dream.name}</p>
      {dream.is_purchased ? (
        <p className="text-sm text-tertiary font-semibold mt-1">✓ Đã đổi</p>
      ) : (
        <>
          <p className="text-sm text-on-surface-variant mt-1">
            🪙 {totalCoins.toLocaleString("vi-VN")} / {dream.price.toLocaleString("vi-VN")}
          </p>
          <div className="h-2.5 rounded-full bg-surface-container-highest mt-2 overflow-hidden">
            <div className="h-full bg-primary rounded-full" style={{ width: `${pct}%` }} />
          </div>
          <button
            disabled={!funded || pending}
            onClick={() =>
              start(async () => {
                await redeemDream({ childId, dreamId: dream.id, price: dream.price });
                router.refresh();
              })
            }
            className="mt-3 w-full py-2 rounded-[14px] bg-primary text-on-primary text-sm font-bold disabled:opacity-40"
          >
            {pending ? "Đang đổi…" : funded ? "Đổi ngay 🎉" : `Còn ${pct}%`}
          </button>
        </>
      )}

      {/* Edit modal */}
      {editing && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="app-card w-full max-w-sm p-6">
            <h3 className="text-lg font-bold text-on-surface mb-4">Sửa ước mơ</h3>
            <div className="flex flex-wrap gap-2 mb-3">
              {ICONS.map((ic) => (
                <button
                  key={ic}
                  onClick={() => setEditIcon(ic)}
                  className={`w-9 h-9 rounded-[12px] text-lg border ${
                    editIcon === ic ? "border-primary bg-primary-container/20" : "border-outline-variant"
                  }`}
                >
                  {ic}
                </button>
              ))}
            </div>
            <input
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              placeholder="Tên món đồ"
              className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-3"
            />
            <label className="block text-sm font-semibold text-on-surface mb-1">Giá (xu)</label>
            <input
              type="number"
              min={1}
              value={editPrice}
              onChange={(e) => setEditPrice(Number(e.target.value))}
              className="w-full border border-outline-variant rounded-[14px] px-3 py-2.5 text-on-surface mb-4"
            />
            <div className="flex gap-2">
              <button
                onClick={() => setEditing(false)}
                className="flex-1 py-2.5 rounded-[14px] bg-surface-container text-on-surface-variant font-semibold"
              >
                Huỷ
              </button>
              <button
                disabled={pending || !editName.trim()}
                onClick={() =>
                  start(async () => {
                    await updateDream({ dreamId: dream.id, name: editName.trim(), price: editPrice, icon: editIcon });
                    setEditing(false);
                    router.refresh();
                  })
                }
                className="flex-1 py-2.5 rounded-[14px] bg-primary text-on-primary font-bold disabled:opacity-50"
              >
                {pending ? "Đang lưu…" : "Lưu"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
