"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Emoji from "@/components/Emoji";

interface Survey {
  id: string;
  title: string;
  description: string | null;
  url: string;
  audience: "parent" | "child" | "all";
  min_age: number | null;
  max_age: number | null;
  is_published: boolean;
  created_at: string;
  published_at: string | null;
}

const AUDIENCE_LABEL: Record<string, string> = {
  parent: "Phụ huynh",
  child: "Trẻ em",
  all: "Tất cả",
};

export default function AdminSurveysPage() {
  const router = useRouter();
  const [surveys, setSurveys] = useState<Survey[]>([]);
  const [role, setRole] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState("");

  // create / edit form
  const [editingId, setEditingId] = useState<string | null>(null);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [url, setUrl] = useState("");
  const [audience, setAudience] = useState<"parent" | "child" | "all">("all");
  const [minAge, setMinAge] = useState("");
  const [maxAge, setMaxAge] = useState("");
  const [creating, setCreating] = useState(false);

  const canPublish = role === "admin" || role === "manager";

  function resetForm() {
    setEditingId(null);
    setTitle("");
    setDescription("");
    setUrl("");
    setAudience("all");
    setMinAge("");
    setMaxAge("");
  }

  function startEdit(s: Survey) {
    setEditingId(s.id);
    setTitle(s.title);
    setDescription(s.description ?? "");
    setUrl(s.url);
    setAudience(s.audience);
    setMinAge(s.min_age != null ? String(s.min_age) : "");
    setMaxAge(s.max_age != null ? String(s.max_age) : "");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  useEffect(() => {
    load();
  }, []);

  async function load() {
    setLoading(true);
    const res = await fetch("/api/admin/surveys");
    if (res.status === 403) {
      router.replace("/admin/lessons");
      return;
    }
    const data = await res.json();
    setSurveys(data.surveys ?? []);
    setRole(data.role ?? "");
    setLoading(false);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setCreating(true);
    setError("");
    const payload = {
      title,
      description,
      url,
      audience,
      min_age: audience !== "parent" && minAge !== "" ? Number(minAge) : null,
      max_age: audience !== "parent" && maxAge !== "" ? Number(maxAge) : null,
    };
    const res = await fetch(
      editingId ? `/api/admin/surveys/${editingId}` : "/api/admin/surveys",
      {
        method: editingId ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      },
    );
    const json = await res.json();
    if (!res.ok) {
      setError(json.error ?? "Không lưu được khảo sát");
    } else {
      resetForm();
      await load();
    }
    setCreating(false);
  }

  async function patchSurvey(id: string, patch: object) {
    setBusy(id);
    setError("");
    const res = await fetch(`/api/admin/surveys/${id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(patch),
    });
    if (!res.ok) setError((await res.json()).error ?? "Lỗi");
    await load();
    setBusy(null);
  }

  async function remove(id: string) {
    if (!confirm("Xoá khảo sát này?")) return;
    setBusy(id);
    const res = await fetch(`/api/admin/surveys/${id}`, { method: "DELETE" });
    if (!res.ok) setError((await res.json()).error ?? "Lỗi");
    await load();
    setBusy(null);
  }

  return (
    <div className="p-6 max-w-[1100px] mx-auto space-y-6">
      <div>
        <h2 className="text-3xl font-bold text-on-surface flex items-center gap-2"><Emoji name="clipboard" size={26} /> Khảo sát</h2>
        <p className="text-sm text-on-surface-variant mt-1">
          Tạo khảo sát (link Google Form) hiển thị dạng banner ở dashboard người dùng.
          {!canPublish && " Bạn tạo được bản nháp; cần Quản lý/Admin duyệt (Publish)."}
        </p>
      </div>

      {/* Create / edit form */}
      <form onSubmit={handleSubmit} className="bg-surface-container-lowest rounded-xl border border-outline-variant p-6 space-y-4">
        <h3 className="text-lg font-semibold text-on-surface">
          {editingId ? "Sửa khảo sát" : "Tạo khảo sát mới"}
        </h3>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Tiêu đề</label>
            <input value={title} onChange={e => setTitle(e.target.value)} required placeholder="Khảo sát trải nghiệm GrowWise"
              className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary" />
          </div>
          <div>
            <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Đối tượng</label>
            <select value={audience} onChange={e => setAudience(e.target.value as "parent" | "child" | "all")}
              className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary">
              <option value="all">Tất cả</option>
              <option value="parent">Phụ huynh</option>
              <option value="child">Trẻ em</option>
            </select>
          </div>
        </div>
        <div>
          <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Link Google Form</label>
          <input value={url} onChange={e => setUrl(e.target.value)} required type="url" placeholder="https://forms.gle/..."
            className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary" />
        </div>
        <div>
          <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Mô tả (tuỳ chọn)</label>
          <textarea value={description} onChange={e => setDescription(e.target.value)} rows={2} placeholder="Giúp chúng tôi cải thiện ứng dụng…"
            className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary" />
        </div>

        {audience !== "parent" && (
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Tuổi tối thiểu của trẻ (tuỳ chọn)</label>
              <input type="number" min={0} max={18} value={minAge} onChange={e => setMinAge(e.target.value)} placeholder="vd: 9"
                className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1">Tuổi tối đa của trẻ (tuỳ chọn)</label>
              <input type="number" min={0} max={18} value={maxAge} onChange={e => setMaxAge(e.target.value)} placeholder="vd: 15"
                className="w-full border border-outline-variant rounded-lg px-4 py-2.5 text-sm text-on-surface bg-surface-container-lowest outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary" />
            </div>
          </div>
        )}

        <p className="text-xs text-on-surface-variant">
          <Emoji name="bulb" size={14} /> Để xác minh người dùng đã nộp form: trong link, đặt câu &quot;Mã xác nhận&quot; với giá trị
          <code className="mx-1 px-1 rounded bg-surface-container">__TOKEN__</code>
          (xem hướng dẫn Apps Script). Không có thì banner ẩn ngay khi bấm.
        </p>

        {error && <p className="text-xs text-error">{error}</p>}
        <div className="flex gap-2">
          <button type="submit" disabled={creating}
            className="px-6 py-2.5 bg-primary text-on-primary text-sm font-semibold rounded-lg hover:opacity-90 active:scale-95 transition-all disabled:opacity-50">
            {creating ? "Đang lưu…" : editingId ? "Lưu thay đổi" : "Tạo bản nháp"}
          </button>
          {editingId && (
            <button type="button" onClick={resetForm}
              className="px-6 py-2.5 border border-outline-variant text-on-surface-variant text-sm font-semibold rounded-lg hover:bg-surface-container">
              Huỷ sửa
            </button>
          )}
        </div>
      </form>

      {/* List */}
      <div className="bg-surface-container-lowest rounded-xl border border-outline-variant">
        <div className="p-5 border-b border-outline-variant">
          <h3 className="text-lg font-semibold text-on-surface">Danh sách khảo sát</h3>
        </div>
        <div className="divide-y divide-outline-variant">
          {loading && <p className="px-6 py-10 text-center text-on-surface-variant">Đang tải…</p>}
          {!loading && surveys.length === 0 && (
            <p className="px-6 py-10 text-center text-on-surface-variant">Chưa có khảo sát nào</p>
          )}
          {surveys.map(s => (
            <div key={s.id} className="px-6 py-4 flex flex-wrap items-center gap-3">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="font-semibold text-on-surface truncate">{s.title}</p>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-semibold ${
                    s.is_published ? "bg-secondary-container text-on-secondary-container" : "bg-surface-container-high text-on-surface-variant"
                  }`}>
                    {s.is_published ? "Đang publish" : "Nháp"}
                  </span>
                  <span className="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary font-medium">
                    {AUDIENCE_LABEL[s.audience]}
                    {s.audience !== "parent" && (s.min_age != null || s.max_age != null)
                      ? ` · ${s.min_age ?? 0}–${s.max_age ?? "∞"} tuổi`
                      : ""}
                  </span>
                  {s.url.includes("__TOKEN__") && (
                    <span className="text-xs px-2 py-0.5 rounded-full bg-secondary/10 text-secondary font-medium">Có xác minh</span>
                  )}
                </div>
                <a href={s.url} target="_blank" rel="noopener noreferrer" className="text-xs text-primary hover:underline break-all">
                  {s.url}
                </a>
                <p className="text-[11px] text-on-surface-variant mt-0.5">
                  Tạo: {new Date(s.created_at).toLocaleDateString("vi-VN")}
                </p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => startEdit(s)}
                  className="text-xs px-3 py-1.5 rounded-lg font-semibold border border-outline-variant text-on-surface-variant hover:bg-surface-container"
                >
                  Sửa
                </button>
                {canPublish ? (
                  <button
                    onClick={() => patchSurvey(s.id, { is_published: !s.is_published })}
                    disabled={busy === s.id}
                    className={`text-xs px-3 py-1.5 rounded-lg font-semibold disabled:opacity-50 ${
                      s.is_published
                        ? "border border-outline-variant text-on-surface-variant hover:bg-surface-container"
                        : "bg-primary text-on-primary hover:opacity-90"
                    }`}
                  >
                    {s.is_published ? "Bỏ publish" : "Publish"}
                  </button>
                ) : (
                  <span className="text-xs text-on-surface-variant italic">Cần Quản lý duyệt</span>
                )}
                {canPublish && (
                  <button onClick={() => remove(s.id)} disabled={busy === s.id}
                    className="text-xs px-2.5 py-1.5 rounded-lg text-error hover:bg-error-container/10 font-medium disabled:opacity-50">
                    Xoá
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
