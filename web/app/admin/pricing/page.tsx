"use client";

import { useEffect, useState } from "react";
import { Plan, UserSubscription } from "@/lib/types";
import { effectiveYearly, YEARLY_DISCOUNT } from "@/lib/app/pricing-utils";
import Emoji, { type EmojiName } from "@/components/Emoji";

interface PlanWithCount extends Plan {
  subscriber_count: number;
}

interface SubWithEmail extends UserSubscription {
  email: string;
}

function formatVND(amount: number) {
  return amount.toLocaleString("vi-VN") + "₫";
}

const INTERVAL_LABEL: Record<string, string> = {
  monthly: "Hàng tháng",
  yearly:  "Hàng năm",
};

const STATUS_LABEL: Record<string, string> = {
  active:   "Hoạt động",
  trial:    "Dùng thử",
  canceled: "Đã hủy",
  expired:  "Hết hạn",
};

const STATUS_CLASS: Record<string, string> = {
  active:   "bg-secondary-container text-on-secondary-container",
  trial:    "bg-blue-100 text-blue-700",
  canceled: "bg-error-container text-on-error-container",
  expired:  "bg-surface-container-high text-on-surface-variant",
};

const PLAN_EMOJI: Record<string, EmojiName> = { free: "seedling", premium: "rocket", family: "family" };

function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${STATUS_CLASS[status] ?? "bg-surface-container-high text-on-surface-variant"}`}>
      {STATUS_LABEL[status] ?? status}
    </span>
  );
}

export default function PricingAdminPage() {
  const [plans, setPlans]               = useState<PlanWithCount[]>([]);
  const [subs, setSubs]                 = useState<SubWithEmail[]>([]);
  const [monthlyRevenue, setMonthlyRevenue] = useState(0);
  const [loading, setLoading]           = useState(true);
  const [editingName,    setEditingName]    = useState<Record<string, string>>({});
  const [editingMonthly, setEditingMonthly] = useState<Record<string, string>>({});
  const [saving, setSaving]                 = useState<string | null>(null);

  /** Monthly price currently in effect for a plan (edited value if any). */
  function currentMonthly(planId: string, planMonthly: number): number {
    const edited = editingMonthly[planId];
    if (edited === undefined || edited === "") return planMonthly;
    const n = parseInt(edited);
    return isNaN(n) ? planMonthly : n;
  }

  useEffect(() => { fetchAll(); }, []);

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

  async function savePlan(plan: PlanWithCount) {
    const monthly     = editingMonthly[plan.id]  !== undefined ? parseInt(editingMonthly[plan.id])   : undefined;
    const display_name= editingName[plan.id]?.trim() || undefined;
    if (monthly !== undefined && isNaN(monthly)) return;
    if (monthly === undefined && !display_name) return;
    // Yearly is always auto 20% off the (new) monthly — keep DB in sync.
    const yearly = monthly !== undefined ? effectiveYearly(monthly) : undefined;
    setSaving(plan.id);
    await fetch("/api/admin/pricing/plans", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: plan.id, price_monthly: monthly, price_yearly: yearly, display_name }),
    });
    setSaving(null);
    setEditingName(prev     => { const n = { ...prev }; delete n[plan.id]; return n; });
    setEditingMonthly(prev  => { const n = { ...prev }; delete n[plan.id]; return n; });
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

  if (loading) {
    return (
      <div className="p-6">
        <div className="h-8 w-48 bg-surface-container rounded animate-pulse mb-8" />
        <div className="grid md:grid-cols-3 gap-5">
          {[0,1,2].map(i => (
            <div key={i} className="bg-surface-container-lowest border border-outline-variant rounded-xl p-5 h-40 animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-[1440px] mx-auto space-y-8">
      {/* Header */}
      <div className="flex items-end justify-between">
        <div>
          <h2 className="text-3xl font-bold text-on-surface flex items-center gap-2"><Emoji name="moneybag" size={26} /> Định giá</h2>
          <p className="text-sm text-on-surface-variant mt-1">
            Doanh thu tháng này:{" "}
            <span className="font-bold text-secondary">{formatVND(monthlyRevenue)}</span>
          </p>
        </div>
      </div>

      {/* Plan cards */}
      <section>
        <h3 className="text-base font-semibold text-on-surface mb-4">Gói hiện tại</h3>
        <div className="grid md:grid-cols-3 gap-5">
          {plans.map(plan => (
            <div key={plan.id} className="bg-surface-container-lowest rounded-xl border border-outline-variant p-5 hover:-translate-y-0.5 hover:shadow-md transition-all">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <div className="mb-1"><Emoji name={PLAN_EMOJI[plan.name] ?? "box"} size={30} /></div>
                  <h4 className="font-bold text-on-surface">{plan.display_name}</h4>
                  <p className="text-xs text-on-surface-variant capitalize">{plan.name}</p>
                </div>
                <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${
                  plan.is_active
                    ? "bg-secondary-container text-on-secondary-container"
                    : "bg-surface-container-high text-on-surface-variant"
                }`}>
                  {plan.is_active ? "Đang hoạt động" : "Tắt"}
                </span>
              </div>

              <div className="space-y-2 text-sm mb-4 border-t border-outline-variant pt-3">
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">Người đăng ký</span>
                  <span className="font-bold text-on-surface">{plan.subscriber_count}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-on-surface-variant">Giá tháng</span>
                  <span className="font-semibold text-on-surface">
                    {plan.price_monthly === 0 ? "Miễn phí" : formatVND(plan.price_monthly)}
                  </span>
                </div>
                {plan.price_monthly > 0 && (
                  <div className="flex justify-between">
                    <span className="text-on-surface-variant">Giá năm (tự tính -20%)</span>
                    <span className="font-semibold text-on-surface">{formatVND(effectiveYearly(plan.price_monthly))}</span>
                  </div>
                )}
              </div>

              <div className="space-y-2 mt-2 border-t border-outline-variant pt-3">
                {/* Đổi tên hiển thị */}
                <input
                  type="text"
                  placeholder={`Tên hiển thị (${plan.display_name ?? plan.name})`}
                  value={editingName[plan.id] ?? ""}
                  onChange={e => setEditingName(prev => ({ ...prev, [plan.id]: e.target.value }))}
                  className="w-full border border-outline-variant rounded-lg px-3 py-1.5 text-sm bg-surface text-on-surface outline-none focus:border-primary"
                />

                {plan.name !== "free" && (
                  <>
                    {/* Giá tháng */}
                    <div className="flex gap-2">
                      <input
                        type="number"
                        placeholder={`Giá tháng (${plan.price_monthly.toLocaleString("vi-VN")}₫)`}
                        value={editingMonthly[plan.id] ?? ""}
                        onChange={e => setEditingMonthly(prev => ({ ...prev, [plan.id]: e.target.value }))}
                        className="flex-1 border border-outline-variant rounded-lg px-3 py-1.5 text-sm bg-surface text-on-surface outline-none focus:border-primary"
                      />
                      <span className="text-xs text-on-surface-variant self-center whitespace-nowrap">/tháng</span>
                    </div>

                    {/* Giá năm tự tính (-20%) */}
                    <div className="flex items-center gap-2 text-xs text-on-surface-variant bg-surface-container rounded-lg px-3 py-1.5">
                      <span>Giá năm (tự tính -{Math.round(YEARLY_DISCOUNT * 100)}%):</span>
                      <span className="font-semibold text-secondary">
                        {effectiveYearly(currentMonthly(plan.id, plan.price_monthly)).toLocaleString("vi-VN")}₫
                      </span>
                      <span className="ml-auto text-[11px] opacity-70">/năm</span>
                    </div>
                  </>
                )}

                <button
                  onClick={() => savePlan(plan)}
                  disabled={
                    saving === plan.id ||
                    (!editingName[plan.id] && !editingMonthly[plan.id])
                  }
                  className="w-full bg-primary text-on-primary text-sm py-1.5 rounded-lg hover:opacity-90 disabled:opacity-50 transition-all"
                >
                  {saving === plan.id ? "Đang lưu..." : "Lưu thay đổi"}
                </button>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Subscriptions table */}
      <section>
        <h3 className="text-base font-semibold text-on-surface mb-4">
          Đăng ký ({subs.length})
        </h3>
        <div className="bg-surface-container-lowest rounded-xl border border-outline-variant overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-surface-container-low border-b border-outline-variant">
                <tr>
                  <th className="text-left px-5 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Email</th>
                  <th className="text-left px-5 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Gói</th>
                  <th className="text-left px-5 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Chu kỳ</th>
                  <th className="text-left px-5 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Trạng thái</th>
                  <th className="text-left px-5 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Bắt đầu</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant">
                {subs.length === 0 && (
                  <tr>
                    <td colSpan={6} className="text-center py-12 text-on-surface-variant">
                      Chưa có đăng ký nào
                    </td>
                  </tr>
                )}
                {subs.map(sub => (
                  <tr key={sub.id} className="hover:bg-surface-container-low transition-colors">
                    <td className="px-5 py-3 font-medium text-on-surface">{sub.email}</td>
                    <td className="px-5 py-3">
                      <span className="flex items-center gap-1.5 text-on-surface">
                        <Emoji name={PLAN_EMOJI[(sub.plan as Plan | undefined)?.name ?? "free"] ?? "box"} size={16} />
                        {(sub.plan as Plan | undefined)?.display_name ?? "—"}
                      </span>
                    </td>
                    <td className="px-5 py-3 text-on-surface-variant">
                      {INTERVAL_LABEL[sub.billing_interval] ?? sub.billing_interval}
                    </td>
                    <td className="px-5 py-3"><StatusBadge status={sub.status} /></td>
                    <td className="px-5 py-3 text-on-surface-variant">
                      {new Date(sub.current_period_start).toLocaleDateString("vi-VN")}
                    </td>
                    <td className="px-5 py-3 text-right">
                      {(sub.status === "active" || sub.status === "trial") && (
                        <button
                          onClick={() => cancelSub(sub.id)}
                          className="text-xs text-error hover:underline"
                        >
                          Hủy
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </div>
  );
}
