"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Plan, UserSubscription } from "@/lib/types";

interface PlanWithCount extends Plan {
  subscriber_count: number;
}

interface SubWithEmail extends UserSubscription {
  email: string;
}

function formatVND(amount: number) {
  return amount.toLocaleString("vi-VN") + "₫";
}

function statusBadge(status: string) {
  const map: Record<string, string> = {
    active: "bg-green-100 text-green-700",
    trial: "bg-blue-100 text-blue-700",
    canceled: "bg-red-100 text-red-700",
    expired: "bg-gray-100 text-gray-600",
  };
  const labels: Record<string, string> = {
    active: "Active",
    trial: "Dùng thử",
    canceled: "Đã hủy",
    expired: "Hết hạn",
  };
  return (
    <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${map[status] ?? "bg-gray-100"}`}>
      {labels[status] ?? status}
    </span>
  );
}

export default function PricingAdminPage() {
  const [plans, setPlans] = useState<PlanWithCount[]>([]);
  const [subs, setSubs] = useState<SubWithEmail[]>([]);
  const [monthlyRevenue, setMonthlyRevenue] = useState(0);
  const [loading, setLoading] = useState(true);
  const [editingPrice, setEditingPrice] = useState<Record<string, string>>({});
  const [saving, setSaving] = useState<string | null>(null);

  useEffect(() => {
    fetchAll();
  }, []);

  async function fetchAll() {
    setLoading(true);
    const [plansRes, subsRes] = await Promise.all([
      fetch("/api/admin/pricing/plans"),
      fetch("/api/admin/pricing/subscriptions"),
    ]);
    if (plansRes.ok) setPlans(await plansRes.json());
    if (subsRes.ok) {
      const data = await subsRes.json();
      setSubs(data.subscriptions ?? []);
      setMonthlyRevenue(data.monthly_revenue ?? 0);
    }
    setLoading(false);
  }

  async function savePrice(plan: PlanWithCount) {
    const newPrice = parseInt(editingPrice[plan.id] ?? "");
    if (isNaN(newPrice) || newPrice < 0) return;
    setSaving(plan.id);
    await fetch("/api/admin/pricing/plans", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: plan.id, price_monthly: newPrice }),
    });
    setSaving(null);
    setEditingPrice((prev) => {
      const next = { ...prev };
      delete next[plan.id];
      return next;
    });
    fetchAll();
  }

  async function cancelSub(subId: string) {
    if (!confirm("Hủy subscription này?")) return;
    await fetch("/api/admin/pricing/subscriptions", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: subId, status: "canceled" }),
    });
    fetchAll();
  }

  const planEmoji: Record<string, string> = { free: "🌱", premium: "🚀", family: "👨‍👩‍👧‍👦" };

  if (loading) {
    return (
      <div className="min-h-screen bg-muted/30 flex items-center justify-center">
        <p className="text-muted-foreground">Đang tải...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/30">
      {/* Header */}
      <div className="bg-white border-b border-border px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/admin/lessons" className="text-sm text-muted-foreground hover:text-foreground">
            ← Bài học
          </Link>
          <h1 className="text-xl font-bold">💰 Quản lý Pricing</h1>
        </div>
        <div className="text-sm text-muted-foreground">
          Revenue tháng này:{" "}
          <span className="font-bold text-green-600">{formatVND(monthlyRevenue)}</span>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-6 py-8 space-y-10">
        {/* Plan cards */}
        <section>
          <h2 className="text-lg font-bold mb-4">Gói hiện tại</h2>
          <div className="grid md:grid-cols-3 gap-5">
            {plans.map((plan) => (
              <div key={plan.id} className="bg-white rounded-2xl border border-border p-5 shadow-sm">
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <div className="text-2xl">{planEmoji[plan.name]}</div>
                    <h3 className="font-bold text-foreground mt-1">{plan.display_name}</h3>
                    <p className="text-xs text-muted-foreground capitalize">{plan.name}</p>
                  </div>
                  <span
                    className={`text-xs px-2 py-1 rounded-full font-medium ${
                      plan.is_active ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500"
                    }`}
                  >
                    {plan.is_active ? "Active" : "Tắt"}
                  </span>
                </div>

                <div className="space-y-2 text-sm mb-4">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Subscribers</span>
                    <span className="font-bold text-foreground">{plan.subscriber_count}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Giá tháng</span>
                    <span className="font-semibold">
                      {plan.price_monthly === 0 ? "Miễn phí" : formatVND(plan.price_monthly)}
                    </span>
                  </div>
                  {plan.price_yearly && (
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Giá năm</span>
                      <span className="font-semibold">{formatVND(plan.price_yearly)}</span>
                    </div>
                  )}
                </div>

                {plan.name !== "free" && (
                  <div className="flex gap-2">
                    <input
                      type="number"
                      placeholder={String(plan.price_monthly)}
                      value={editingPrice[plan.id] ?? ""}
                      onChange={(e) =>
                        setEditingPrice((prev) => ({ ...prev, [plan.id]: e.target.value }))
                      }
                      className="flex-1 border border-border rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                    <button
                      onClick={() => savePrice(plan)}
                      disabled={saving === plan.id || !editingPrice[plan.id]}
                      className="bg-primary text-white text-sm px-3 py-1.5 rounded-lg hover:bg-primary/90 disabled:opacity-50"
                    >
                      {saving === plan.id ? "..." : "Lưu"}
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        </section>

        {/* Subscriptions table */}
        <section>
          <h2 className="text-lg font-bold mb-4">
            Subscriptions ({subs.length})
          </h2>
          <div className="bg-white rounded-2xl border border-border overflow-hidden shadow-sm">
            <table className="w-full text-sm">
              <thead className="bg-muted/40 border-b border-border">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold text-muted-foreground">Email</th>
                  <th className="text-left px-4 py-3 font-semibold text-muted-foreground">Gói</th>
                  <th className="text-left px-4 py-3 font-semibold text-muted-foreground">Thanh toán</th>
                  <th className="text-left px-4 py-3 font-semibold text-muted-foreground">Trạng thái</th>
                  <th className="text-left px-4 py-3 font-semibold text-muted-foreground">Bắt đầu</th>
                  <th className="px-4 py-3"></th>
                </tr>
              </thead>
              <tbody>
                {subs.length === 0 && (
                  <tr>
                    <td colSpan={6} className="text-center py-10 text-muted-foreground">
                      Chưa có subscription nào
                    </td>
                  </tr>
                )}
                {subs.map((sub) => (
                  <tr key={sub.id} className="border-t border-border hover:bg-muted/20">
                    <td className="px-4 py-3 font-medium">{sub.email}</td>
                    <td className="px-4 py-3">
                      <span className="flex items-center gap-1.5">
                        {planEmoji[(sub.plan as Plan | undefined)?.name ?? "free"]}
                        {(sub.plan as Plan | undefined)?.display_name ?? "—"}
                      </span>
                    </td>
                    <td className="px-4 py-3 capitalize text-muted-foreground">{sub.billing_interval}</td>
                    <td className="px-4 py-3">{statusBadge(sub.status)}</td>
                    <td className="px-4 py-3 text-muted-foreground">
                      {new Date(sub.current_period_start).toLocaleDateString("vi-VN")}
                    </td>
                    <td className="px-4 py-3">
                      {sub.status === "active" || sub.status === "trial" ? (
                        <button
                          onClick={() => cancelSub(sub.id)}
                          className="text-xs text-red-500 hover:underline"
                        >
                          Hủy
                        </button>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}
