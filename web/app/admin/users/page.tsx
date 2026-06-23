"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";

interface UserRow {
  id: string;
  email: string;
  created_at: string;
  last_sign_in_at: string | null;
  profile: {
    role: "admin" | "manager" | "staff";
    is_banned: boolean;
    access_granted: boolean;
  } | null;
}

function relativeTime(iso: string | null) {
  if (!iso) return "Chưa đăng nhập";
  const diff = Date.now() - new Date(iso).getTime();
  const h = Math.floor(diff / 3600000);
  const d = Math.floor(diff / 86400000);
  if (h < 1) return "Vừa mới xong";
  if (h < 24) return `${h} giờ trước`;
  if (d === 1) return "Hôm qua";
  return `${d} ngày trước`;
}

function avatarColor(email: string) {
  const colors = [
    "bg-primary/20 text-primary",
    "bg-secondary/20 text-secondary",
    "bg-orange-100 text-orange-600",
    "bg-blue-100 text-blue-600",
    "bg-pink-100 text-pink-600",
  ];
  return colors[email.charCodeAt(0) % colors.length];
}

export default function AdminUsersPage() {
  const router = useRouter();
  const [users, setUsers] = useState<UserRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteRole, setInviteRole] = useState<"staff" | "manager" | "admin">("staff");
  const [inviting, setInviting] = useState(false);
  const [inviteError, setInviteError] = useState("");
  const [inviteSuccess, setInviteSuccess] = useState("");
  const [filterRole, setFilterRole] = useState<"all" | "admin" | "staff" | "none">("all");
  const [filterStatus, setFilterStatus] = useState<"all" | "active" | "banned">("all");
  const [filterCreated, setFilterCreated] = useState<"all" | "today" | "7d" | "30d">("all");
  const [showFilter, setShowFilter] = useState(false);

  useEffect(() => { fetchUsers(); }, []);

  async function fetchUsers() {
    setLoading(true);
    const res = await fetch("/api/admin/users");
    if (!res.ok) { router.push("/admin/lessons"); return; }
    setUsers(await res.json());
    setLoading(false);
  }

  async function updateUser(id: string, patch: object) {
    setBusy(id);
    const res = await fetch(`/api/admin/users/${id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(patch),
    });
    if (!res.ok) {
      const { error } = await res.json();
      alert(error);
    }
    await fetchUsers();
    setBusy(null);
  }

  async function grantAccess(u: UserRow) {
    await updateUser(u.id, { email: u.email, role: "staff", is_banned: false, access_granted: true });
  }

  async function handleInvite(e: React.FormEvent) {
    e.preventDefault();
    setInviting(true);
    setInviteError("");
    setInviteSuccess("");
    const res = await fetch("/api/admin/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: inviteEmail, role: inviteRole }),
    });
    const json = await res.json();
    if (!res.ok) {
      setInviteError(json.error ?? "Có lỗi xảy ra");
    } else {
      setInviteSuccess(`Đã gửi lời mời đến ${inviteEmail}`);
      setInviteEmail("");
      await fetchUsers();
    }
    setInviting(false);
  }

  const adminCount   = users.filter(u => u.profile?.role === "admin").length;
  const staffCount   = users.filter(u => u.profile?.role === "staff").length;
  const activeCount  = users.filter(u => u.profile?.access_granted && !u.profile?.is_banned).length;
  const bannedCount  = users.filter(u => u.profile?.is_banned).length;

  function matchesCreated(iso: string) {
    if (filterCreated === "all") return true;
    const created = new Date(iso);
    const now = new Date();
    if (filterCreated === "today") return created.toDateString() === now.toDateString();
    const days = filterCreated === "7d" ? 7 : 30;
    return created.getTime() >= now.getTime() - days * 86400000;
  }

  const filteredUsers = users.filter(u => {
    if (filterRole === "admin"  && u.profile?.role !== "admin")  return false;
    if (filterRole === "staff"  && u.profile?.role !== "staff")  return false;
    if (filterRole === "none"   && u.profile?.access_granted)    return false;
    if (filterStatus === "active" && u.profile?.is_banned)       return false;
    if (filterStatus === "banned" && !u.profile?.is_banned)      return false;
    if (!matchesCreated(u.created_at))                           return false;
    return true;
  });

  const isFiltered = filterRole !== "all" || filterStatus !== "all" || filterCreated !== "all";

  return (
    <div className="p-6 max-w-[1440px] mx-auto space-y-6">
      {/* Page Header */}
      <div className="mb-2">
        <h2 className="text-3xl font-bold text-on-surface flex items-center gap-2">
          👥 Người dùng
        </h2>
        <p className="text-sm text-on-surface-variant mt-1">Quản lý tài khoản admin và staff truy cập hệ thống</p>
      </div>

      {/* Invite form */}
      <div className="bg-surface-container-lowest rounded-xl border border-outline-variant p-6 shadow-sm">
        <div className="flex items-center gap-2 mb-5">
          <span className="text-lg">➕</span>
          <h3 className="text-lg font-semibold text-on-surface">Mời thành viên mới</h3>
        </div>
        <form onSubmit={handleInvite} className="flex flex-col md:flex-row items-end gap-3">
          <div className="flex-1 w-full">
            <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Địa chỉ Email</label>
            <input
              type="email"
              required
              value={inviteEmail}
              onChange={e => setInviteEmail(e.target.value)}
              placeholder="example@growwise.vn"
              className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
          </div>
          <div className="w-full md:w-48">
            <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Vai trò</label>
            <select
              value={inviteRole}
              onChange={e => setInviteRole(e.target.value as "staff" | "manager" | "admin")}
              className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            >
              <option value="staff">Staff</option>
              <option value="manager">Quản lý (duyệt)</option>
              <option value="admin">Admin</option>
            </select>
          </div>
          <button
            type="submit"
            disabled={inviting}
            className="w-full md:w-auto px-6 py-2.5 bg-primary text-on-primary text-sm font-semibold rounded-lg hover:opacity-90 active:scale-95 transition-all flex items-center justify-center gap-2 disabled:opacity-50 h-[42px]"
          >
            {inviting ? "Đang gửi..." : "Gửi lời mời"}
          </button>
        </form>
        {inviteError && <p className="mt-2 text-xs text-error">{inviteError}</p>}
        {inviteSuccess && <p className="mt-2 text-xs text-secondary">{inviteSuccess}</p>}
      </div>

      {/* User table */}
      <div className="bg-surface-container-lowest rounded-xl border border-outline-variant shadow-sm">
        <div className="p-5 border-b border-outline-variant flex justify-between items-center bg-surface-container-lowest">
          <div className="flex items-center gap-3">
            <h3 className="text-lg font-semibold text-on-surface">Danh sách nhân sự</h3>
            {isFiltered && (
              <span className="text-xs px-2 py-0.5 bg-primary/10 text-primary rounded-full font-medium">
                {filteredUsers.length}/{users.length}
              </span>
            )}
          </div>
          <div className="relative">
            <button
              onClick={() => setShowFilter(v => !v)}
              className={`px-3 py-1.5 rounded-lg border transition-colors flex items-center gap-1.5 text-sm font-medium ${
                isFiltered
                  ? "border-primary bg-primary/10 text-primary"
                  : "border-outline-variant hover:bg-surface-container-high text-on-surface-variant"
              }`}
            >
              <span>⚙</span> Lọc {isFiltered && "•"}
            </button>
            {showFilter && (
              <div className="absolute right-0 top-9 z-20 bg-surface-container-lowest border border-outline-variant rounded-xl shadow-lg p-4 w-56 space-y-4">
                <div>
                  <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-2">Vai trò</p>
                  <div className="flex flex-col gap-1">
                    {(["all", "admin", "staff", "none"] as const).map(v => (
                      <label key={v} className="flex items-center gap-2 cursor-pointer text-sm text-on-surface hover:text-primary">
                        <input
                          type="radio"
                          name="filterRole"
                          checked={filterRole === v}
                          onChange={() => setFilterRole(v)}
                          className="accent-primary"
                        />
                        {{ all: "Tất cả", admin: "Admin", staff: "Staff", none: "Chưa cấp quyền" }[v]}
                      </label>
                    ))}
                  </div>
                </div>
                <div>
                  <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-2">Trạng thái</p>
                  <div className="flex flex-col gap-1">
                    {(["all", "active", "banned"] as const).map(v => (
                      <label key={v} className="flex items-center gap-2 cursor-pointer text-sm text-on-surface hover:text-primary">
                        <input
                          type="radio"
                          name="filterStatus"
                          checked={filterStatus === v}
                          onChange={() => setFilterStatus(v)}
                          className="accent-primary"
                        />
                        {{ all: "Tất cả", active: "Hoạt động", banned: "Bị khóa" }[v]}
                      </label>
                    ))}
                  </div>
                </div>
                <div>
                  <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-2">Ngày tạo tài khoản</p>
                  <div className="flex flex-col gap-1">
                    {(["all", "today", "7d", "30d"] as const).map(v => (
                      <label key={v} className="flex items-center gap-2 cursor-pointer text-sm text-on-surface hover:text-primary">
                        <input
                          type="radio"
                          name="filterCreated"
                          checked={filterCreated === v}
                          onChange={() => setFilterCreated(v)}
                          className="accent-primary"
                        />
                        {{ all: "Tất cả", today: "Hôm nay", "7d": "7 ngày qua", "30d": "30 ngày qua" }[v]}
                      </label>
                    ))}
                  </div>
                </div>
                <button
                  onClick={() => { setFilterRole("all"); setFilterStatus("all"); setFilterCreated("all"); setShowFilter(false); }}
                  className="w-full text-xs text-on-surface-variant hover:text-error text-center pt-1 border-t border-outline-variant"
                >
                  Xóa bộ lọc
                </button>
              </div>
            )}
          </div>
        </div>
        <div className="overflow-x-auto overflow-y-visible rounded-b-xl">
          <table className="w-full text-left border-collapse text-sm">
            <thead className="bg-surface-container-low">
              <tr>
                <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Thành viên</th>
                <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Vai trò</th>
                <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Trạng thái</th>
                <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Đăng nhập lần cuối</th>
                <th className="px-6 py-3 text-xs font-semibold text-on-surface-variant uppercase tracking-wider text-right">Hành động</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant">
              {loading && (
                <tr>
                  <td colSpan={5} className="px-6 py-10 text-center text-on-surface-variant">Đang tải...</td>
                </tr>
              )}
              {!loading && users.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-6 py-10 text-center text-on-surface-variant">Chưa có thành viên nào</td>
                </tr>
              )}
              {filteredUsers.map(u => (
                <tr key={u.id} className={`group hover:bg-surface-container-low/50 transition-colors ${u.profile?.is_banned ? "bg-error-container/5" : ""}`}>
                  {/* Member */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-base flex-shrink-0 ${avatarColor(u.email)}`}>
                        {u.email[0].toUpperCase()}
                      </div>
                      <div>
                        <p className="font-medium text-on-surface">{u.email.split("@")[0]}</p>
                        <p className="text-xs text-on-surface-variant">{u.email}</p>
                        <p className="text-[11px] text-on-surface-variant mt-0.5">
                          Tạo: {new Date(u.created_at).toLocaleDateString("vi-VN")}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Role */}
                  <td className="px-6 py-4">
                    {u.profile?.access_granted ? (
                      <select
                        value={u.profile.role}
                        disabled={busy === u.id}
                        onChange={e => updateUser(u.id, { email: u.email, role: e.target.value, is_banned: u.profile!.is_banned, access_granted: true })}
                        className={`text-xs px-2 py-1 rounded-full border font-semibold outline-none cursor-pointer disabled:opacity-50 ${
                          u.profile.role === "admin"
                            ? "bg-primary/10 text-primary border-primary/20"
                            : u.profile.role === "manager"
                              ? "bg-secondary/10 text-secondary border-secondary/20"
                              : "bg-surface-variant text-on-surface-variant border-outline-variant"
                        }`}
                      >
                        <option value="admin">Admin</option>
                        <option value="manager">Quản lý</option>
                        <option value="staff">Staff</option>
                      </select>
                    ) : (
                      <button
                        onClick={() => grantAccess(u)}
                        disabled={busy === u.id}
                        className="text-xs px-3 py-1 rounded-full bg-primary/10 text-primary border border-primary/20 font-semibold hover:bg-primary/20 transition-colors disabled:opacity-50"
                      >
                        + Cấp quyền
                      </button>
                    )}
                  </td>

                  {/* Status */}
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold ${
                      u.profile?.is_banned
                        ? "bg-error-container text-on-error-container"
                        : "bg-secondary-container text-on-secondary-container"
                    }`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${u.profile?.is_banned ? "bg-error" : "bg-secondary"}`} />
                      {u.profile?.is_banned ? "Bị khóa" : "Hoạt động"}
                    </span>
                  </td>

                  {/* Last login */}
                  <td className="px-6 py-4 text-xs text-on-surface-variant">{relativeTime(u.last_sign_in_at)}</td>

                  {/* Actions */}
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => updateUser(u.id, {
                          email: u.email,
                          role: u.profile?.role ?? "staff",
                          is_banned: !(u.profile?.is_banned ?? false),
                          access_granted: u.profile?.access_granted ?? false,
                        })}
                        disabled={busy === u.id}
                        className={`text-xs px-2.5 py-1 font-medium rounded hover:underline disabled:opacity-50 ${
                          u.profile?.is_banned ? "text-secondary" : "text-error"
                        }`}
                      >
                        {u.profile?.is_banned ? "Mở khóa" : "Khóa"}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Stats mini-widgets */}
      {!loading && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="bg-surface-container-lowest rounded-xl border border-outline-variant p-4">
            <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Tổng Admin</p>
            <p className="text-3xl font-bold text-primary mt-1">{String(adminCount).padStart(2, "0")}</p>
          </div>
          <div className="bg-surface-container-lowest rounded-xl border border-outline-variant p-4">
            <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Tổng Staff</p>
            <p className="text-3xl font-bold text-on-surface mt-1">{String(staffCount).padStart(2, "0")}</p>
          </div>
          <div className="bg-surface-container-lowest rounded-xl border border-outline-variant p-4">
            <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Đang hoạt động</p>
            <p className="text-3xl font-bold text-secondary mt-1">{String(activeCount).padStart(2, "0")}</p>
          </div>
          <div className="bg-surface-container-lowest rounded-xl border border-outline-variant p-4">
            <p className="text-xs font-semibold text-on-surface-variant uppercase tracking-wider">Tài khoản khóa</p>
            <p className="text-3xl font-bold text-error mt-1">{String(bannedCount).padStart(2, "0")}</p>
          </div>
        </div>
      )}
    </div>
  );
}
